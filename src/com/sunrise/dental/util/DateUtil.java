package com.sunrise.dental.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

/**
 * DateUtil — Centralised date/time parsing and formatting helpers.
 *
 * Keeps all date-format knowledge in one place so that changing
 * a display format only requires editing this class.
 */
public final class DateUtil {

    // Formats used in forms and display
    public static final DateTimeFormatter DATE_FORM    = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    public static final DateTimeFormatter DATE_DISPLAY = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    public static final DateTimeFormatter TIME_FORM    = DateTimeFormatter.ofPattern("HH:mm");
    public static final DateTimeFormatter TIME_DISPLAY = DateTimeFormatter.ofPattern("hh:mm a");
    public static final DateTimeFormatter DT_DISPLAY   = DateTimeFormatter.ofPattern("dd/MM/yyyy hh:mm a");

    private DateUtil() {}

    // -------------------------------------------------------
    // Parsing helpers
    // -------------------------------------------------------

    public static LocalDate parseDate(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try {
            return LocalDate.parse(s.trim(), DATE_FORM);
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    public static LocalTime parseTime(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        String trimmed = s.trim();
        try {
            if (trimmed.length() == 5) {
                return LocalTime.parse(trimmed, TIME_FORM);
            }
            return LocalTime.parse(trimmed);
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    // -------------------------------------------------------
    // Formatting helpers
    // -------------------------------------------------------

    public static String formatDate(LocalDate d) {
        return d == null ? "" : d.format(DATE_DISPLAY);
    }

    public static String formatDateForm(LocalDate d) {
        return d == null ? "" : d.format(DATE_FORM);
    }

    public static String formatTime(LocalTime t) {
        return t == null ? "" : t.format(TIME_DISPLAY);
    }

    public static String formatDateTime(LocalDateTime dt) {
        return dt == null ? "" : dt.format(DT_DISPLAY);
    }

    // -------------------------------------------------------
    // Business rule helpers
    // -------------------------------------------------------

    /** True if the date is today or in the future. */
    public static boolean isTodayOrFuture(LocalDate d) {
        return d != null && !d.isBefore(LocalDate.now());
    }

    /** True if the date is strictly in the future. */
    public static boolean isFuture(LocalDate d) {
        return d != null && d.isAfter(LocalDate.now());
    }

    /** Returns today's date string in yyyy-MM-dd format (for HTML min attribute). */
    public static String todayString() {
        return LocalDate.now().format(DATE_FORM);
    }

    /** Returns current year as int. */
    public static int currentYear() {
        return LocalDate.now().getYear();
    }
}
