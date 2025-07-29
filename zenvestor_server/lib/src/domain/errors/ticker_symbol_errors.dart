part of 'domain_error.dart';

/// Base class for all ticker symbol validation errors.
///
/// This abstract class serves as the root of the ticker symbol error hierarchy,
/// enabling type-safe error handling specific to ticker symbol validation while
/// extending the general [DomainError] framework.
///
/// All specific ticker symbol validation errors should extend this class.
abstract class TickerSymbolError extends DomainError {
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
