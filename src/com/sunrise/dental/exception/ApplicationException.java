package com.sunrise.dental.exception;

/**
 * Application-level checked exception.
 * Wraps low-level exceptions (SQLException, etc.) so that
 * service/servlet layers never need to import java.sql.
 */
public class ApplicationException extends Exception {

    private static final long serialVersionUID = 1L;

    private final int errorCode;   // optional application error code

    public ApplicationException(String message) {
        super(message);
        this.errorCode = 0;
    }

    public ApplicationException(String message, Throwable cause) {
        super(message, cause);
        this.errorCode = 0;
    }

    public ApplicationException(int errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public ApplicationException(int errorCode, String message, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
    }

    public int getErrorCode() {
        return errorCode;
    }
}
