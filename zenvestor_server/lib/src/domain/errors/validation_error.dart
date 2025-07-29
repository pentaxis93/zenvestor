part of 'domain_error.dart';

/// Represents a validation error for a specific field in the domain layer.
///
/// This class is used throughout the domain layer to represent validation
/// failures in a consistent and type-safe manner. It works well with
/// functional error handling patterns using Either types.
///
/// @deprecated Use specific error hierarchies for each value object instead.
/// For example, use TickerSymbolError for ticker validation, CompanyNameError
/// for company name validation, etc. This provides better type safety and
/// more expressive domain modeling.
@Deprecated(
  'Use specific error hierarchies for each value object. '
  'See TickerSymbolError and CompanyNameError for examples.',
)
class ValidationError extends DomainError {
  /// Creates a validation error with the specified field, value, and message.
  @Deprecated(
    'Use specific error hierarchies for each value object. '
    'See TickerSymbolError and CompanyNameError for examples.',
  )
  const ValidationError({
    required this.field,
    required this.invalidValue,
    required this.message,
  });

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
///
/// @deprecated Consider using specific error types and Either for single
/// validation failures, or create domain-specific error aggregation types
/// as needed. The generic ValidationError is being phased out in favor of
/// more expressive, type-safe error hierarchies.
@Deprecated(
  'Consider using specific error types with Either for validation. '
  'Create domain-specific error aggregation types if needed.',
)
class ValidationErrors extends Equatable {
  /// Creates a collection of validation errors.
  @Deprecated(
    'Consider using specific error types with Either for validation. '
    'Create domain-specific error aggregation types if needed.',
  )
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
