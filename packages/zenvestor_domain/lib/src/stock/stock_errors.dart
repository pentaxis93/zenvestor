import '../shared/errors/domain_error.dart';
import '../shared/errors/validation_errors.dart';

// This file consolidates all stock-related domain errors.
// These errors represent various failure conditions that can occur
// when working with stock entities and their associated value objects.

// ============================================================================
// Ticker Symbol Errors
// ============================================================================

/// Base class for all ticker symbol validation errors.
///
/// This abstract class serves as the root of the ticker symbol error hierarchy,
/// enabling type-safe error handling specific to ticker symbol validation while
/// extending the general [DomainError] framework.
///
/// All specific ticker symbol validation errors should extend this class.
sealed class TickerSymbolError extends DomainError {
  /// Creates a ticker symbol error.
  const TickerSymbolError();

  /// A human-readable error message.
  String get message;
}

/// Error indicating that a ticker symbol is empty or contains only whitespace.
///
/// This error is returned when:
/// - The input is null
/// - The input is an empty string
/// - The input contains only whitespace characters
class TickerSymbolEmpty extends TickerSymbolError
    implements RequiredFieldError {
  /// Creates an error for an empty ticker symbol.
  ///
  /// [providedValue] is the original input that was empty or whitespace.
  const TickerSymbolEmpty([this.providedValue]);

  @override
  final Object? providedValue;

  @override
  String get fieldContext => 'ticker symbol';

  @override
  String get message => 'Ticker symbol is required';

  @override
  List<Object?> get props => [providedValue];

  @override
  String toString() => 'TickerSymbolEmpty(providedValue: $providedValue)';
}

/// Error indicating that a ticker symbol exceeds the maximum allowed length.
///
/// Stock ticker symbols have a maximum length of 5 characters according to
/// standard market conventions. This error is returned when the normalized
/// input exceeds this limit.
class TickerSymbolTooLong extends TickerSymbolError
    implements LengthValidationError {
  /// Creates an error for a ticker symbol that is too long.
  ///
  /// [actualLength] is the length of the normalized ticker symbol.
  const TickerSymbolTooLong(this.actualLength);

  @override
  final int actualLength;

  @override
  int? get maxLength => 5;

  @override
  int? get minLength => 1;

  @override
  String get fieldContext => 'ticker symbol';

  @override
  String get message =>
      'Ticker symbol must be at most 5 characters (was $actualLength)';

  @override
  List<Object?> get props => [actualLength];

  @override
  String toString() => 'TickerSymbolTooLong(actualLength: $actualLength)';
}

/// Error indicating that a ticker symbol is too short
/// (empty after normalization).
///
/// While this might seem redundant with [TickerSymbolEmpty], this error
/// specifically handles cases where input was provided but resulted in an
/// empty string after normalization (e.g., symbols with only invalid characters
/// that get stripped out).
class TickerSymbolTooShort extends TickerSymbolError
    implements LengthValidationError {
  /// Creates an error for a ticker symbol that is too short.
  const TickerSymbolTooShort();

  @override
  int get actualLength => 0;

  @override
  int? get maxLength => 5;

  @override
  int? get minLength => 1;

  @override
  String get fieldContext => 'ticker symbol';

  @override
  String get message => 'Ticker symbol must be at least 1 character';

  @override
  List<Object?> get props => [];

  @override
  String toString() => 'TickerSymbolTooShort()';
}

/// Error indicating that a ticker symbol contains invalid characters.
///
/// Ticker symbols must contain only uppercase letters (A-Z). This error is
/// returned when the input contains:
/// - Numbers
/// - Special characters
/// - Lowercase letters (though these are typically normalized to uppercase)
/// - Spaces or other whitespace
class TickerSymbolInvalidFormat extends TickerSymbolError
    implements FormatValidationError {
  /// Creates an error for a ticker symbol with invalid format.
  ///
  /// [actualValue] is the invalid ticker symbol value.
  const TickerSymbolInvalidFormat(this.actualValue);

  @override
  final String actualValue;

  @override
  String get expectedFormat => '1-5 uppercase letters (A-Z only)';

  @override
  String get fieldContext => 'ticker symbol';

  @override
  String get message => 'Ticker symbol must contain only uppercase letters A-Z';

  @override
  List<Object?> get props => [actualValue];

  @override
  String toString() => 'TickerSymbolInvalidFormat(actualValue: $actualValue)';
}

