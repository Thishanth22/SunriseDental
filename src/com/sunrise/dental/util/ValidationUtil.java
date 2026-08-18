package com.sunrise.dental.util;

import java.util.regex.Pattern;

/**
 * ValidationUtil — Server-side input validation helpers.
 *
 * Security note: Client-side JS validation is for UX only.
 * This class enforces the same rules on the server where they
 * cannot be bypassed by disabling JavaScript.
 */
public final class ValidationUtil {

    // -------------------------------------------------------
    // Sri Lankan phone: 07XXXXXXXX or +947XXXXXXXX or 0094XXXXXXXXX
    // -------------------------------------------------------
    private static final Pattern PHONE_LK = Pattern.compile(
            "^(\\+94|0094)?0?[1-9][0-9]{8}$"
    );

    // Standard email pattern
    private static final Pattern EMAIL = Pattern.compile(
            "^[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}$"
    );

    // Names: letters, spaces, hyphens, apostrophes
    private static final Pattern NAME = Pattern.compile(
            "^[A-Za-z\\s'\\-\\.]{2,100}$"
    );

    // Alphanumeric + basic punctuation (for notes/descriptions)
    private static final Pattern SAFE_TEXT = Pattern.compile(
            "^[A-Za-z0-9\\s,\\.\\-_/()&%@#!?'\":;\\+\\n\\r]{0,2000}$"
    );

    private ValidationUtil() {}

    // -------------------------------------------------------
    // Null / empty
    // -------------------------------------------------------

    public static boolean isNullOrEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }

    public static boolean hasValue(String s) {
        return !isNullOrEmpty(s);
    }

    // -------------------------------------------------------
    // Length
    // -------------------------------------------------------

    public static boolean withinLength(String s, int max) {
        return s != null && s.length() <= max;
    }

    public static boolean withinLength(String s, int min, int max) {
        return s != null && s.length() >= min && s.length() <= max;
    }

    // -------------------------------------------------------
    // Phone (Sri Lanka)
    // -------------------------------------------------------

    /**
     * Validates Sri Lankan mobile/landline numbers.
     * Accepted formats: 0711234567, +94711234567, 0094711234567
     */
    public static boolean isValidPhoneLK(String phone) {
        if (isNullOrEmpty(phone)) return false;
        String cleaned = phone.replaceAll("[\\s\\-()]", "");
        return PHONE_LK.matcher(cleaned).matches();
    }

    // -------------------------------------------------------
    // Email
    // -------------------------------------------------------

    public static boolean isValidEmail(String email) {
        if (isNullOrEmpty(email)) return false;
        return EMAIL.matcher(email.trim()).matches() && email.length() <= 100;
    }

    // -------------------------------------------------------
    // Name
    // -------------------------------------------------------

    public static boolean isValidName(String name) {
        if (isNullOrEmpty(name)) return false;
        return NAME.matcher(name.trim()).matches();
    }

    // -------------------------------------------------------
    // Numbers
    // -------------------------------------------------------

    public static boolean isPositiveDecimal(String s) {
        if (isNullOrEmpty(s)) return false;
        try {
            double v = Double.parseDouble(s.trim());
            return v >= 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    public static boolean isPositiveInt(String s) {
        if (isNullOrEmpty(s)) return false;
        try {
            int v = Integer.parseInt(s.trim());
            return v > 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    // -------------------------------------------------------
    // XSS — basic HTML encoding for output
    // -------------------------------------------------------

    /**
     * Escapes HTML special characters to prevent XSS.
     * Use this before writing untrusted data into HTML output.
     * (JSTL's <c:out> does this automatically, but this is
     * available for non-JSTL contexts.)
     */
    public static String escapeHtml(String input) {
        if (input == null) return "";
        return input
                .replace("&",  "&amp;")
                .replace("<",  "&lt;")
                .replace(">",  "&gt;")
                .replace("\"", "&quot;")
                .replace("'",  "&#x27;");
    }

    /**
     * Strips script tags and event handlers from a string.
     * Additional defence-in-depth beyond HTML escaping.
     */
    public static String sanitize(String input) {
        if (input == null) return null;
        // Remove script tags (case-insensitive)
        String clean = input.replaceAll("(?i)<script[^>]*>.*?</script>", "");
        // Remove on* event attributes
        clean = clean.replaceAll("(?i)\\bon\\w+\\s*=", "");
        return clean.trim();
    }

    // -------------------------------------------------------
    // Enum/domain value checks
    // -------------------------------------------------------

    public static boolean isValidGender(String gender) {
        return "MALE".equals(gender) || "FEMALE".equals(gender) || "OTHER".equals(gender);
    }

    public static boolean isValidAppointmentStatus(String status) {
        return status != null && status.matches(
                "SCHEDULED|CONFIRMED|COMPLETED|CANCELLED|NO_SHOW|RESCHEDULED");
    }

    public static boolean isValidPaymentMethod(String method) {
        return method != null && method.matches(
                "CASH|CARD|BANK_TRANSFER|ONLINE|CHEQUE");
    }

    public static boolean isValidRole(String role) {
        return "ADMIN".equals(role) || "RECEPTIONIST".equals(role) || "DENTIST".equals(role);
    }
}
