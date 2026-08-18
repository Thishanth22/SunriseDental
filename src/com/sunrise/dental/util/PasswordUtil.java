package com.sunrise.dental.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * PasswordUtil — Secure password hashing using BCrypt.
 *
 * BCrypt automatically generates a salt and embeds it in the hash,
 * so we never need to store a separate salt column.
 *
 * Cost factor 12 is a good balance between security and performance
 * on modern hardware (~300ms per hash).
 *
 * IMPORTANT: Never store plain-text passwords anywhere in the system.
 */
public final class PasswordUtil {

    private static final int BCRYPT_COST = 12;

    // Private constructor — utility class
    private PasswordUtil() {}

    /**
     * Hash a plain-text password using BCrypt.
     *
     * @param plainPassword Raw password from user input
     * @return  BCrypt hash to store in the database
     */
    public static String hash(String plainPassword) {
        if (plainPassword == null || plainPassword.isEmpty()) {
            throw new IllegalArgumentException("Password must not be empty.");
        }
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(BCRYPT_COST));
    }

    /**
     * Verify a plain-text password against a BCrypt hash.
     *
     * @param plainPassword  Password supplied by user at login
     * @param hashedPassword Hash retrieved from database
     * @return true if the password matches, false otherwise
     */
    public static boolean verify(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null) {
            return false;
        }
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (IllegalArgumentException e) {
            // Handles malformed hashes gracefully (no crash, just fail)
            return false;
        }
    }

    /**
     * Checks whether a plain password meets complexity requirements:
     *   - Minimum 8 characters
     *   - At least one uppercase letter
     *   - At least one lowercase letter
     *   - At least one digit
     *
     * @param password password to validate
     * @return true if password meets policy
     */
    public static boolean meetsPolicy(String password) {
        if (password == null || password.length() < 8) return false;
        boolean hasUpper  = password.chars().anyMatch(Character::isUpperCase);
        boolean hasLower  = password.chars().anyMatch(Character::isLowerCase);
        boolean hasDigit  = password.chars().anyMatch(Character::isDigit);
        return hasUpper && hasLower && hasDigit;
    }
}
