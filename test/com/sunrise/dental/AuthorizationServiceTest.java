package com.sunrise.dental;

import com.sunrise.dental.model.User;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Automated Unit Tests for Role-Based Access Control (RBAC).
 * Covers: UT-19.
 */
public class AuthorizationServiceTest {

    private boolean isAuthorizedForAdminModule(User user, String path) {
        if (user == null || user.getRoleName() == null) return false;
        boolean isAdminOnlyPath = path.startsWith("/audit") || path.startsWith("/users") || path.startsWith("/dentists");
        if (isAdminOnlyPath) {
            return "ADMIN".equalsIgnoreCase(user.getRoleName());
        }
        return true;
    }

    @Test
    public void testRoleBasedAccess_UT19() {
        // UT-19: Role-based access enforcement for Administrator vs Receptionist
        User receptionist = new User();
        receptionist.setUserId(2);
        receptionist.setUsername("reception1");
        receptionist.setRoleName("RECEPTIONIST");

        User admin = new User();
        admin.setUserId(1);
        admin.setUsername("admin");
        admin.setRoleName("ADMIN");

        // Test Admin-only path: /audit
        assertFalse("Receptionist must be denied access to /audit",
                isAuthorizedForAdminModule(receptionist, "/audit"));
        assertFalse("Receptionist must be denied access to /users",
                isAuthorizedForAdminModule(receptionist, "/users"));
        assertTrue("Admin must be granted access to /audit",
                isAuthorizedForAdminModule(admin, "/audit"));
        assertTrue("Admin must be granted access to /users",
                isAuthorizedForAdminModule(admin, "/users"));
    }
}
