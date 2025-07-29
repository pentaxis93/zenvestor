part of 'domain_error.dart';

/// Base class for all grade validation errors.
///
/// This abstract class serves as the root of the grade error hierarchy,
/// enabling type-safe error handling specific to grade validation while
/// extending the general [DomainError] framework.
///
/// All specific grade validation errors should extend this class.
abstract class GradeError extends DomainError {
  /// Creates a grade error.
  const GradeError();

  /// A human-readable error message.
  String get message;
}

/// Error indicating that a grade is empty or contains only whitespace.
///
/// This error is returned when:
/// - The input is an empty string
/// - The input contains only whitespace characters
class GradeEmpty extends GradeError implements RequiredFieldError {
  /// Creates an error for an empty grade.
  ///
  /// [providedValue] is the original input that was empty or whitespace.
  const GradeEmpty([this.providedValue]);

  @override
  final Object? providedValue;

  @override
  String get fieldContext => 'grade';

  @override
  String get message => 'Grade cannot be empty';

  @override
  List<Object?> get props => [providedValue];

  @override
  String toString() => 'GradeEmpty(providedValue: $providedValue)';
}

/// Error indicating that a grade contains an invalid value.
///
/// Grades must be exactly one of: A, B, C, D, or F. This error is
/// returned when the input contains:
/// - Invalid letters (E, G, etc.)
/// - Grade modifiers (A+, B-, etc.)
/// - Numbers
/// - Special characters
/// - Multiple characters
class GradeInvalidValue extends GradeError implements FormatValidationError {
  /// Creates an error for a grade with invalid value.
  ///
  /// [actualValue] is the invalid grade value provided.
  const GradeInvalidValue(this.actualValue);

  @override
  final String actualValue;

  @override
  String get expectedFormat => 'A, B, C, D, or F';

  @override
  String get fieldContext => 'grade';

  @override
  String get message => 'Grade must be A, B, C, D, or F';

  @override
  List<Object?> get props => [actualValue];

  @override
  String toString() => 'GradeInvalidValue(actualValue: $actualValue)';
}
