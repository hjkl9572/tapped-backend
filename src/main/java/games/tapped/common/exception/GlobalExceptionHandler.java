package games.tapped.common.exception;

import jakarta.persistence.EntityNotFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<Map<String, String>> handleNotFound(
            EntityNotFoundException exception
    ) {
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(Map.of(
                        "error", "NOT_FOUND",
                        "message", Objects.requireNonNullElse(
                                exception.getMessage(),
                                "Resource not found"
                        )
                ));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<Map<String, String>> handleAccessDenied(
            AccessDeniedException exception
    ) {
        return ResponseEntity
                .status(HttpStatus.FORBIDDEN)
                .body(Map.of(
                        "error", "FORBIDDEN",
                        "message", exception.getMessage()
                ));
    }

    @ExceptionHandler(DomainConflictException.class)
    public ResponseEntity<Map<String, String>> handleConflict(
            DomainConflictException exception
    ) {
        return ResponseEntity
                .status(HttpStatus.CONFLICT)
                .body(Map.of(
                        "error", "CONFLICT",
                        "message", exception.getMessage()
                ));
    }

    @ExceptionHandler(UnprocessableOperationException.class)
    public ResponseEntity<Map<String, String>> handleUnprocessableOperation(
            UnprocessableOperationException exception
    ) {
        return ResponseEntity
                .unprocessableEntity()
                .body(Map.of(
                        "error", "UNPROCESSABLE_ENTITY",
                        "message", exception.getMessage()
                ));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleBadRequest(
            IllegalArgumentException exception
    ) {
        return ResponseEntity
                .badRequest()
                .body(Map.of(
                        "error", "BAD_REQUEST",
                        "message", Objects.requireNonNullElse(
                                exception.getMessage(),
                                "Invalid request"
                        )
                ));
    }

    @ExceptionHandler({
            HttpMessageNotReadableException.class,
            MethodArgumentTypeMismatchException.class,
            HttpMediaTypeNotSupportedException.class
    })
    public ResponseEntity<Map<String, String>> handleMalformedRequest(
            Exception exception
    ) {
        return ResponseEntity
                .badRequest()
                .body(Map.of(
                        "error", "BAD_REQUEST",
                        "message", "Invalid request"
                ));
    }

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<Map<String, String>> handleResponseStatus(
            ResponseStatusException exception
    ) {
        return ResponseEntity
                .status(exception.getStatusCode())
                .body(Map.of(
                        "error", exception.getStatusCode().toString(),
                        "message", Objects.requireNonNullElse(
                                exception.getReason(),
                                "Request failed"
                        )
                ));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidation(
            MethodArgumentNotValidException exception
    ) {
        Map<String, String> fields = exception
                .getBindingResult()
                .getFieldErrors()
                .stream()
                .collect(Collectors.toMap(
                        FieldError::getField,
                        error -> Objects.requireNonNullElse(
                                error.getDefaultMessage(),
                                "Invalid value"
                        ),
                        (first, second) -> first
                ));

        return ResponseEntity
                .badRequest()
                .body(Map.of(
                        "error", "VALIDATION_FAILED",
                        "fields", fields
                ));
    }
}
