package com.sunrise.dental.service;

import com.sunrise.dental.dao.*;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.AuditLog;
import com.sunrise.dental.model.User;
import com.sunrise.dental.util.PasswordUtil;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * AuthService — Authentication and session management business logic.
 *
 * Responsibilities:
 *   - Validate login credentials
 *   - Hash passwords securely
 *   - Record login/logout audit entries
 *
 * Security rules enforced here (server-side — cannot be bypassed):
 *   1. Username must exist
 *   2. Password must match BCrypt hash
 *   3. Account must be active (is_active = 1)
 *   4. Last login timestamp updated on success
 */
public class AuthService {

    private static final Logger logger = Logger.getLogger(AuthService.class.getName());

    private final UserDAO userDAO;
    private final AuditService auditService;

    public AuthService() {
        this.userDAO      = DAOFactory.getUserDAO();
        this.auditService = new AuditService();
    }

    // Testability constructor
    public AuthService(UserDAO userDAO, AuditService auditService) {
        this.userDAO      = userDAO;
        this.auditService = auditService;
    }

    /**
     * Authenticate a user.
     *
     * @param username  Username from login form
     * @param password  Plain-text password from login form
     * @param ipAddress Client IP for audit log
     * @return Authenticated User object
     * @throws ApplicationException if credentials invalid or account inactive
     */
    public User login(String username, String password, String ipAddress)
            throws ApplicationException {

        if (username == null || username.trim().isEmpty()) {
            throw new ApplicationException("Username is required.");
        }
        if (password == null || password.isEmpty()) {
            throw new ApplicationException("Password is required.");
        }

        // 1. Find user by username
        User user = userDAO.findByUsername(username.trim().toLowerCase());
        if (user == null) {
            // Don't reveal whether username or password was wrong (security)
            logger.warning("Login failed — unknown username: " + username);
            throw new ApplicationException("Invalid username or password.");
        }

        // 2. Check account is active
        if (!user.isActive()) {
            logger.warning("Login attempt on inactive account: " + username);
            throw new ApplicationException(
                "Your account has been deactivated. Please contact the administrator.");
        }

        // 3. Verify password (BCrypt)
        if (!PasswordUtil.verify(password, user.getPasswordHash())) {
            logger.warning("Login failed — wrong password for user: " + username);
            // Audit failed login
            auditService.log(null, username, "LOGIN_FAILED", "USER", user.getUserId(),
                "Failed login attempt", ipAddress, null);
            throw new ApplicationException("Invalid username or password.");
        }

        // 4. Update last login timestamp
        userDAO.updateLastLogin(user.getUserId());

        // 5. Audit successful login
        auditService.log(user.getUserId(), user.getUsername(), "LOGIN",
            "USER", user.getUserId(), "Successful login", ipAddress, null);

        // Clear password hash from returned object (never expose in session)
        user.setPasswordHash(null);
        return user;
    }

    /**
     * Record a logout event.
     *
     * @param user      The logged-out user
     * @param ipAddress Client IP
     */
    public void logout(User user, String ipAddress) {
        if (user != null) {
            try {
                auditService.log(user.getUserId(), user.getUsername(), "LOGOUT",
                    "USER", user.getUserId(), "User logged out", ipAddress, null);
            } catch (Exception e) {
                logger.log(Level.WARNING, "Audit log on logout failed (non-critical)", e);
            }
        }
    }

    /**
     * Change a user's password.
     * Validates current password before allowing change.
     */
    public void changePassword(int userId, String currentPassword,
                               String newPassword) throws ApplicationException {
        User user = userDAO.findById(userId);
        if (user == null) {
            throw new ApplicationException("User not found.");
        }

        // Re-fetch with hash (findById doesn't clear hash)
        User userWithHash = DAOFactory.getUserDAO().findByUsername(user.getUsername());
        if (!PasswordUtil.verify(currentPassword, userWithHash.getPasswordHash())) {
            throw new ApplicationException("Current password is incorrect.");
        }

        if (!PasswordUtil.meetsPolicy(newPassword)) {
            throw new ApplicationException(
                "New password must be at least 8 characters and include " +
                "uppercase, lowercase, and numeric characters.");
        }

        String newHash = PasswordUtil.hash(newPassword);
        userDAO.updatePassword(userId, newHash);
    }

    /**
     * Admin reset password — no current password required.
     */
    public void adminResetPassword(int userId, String newPassword)
            throws ApplicationException {
        if (!PasswordUtil.meetsPolicy(newPassword)) {
            throw new ApplicationException(
                "Password must be at least 8 characters with uppercase, lowercase, and digits.");
        }
        String hash = PasswordUtil.hash(newPassword);
        userDAO.updatePassword(userId, hash);
    }
}