// ============================================================================
// Company Name Errors
// ============================================================================

/// Base class for all company name validation errors.
///
/// This abstract class serves as the root of the company name error hierarchy,
/// enabling type-safe error handling specific to company name validation while
/// extending the general [DomainError] framework.
///
/// All specific company name validation errors should extend this class.
sealed class CompanyNameError extends DomainError {
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

// ============================================================================
// SIC Code Errors
// ============================================================================

/// Base class for all SIC code validation errors.
///
/// This abstract class serves as the root of the SIC code error hierarchy,
/// enabling type-safe error handling specific to SIC code validation while
/// extending the general [DomainError] framework.
///
/// All specific SIC code validation errors should extend this class.
sealed class SicCodeError extends DomainError {
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

// ============================================================================
// Grade Errors
// ============================================================================

/// Base class for all grade validation errors.
///
/// This abstract class serves as the root of the grade error hierarchy,
/// enabling type-safe error handling specific to grade validation while
/// extending the general [DomainError] framework.
///
/// All specific grade validation errors should extend this class.
sealed class GradeError extends DomainError {
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

// ============================================================================
// Stock Entity Errors
// ============================================================================

/// Base class for all stock-related domain errors.
sealed class StockError extends DomainError {
  /// Creates a [StockError].
  const StockError();
}

/// Error thrown when a stock ID is invalid.
class StockInvalidId extends StockError {
  /// Creates a [StockInvalidId] error.
  ///
  /// [invalidId] is the ID value that failed validation.
  const StockInvalidId(this.invalidId);

  /// The invalid ID value that caused this error.
  final String invalidId;

  @override
  List<Object?> get props => [invalidId];

  @override
  String toString() => 'StockInvalidId(invalidId: $invalidId)';
}

/// Error thrown when stock timestamps are invalid.
class StockInvalidTimestamps extends StockError {
  /// Creates a [StockInvalidTimestamps] error.
  ///
  /// [createdAt] is the creation timestamp.
  /// [updatedAt] is the update timestamp that is invalid (before createdAt).
  const StockInvalidTimestamps({
    required this.createdAt,
    required this.updatedAt,
  });

  /// The creation timestamp.
  final DateTime createdAt;

  /// The update timestamp that is invalid.
  final DateTime updatedAt;

  @override
  List<Object?> get props => [createdAt, updatedAt];

  @override
  String toString() =>
      'StockInvalidTimestamps(createdAt: $createdAt, updatedAt: $updatedAt)';
}

// ============================================================================
// Stock Repository Errors
// ============================================================================

/// Base class for all stock repository-related errors.
///
/// This abstract class serves as the foundation for errors that can occur
/// during stock repository operations such as adding stocks or checking
/// for existence. All stock repository errors should extend this class
/// to ensure consistent error handling in the domain layer.
sealed class StockRepositoryError extends DomainError {
  /// Creates a [StockRepositoryError].
  const StockRepositoryError();
}

/// Error thrown when attempting to add a stock that already exists.
///
/// This error indicates a business rule violation where a stock with
/// the same ticker symbol is already present in the repository.
/// The domain layer uses this to prevent duplicate stocks.
class StockAlreadyExistsError extends StockRepositoryError {
  /// Creates a [StockAlreadyExistsError].
  ///
  /// [ticker] is the ticker symbol that already exists in the repository.
  const StockAlreadyExistsError(this.ticker);

  /// The ticker symbol that already exists.
  final String ticker;

  @override
  List<Object?> get props => [ticker];

  @override
  String toString() => 'StockAlreadyExistsError(ticker: $ticker)';
}

/// Error thrown when infrastructure-level storage operations fail.
///
/// This error represents failures at the infrastructure layer such as
/// database connection issues, query timeouts, or other storage-related
/// problems. The optional message provides additional context about
/// the specific failure.
class StockStorageError extends StockRepositoryError {
  /// Creates a [StockStorageError].
  ///
  /// [message] is an optional description of the storage failure.
  const StockStorageError([this.message]);

  /// Optional message describing the storage failure.
  final String? message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message != null
      ? 'StockStorageError(message: $message)'
      : 'StockStorageError()';
}
