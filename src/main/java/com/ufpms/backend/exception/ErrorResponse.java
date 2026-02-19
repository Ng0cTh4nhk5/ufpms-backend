package com.ufpms.backend.exception;

import lombok.Getter;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * Standard error response body returned by GlobalExceptionHandler.
 */
@Getter
public class ErrorResponse {

    private final int status;
    private final String message;
    private final LocalDateTime timestamp;
    private Map<String, String> errors;

    public ErrorResponse(int status, String message) {
        this.status = status;
        this.message = message;
        this.timestamp = LocalDateTime.now();
    }

    public ErrorResponse(int status, String message, Map<String, String> errors) {
        this(status, message);
        this.errors = errors;
    }
}
