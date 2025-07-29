part of 'domain_error.dart';

// Test doubles for testing the shared validation interfaces.
// These are only used in tests and should not be used in production code.

/// Test implementation of LengthValidationError for testing the interface.
class TestLengthError extends DomainError implements LengthValidationError {
  /// Creates a test length error with specified parameters.
  const TestLengthError({
    required this.actualLength,
    required this.fieldContext,
    this.maxLength,
    this.minLength,
  });

  @override
  final int actualLength;

  @override
  final int? maxLength;

  @override
  final int? minLength;

  @override
  final String fieldContext;

  @override
  List<Object?> get props => [actualLength, maxLength, minLength, fieldContext];
}

/// Test implementation of FormatValidationError for testing the interface.
class TestFormatError extends DomainError implements FormatValidationError {
  /// Creates a test format error with specified parameters.
  const TestFormatError({
    required this.expectedFormat,
    required this.actualValue,
    required this.fieldContext,
  });

  @override
  final String expectedFormat;

  @override
  final String actualValue;

  @override
  final String fieldContext;

  @override
  List<Object?> get props => [
        expectedFormat,
        actualValue,
        fieldContext,
      ];
}

/// Test implementation of RequiredFieldError for testing the interface.
class TestRequiredError extends DomainError implements RequiredFieldError {
  /// Creates a test required field error with specified parameters.
  const TestRequiredError({
    required this.fieldContext,
    this.providedValue,
  });

  @override
  final String fieldContext;

  @override
  final Object? providedValue;

  @override
  List<Object?> get props => [fieldContext, providedValue];
}
