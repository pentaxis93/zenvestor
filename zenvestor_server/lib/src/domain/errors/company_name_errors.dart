part of 'domain_error.dart';

/// Base class for all company name validation errors.
///
/// This abstract class serves as the root of the company name error hierarchy,
/// enabling type-safe error handling specific to company name validation while
/// extending the general [DomainError] framework.
///
/// All specific company name validation errors should extend this class.
abstract class CompanyNameError extends DomainError {
  /// Creates a company name error.
  const CompanyNameError();

  /// A human-readable error message.
  String get message;
}

/// Error indicating that a company name is empty or contains only whitespace.
///
/// This error is returned when:
/// - The input is null
/// - The input is an empty string
/// - The input contains only whitespace characters
class CompanyNameEmpty extends CompanyNameError implements RequiredFieldError {
  /// Creates an error for an empty company name.
  ///
  /// [providedValue] is the original input that was empty or whitespace.
  const CompanyNameEmpty([this.providedValue]);

  @override
  final Object? providedValue;

  @override
  String get fieldContext => 'company name';

  @override
  String get message => 'Company name cannot be empty';

  @override
  List<Object?> get props => [providedValue];

  @override
  String toString() => 'CompanyNameEmpty(providedValue: $providedValue)';
}

/// Error indicating that a company name exceeds the maximum allowed length.
///
/// Company names have a maximum length of 255 characters to ensure
/// compatibility
/// with database storage and display constraints. This error is returned when
/// the normalized input exceeds this limit.
class CompanyNameTooLong extends CompanyNameError
    implements LengthValidationError {
  /// Creates an error for a company name that is too long.
  ///
  /// [actualLength] is the length of the normalized company name.
  const CompanyNameTooLong(this.actualLength);

  @override
  final int actualLength;

  @override
  int? get maxLength => 255;

  @override
  int? get minLength => 1;

  @override
  String get fieldContext => 'company name';

  @override
  String get message =>
      'Company name must be at most 255 characters (was $actualLength)';

  @override
  List<Object?> get props => [actualLength];

  @override
  String toString() => 'CompanyNameTooLong(actualLength: $actualLength)';
}

/// Error indicating that a company name is too short.
///
/// Company names must be at least 1 character after normalization.
/// This typically occurs when a name consists only of whitespace or
/// special characters that are removed during normalization.
class CompanyNameTooShort extends CompanyNameError
    implements LengthValidationError {
  /// Creates an error for a company name that is too short.
  const CompanyNameTooShort();

  @override
  int get actualLength => 0;

  @override
  int? get maxLength => 255;

  @override
  int? get minLength => 1;

  @override
  String get fieldContext => 'company name';

  @override
  String get message => 'Company name must be at least 1 character';

  @override
  List<Object?> get props => [];

  @override
  String toString() => 'CompanyNameTooShort()';
}

/// Error indicating that a company name contains invalid characters.
///
/// Company names must contain only allowed business characters:
/// - Letters (a-z, A-Z)
/// - Numbers (0-9)
/// - Spaces
/// - Business punctuation: . , ' - & ( )
///
/// This error is returned when the input contains characters outside
/// this allowed set.
class CompanyNameInvalidCharacters extends CompanyNameError
    implements FormatValidationError {
  /// Creates an error for a company name with invalid characters.
  ///
  /// [actualValue] is the company name containing invalid characters.
  const CompanyNameInvalidCharacters(this.actualValue);

  @override
  final String actualValue;

  @override
  String get expectedFormat =>
      "letters, numbers, spaces, and business punctuation (.,'-&())";

  @override
  String get fieldContext => 'company name';

  @override
  String get message =>
      'Company name contains invalid characters. Only letters, numbers, '
      "spaces, and business punctuation (.,'-&()) are allowed";

  @override
  List<Object?> get props => [actualValue];

  @override
  String toString() =>
      'CompanyNameInvalidCharacters(actualValue: $actualValue)';
}

/// Error indicating that a company name lacks any alphanumeric characters.
///
/// Company names must contain at least one letter or number. This prevents
/// names that consist only of punctuation or special characters, which would
/// not be meaningful business names.
class CompanyNameNoAlphanumeric extends CompanyNameError
    implements FormatValidationError {
  /// Creates an error for a company name without alphanumeric characters.
  ///
  /// [actualValue] is the company name lacking alphanumeric characters.
  const CompanyNameNoAlphanumeric(this.actualValue);

  @override
  final String actualValue;

  @override
  String get expectedFormat => 'at least one letter or number';

  @override
  String get fieldContext => 'company name';

  @override
  String get message =>
      'Company name must contain at least one alphanumeric character';

  @override
  List<Object?> get props => [actualValue];

  @override
  String toString() => 'CompanyNameNoAlphanumeric(actualValue: $actualValue)';
}
