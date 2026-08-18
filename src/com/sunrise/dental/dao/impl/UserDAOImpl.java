package com.sunrise.dental.dao.impl;

import com.sunrise.dental.dao.UserDAO;
import com.sunrise.dental.exception.ApplicationException;
import com.sunrise.dental.model.User;
import com.sunrise.dental.util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * UserDAOImpl — JDBC implementation of UserDAO.
 * ALL SQL uses PreparedStatement — never string concatenation.
 */
public class UserDAOImpl implements UserDAO {

    private static final Logger logger = Logger.getLogger(UserDAOImpl.class.getName());

    // -------------------------------------------------------
    // Helper: map a ResultSet row → User
    // -------------------------------------------------------
    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setPhone(rs.getString("phone"));
        u.setRoleId(rs.getInt("role_id"));
        u.setRoleName(rs.getString("role_name"));
        u.setActive(rs.getBoolean("is_active"));

        Timestamp lastLogin = rs.getTimestamp("last_login");
        if (lastLogin != null) u.setLastLogin(lastLogin.toLocalDateTime());

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) u.setCreatedAt(createdAt.toLocalDateTime());

        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) u.setUpdatedAt(updatedAt.toLocalDateTime());

        return u;
    }

    // -------------------------------------------------------
    @Override
    public int save(User user) throws ApplicationException {
        final String sql =
            "INSERT INTO users (username, password_hash, full_name, email, phone, role_id, is_active) " +
            "VALUES (?, ?, ?, ?, ?, ?, 1)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPasswordHash());
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPhone());
            ps.setInt(6, user.getRoleId());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "save user failed: " + e.getMessage(), e);
            throw new ApplicationException("Unable to save user. Please try again.", e);
        }
        return 0;
    }

    @Override
    public User findById(int userId) throws ApplicationException {
        final String sql =
            "SELECT u.*, r.role_name FROM users u " +
            "JOIN roles r ON u.role_id = r.role_id " +
            "WHERE u.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findById user failed", e);
            throw new ApplicationException("Unable to retrieve user.", e);
        }
        return null;
    }

    @Override
    public User findByUsername(String username) throws ApplicationException {
        final String sql =
            "SELECT u.*, r.role_name FROM users u " +
            "JOIN roles r ON u.role_id = r.role_id " +
            "WHERE u.username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByUsername failed", e);
            throw new ApplicationException("Login failed. Please try again.", e);
        }
        return null;
    }

    @Override
    public User findByEmail(String email) throws ApplicationException {
        final String sql =
            "SELECT u.*, r.role_name FROM users u " +
            "JOIN roles r ON u.role_id = r.role_id " +
            "WHERE u.email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findByEmail failed", e);
            throw new ApplicationException("Unable to retrieve user.", e);
        }
        return null;
    }

    @Override
    public List<User> findAll(int offset, int limit) throws ApplicationException {
        final String sql =
            "SELECT u.*, r.role_name FROM users u " +
            "JOIN roles r ON u.role_id = r.role_id " +
            "ORDER BY u.full_name ASC LIMIT ? OFFSET ?";
        List<User> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            ps.setInt(2, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "findAll users failed", e);
            throw new ApplicationException("Unable to retrieve users.", e);
        }
        return list;
    }

    @Override
    public int count() throws ApplicationException {
        final String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "count users failed", e);
            throw new ApplicationException("Unable to count users.", e);
        }
        return 0;
    }

    @Override
    public void update(User user) throws ApplicationException {
        final String sql =
            "UPDATE users SET full_name=?, email=?, phone=?, role_id=? " +
            "WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setInt(4, user.getRoleId());
            ps.setInt(5, user.getUserId());
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "update user failed", e);
            throw new ApplicationException("Unable to update user.", e);
        }
    }

    @Override
    public void updatePassword(int userId, String newHash) throws ApplicationException {
        final String sql = "UPDATE users SET password_hash=? WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newHash);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "updatePassword failed", e);
            throw new ApplicationException("Unable to update password.", e);
        }
    }

    @Override
    public void updateLastLogin(int userId) throws ApplicationException {
        final String sql = "UPDATE users SET last_login=NOW() WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.WARNING, "updateLastLogin failed (non-critical)", e);
            // Non-critical — don't throw
        }
    }

    @Override
    public void deactivate(int userId) throws ApplicationException {
        final String sql = "UPDATE users SET is_active=0 WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "deactivate user failed", e);
            throw new ApplicationException("Unable to deactivate user.", e);
        }
    }

    @Override
    public void activate(int userId) throws ApplicationException {
        final String sql = "UPDATE users SET is_active=1 WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "activate user failed", e);
            throw new ApplicationException("Unable to activate user.", e);
        }
    }

    @Override
    public boolean usernameExists(String username) throws ApplicationException {
        final String sql = "SELECT 1 FROM users WHERE username=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "usernameExists failed", e);
            throw new ApplicationException("Unable to check username.", e);
        }
    }
}
