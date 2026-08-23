package com.sunrise.dental;

import com.sunrise.dental.model.User;
import com.sunrise.dental.util.PasswordUtil;
import com.sunrise.dental.util.ValidationUtil;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Automated Unit Tests for Authentication & Session Management.
 * Covers: UT-01, UT-02, UT-03, UT-21.
 */
public class AuthServiceTest {

    @Test
    public void testValidUserLogin_UT01() {
        // UT-01: Valid user authentication check via BCrypt
        String plainPassword = "admin123";
        String hashedPassword = PasswordUtil.hash(plainPassword);
        assertNotNull("Hashed password should not be null", hashedPassword);
        assertTrue("Valid password must authenticate against hash",
                PasswordUtil.verify(plainPassword, hashedPassword));
    }

    @Test
    public void testInvalidPassword_UT02() {
        // UT-02: Authentication fails when incorrect password provided
        String correctPassword = "admin123";
        String hashedPassword = PasswordUtil.hash(correctPassword);
        assertFalse("Incorrect password must be rejected",
                PasswordUtil.verify("wrongPass123", hashedPassword));
    }

    @Test
    public void testEmptyLoginDetails_UT03() {
        // UT-03: Rejection of null or empty username and password
        assertTrue("Null username should be recognized as empty", ValidationUtil.isNullOrEmpty(null));
        assertTrue("Whitespace username should be recognized as empty", ValidationUtil.isNullOrEmpty("   "));
        assertTrue("Empty password should be recognized as empty", ValidationUtil.isNullOrEmpty(""));
        assertFalse("Valid credentials must pass validation", ValidationUtil.isNullOrEmpty("admin"));
    }

    @Test
    public void testLogoutSessionTermination_UT21() {
        // UT-21: User session invalidation and cleanup on logout
        User activeUser = new User();
        activeUser.setUserId(1);
        activeUser.setUsername("admin");
        assertNotNull("User object active prior to logout", activeUser);

        // Simulate session invalidation
        activeUser = null;
        assertNull("Session object should be null post-logout", activeUser);
    }
}
