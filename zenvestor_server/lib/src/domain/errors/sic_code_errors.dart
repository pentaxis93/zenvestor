part of 'domain_error.dart';

/// Base class for all SIC code validation errors.
///
/// This abstract class serves as the root of the SIC code error hierarchy,
/// enabling type-safe error handling specific to SIC code validation while
/// extending the general [DomainError] framework.
///
/// All specific SIC code validation errors should extend this class.
abstract class SicCodeError extends DomainError {
  /// Creates a SIC code error.
  const SicCodeError();

  /// A human-readable error message.
  String get message;
}

/// Error indicating that a SIC code is empty or contains only whitespace.
///
/// This error is returned when:
/// - The input is null
/// - The input is an empty string
/// - The input contains only whitespace characters
class SicCodeEmpty extends SicCodeError implements RequiredFieldError {
  /// Creates an error for an empty SIC code.
  ///
  /// [providedValue] is the original input that was empty or whitespace.
  const SicCodeEmpty([this.providedValue]);

  @override
  final Object? providedValue;

  @override
  String get fieldContext => 'SIC code';

  @override
  String get message => 'SIC code is required';

  @override
  List<Object?> get props => [providedValue];

  @override
  String toString() => 'SicCodeEmpty(providedValue: $providedValue)';
}

/// Error indicating that a SIC code has invalid length.
///
/// SIC codes must be exactly 4 digits long. This error is returned when
/// the normalized input has a different length.
class SicCodeInvalidLength extends SicCodeError
    implements LengthValidationError {
  /// Creates an error for a SIC code with invalid length.
  ///
  /// [actualLength] is the length of the trimmed SIC code.
  const SicCodeInvalidLength(this.actualLength);

  @override
  final int actualLength;

  @override
  int? get maxLength => 4;

  @override
  int? get minLength => 4;

  @override
  String get fieldContext => 'SIC code';

  @override
  String get message => 'SIC code must be exactly 4 digits (was $actualLength)';

  @override
  List<Object?> get props => [actualLength];

  @override
  String toString() => 'SicCodeInvalidLength(actualLength: $actualLength)';
}

/// Error indicating that a SIC code contains invalid characters.
///
/// SIC codes must contain only numeric digits (0-9). This error is
/// returned when the input contains:
/// - Letters
/// - Special characters
/// - Spaces or other whitespace (after trimming)
class SicCodeInvalidFormat extends SicCodeError
    implements FormatValidationError {
  /// Creates an error for a SIC code with invalid format.
  ///
  /// [actualValue] is the invalid SIC code value after trimming.
  const SicCodeInvalidFormat(this.actualValue);

  @override
  final String actualValue;

  @override
  String get expectedFormat => '4 numeric digits';

  @override
  String get fieldContext => 'SIC code';

  @override
  String get message => 'SIC code must contain only numeric digits';

  @override
  List<Object?> get props => [actualValue];

  @override
  String toString() => 'SicCodeInvalidFormat(actualValue: $actualValue)';
}

/// Error indicating that a SIC code is outside the valid range.
///
/// SIC codes must be between 0100 and 9999. This error is returned when
/// the code is outside this range, even if it has the correct format.
class SicCodeOutOfRange extends SicCodeError {
  /// Creates an error for a SIC code outside the valid range.
  ///
  /// [actualValue] is the SIC code that is out of range.
  const SicCodeOutOfRange(this.actualValue);

  /// The SIC code value that is out of range.
  final String actualValue;

  @override
  String get message => 'SIC code must be between 0100 and 9999';

  @override
  List<Object?> get props => [actualValue];

  @override
  String toString() => 'SicCodeOutOfRange(actualValue: $actualValue)';
}
