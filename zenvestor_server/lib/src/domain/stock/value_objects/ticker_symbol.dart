import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zenvestor_server/src/domain/shared/errors/domain_error.dart';

/// Represents a valid stock ticker symbol.
///
/// Ticker symbols must:
/// - Be between 1-5 characters long
/// - Contain only uppercase letters A-Z
/// - Not be empty or contain only whitespace
///
/// The factory constructor normalizes input by:
/// - Converting to uppercase
/// - Trimming whitespace
class TickerSymbol extends Equatable {
  /// Creates a new TickerSymbol instance with a validated value.
  ///
  /// This constructor is private to ensure all instances are created
  /// through the factory method with proper validation.
  const TickerSymbol._(this.value);

  /// Maximum allowed length for a ticker symbol.
  static const int maxLength = 5;

  /// Regular expression pattern for valid ticker symbols (A-Z only).
  static final RegExp _validPattern = RegExp(r'^[A-Z]+$');

  /// Creates a TickerSymbol from a string value.
  ///
  /// The input is normalized by:
  /// - Trimming whitespace
  /// - Converting to uppercase
  ///
  /// Returns a Right with the TickerSymbol if valid, or a Left with
  /// a TickerSymbolError if the input violates any business rules.
  static Either<TickerSymbolError, TickerSymbol> create(String input) {
    final trimmed = input.trim();

    // Check if empty after trimming
    if (trimmed.isEmpty) {
      return Left(TickerSymbolEmpty(input));
    }

    // Normalize to uppercase
    final normalized = trimmed.toUpperCase();

    // Check for valid characters (only A-Z) before checking length
    if (!_validPattern.hasMatch(normalized)) {
      return Left(TickerSymbolInvalidFormat(input));
    }

    // Check length after validating characters
    if (normalized.length > maxLength) {
      return Left(TickerSymbolTooLong(normalized.length));
    }

    return Right(TickerSymbol._(normalized));
  }

  /// The validated and normalized ticker symbol value.
  final String value;

  @override
  List<Object> get props => [value];

  @override
  String toString() => 'TickerSymbol($value)';
}
