part of 'domain_error.dart';

/// Represents a validation error for a specific field in the domain layer.
///
/// This class is used throughout the domain layer to represent validation
/// failures in a consistent and type-safe manner. It works well with
/// functional error handling patterns using Either types.
class ValidationError extends DomainError {
  /// Creates a validation error with the specified field, value, and message.
  const ValidationError({
    required this.field,
    required this.invalidValue,
    required this.message,
  });

  /// Creates a validation error for a required field that is missing.
  ///
  /// Example:
  /// ```dart
  /// final error = ValidationError.missingRequired('email');
  /// // Results in: ValidationError(field: 'email', invalidValue: null,
  /// //             message: 'email is required')
  /// ```
  factory ValidationError.missingRequired(String field) {
    return ValidationError(
      field: field,
      invalidValue: null,
      message: '$field is required',
    );
  }

  /// Creates a validation error for a field with invalid format.
  ///
  /// Example:
  /// ```dart
  /// final error = ValidationError.invalidFormat(
  ///   field: 'email',
  ///   invalidValue: 'not-an-email',
  ///   expectedFormat: 'valid email address',
  /// );
  /// // Results in: ValidationError(field: 'email',
  /// //             invalidValue: 'not-an-email',
  /// //             message: 'email must be a valid email address')
  /// ```
  factory ValidationError.invalidFormat({
    required String field,
    required Object? invalidValue,
    required String expectedFormat,
  }) {
    return ValidationError(
      field: field,
      invalidValue: invalidValue,
      message: '$field must be a $expectedFormat',
    );
  }

  /// Creates a validation error for a field with invalid length.
  ///
  /// Example:
  /// ```dart
  /// final error = ValidationError.invalidLength(
  ///   field: 'username',
  ///   invalidValue: 'ab',
  ///   minLength: 3,
  ///   maxLength: 20,
  /// );
  /// // Results in: ValidationError(field: 'username', invalidValue: 'ab',
  /// //             message: 'username must be between 3 and 20 characters')
  /// ```
  factory ValidationError.invalidLength({
    required String field,
    required Object? invalidValue,
    int? minLength,
    int? maxLength,
  }) {
    String message;
    if (minLength != null && maxLength != null) {
      message = '$field must be between $minLength and $maxLength characters';
    } else if (minLength != null) {
      message = '$field must be at least $minLength characters';
    } else if (maxLength != null) {
      message = '$field must be at most $maxLength characters';
    } else {
      throw ArgumentError(
        'At least one of minLength or maxLength must be provided',
      );
    }

    return ValidationError(
      field: field,
      invalidValue: invalidValue,
      message: message,
    );
  }

  /// Creates a validation error for a numeric field that is out of range.
  ///
  /// Example:
  /// ```dart
  /// final error = ValidationError.outOfRange(
  ///   field: 'age',
  ///   invalidValue: 150,
  ///   min: 0,
  ///   max: 120,
  /// );
  /// // Results in: ValidationError(field: 'age', invalidValue: 150,
  /// //             message: 'age must be between 0 and 120')
  /// ```
  factory ValidationError.outOfRange({
    required String field,
    required num invalidValue,
    num? min,
    num? max,
  }) {
    String message;
    if (min != null && max != null) {
      message = '$field must be between $min and $max';
    } else if (min != null) {
      message = '$field must be at least $min';
    } else if (max != null) {
      message = '$field must be at most $max';
    } else {
      throw ArgumentError('At least one of min or max must be provided');
    }

    return ValidationError(
      field: field,
      invalidValue: invalidValue,
      message: message,
    );
  }

  /// Creates a validation error for an invalid stock symbol.
  /// Stock symbols must be 1-5 uppercase letters.
  factory ValidationError.invalidStockSymbol({
    required String field,
    required String invalidValue,
  }) {
    return ValidationError(
      field: field,
      invalidValue: invalidValue,
      message: 'Stock symbol must be 1-5 uppercase letters',
    );
  }

  /// Creates a validation error for a percentage value outside 0-100 range.
  factory ValidationError.invalidPercentage({
    required String field,
    required num invalidValue,
  }) {
    return ValidationError(
      field: field,
      invalidValue: invalidValue,
      message: '$field must be between 0 and 100',
    );
  }

  /// Creates a validation error for a negative or zero price.
  factory ValidationError.invalidPrice({
    required String field,
    required num invalidValue,
  }) {
    return ValidationError(
      field: field,
      invalidValue: invalidValue,
      message: '$field must be a positive number',
    );
  }

  /// Creates a validation error for an invalid quantity
  /// (must be positive integer).
  factory ValidationError.invalidQuantity({
    required String field,
    required num invalidValue,
  }) {
    return ValidationError(
      field: field,
      invalidValue: invalidValue,
      message: '$field must be a positive integer',
    );
  }

  /// The field that failed validation.
  final String field;

  /// The invalid value that was provided.
  final Object? invalidValue;

  /// A descriptive error message.
  final String message;

  @override
  List<Object?> get props => [field, invalidValue, message];

  @override
  String toString() {
    return 'ValidationError(field: $field, '
        'invalidValue: $invalidValue, message: $message)';
  }
}

/// A collection of validation errors, typically used when validating
/// complex domain objects that may have multiple validation failures.
class ValidationErrors extends Equatable {
  /// Creates a collection of validation errors.
  const ValidationErrors(this._errors);

  /// The list of validation errors (read-only).
  final List<ValidationError> _errors;

  /// The list of validation errors.
  List<ValidationError> get errors => List.unmodifiable(_errors);

  /// Returns true if there are any validation errors.
  bool get hasErrors => _errors.isNotEmpty;

  /// Returns true if there are no validation errors.
  bool get isEmpty => _errors.isEmpty;

  /// Creates a new ValidationErrors instance with an additional error.
  ValidationErrors add(ValidationError error) {
    return ValidationErrors([..._errors, error]);
  }

  /// Creates a new ValidationErrors instance with additional errors.
  ValidationErrors addAll(List<ValidationError> newErrors) {
    return ValidationErrors([..._errors, ...newErrors]);
  }

  /// Returns all errors for a specific field.
  List<ValidationError> getErrorsForField(String field) {
    return _errors.where((error) => error.field == field).toList();
  }

  @override
  List<Object?> get props => [_errors];

  @override
  String toString() {
    final buffer = StringBuffer('ValidationErrors(${_errors.length} errors)');
    if (_errors.isNotEmpty) {
      buffer.write(': [');
      for (var i = 0; i < _errors.length; i++) {
        if (i > 0) buffer.write(', ');
        buffer.write(_errors[i].toString());
      }
      buffer.write(']');
    }
    return buffer.toString();
  }
}
