import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zenvestor_server/src/domain/errors/validation_error.dart';

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

  /// Creates a TickerSymbol from a string value.
  ///
  /// The input is normalized by:
  /// - Trimming whitespace
  /// - Converting to uppercase
  ///
  /// Returns a Right with the TickerSymbol if valid, or a Left with
  /// a ValidationError if the input violates any business rules.
  static Either<ValidationError, TickerSymbol> create(String input) {
    final trimmed = input.trim();

    // Check if empty after trimming
    if (trimmed.isEmpty) {
      return Left(
        ValidationError(
          field: 'ticker_symbol',
          invalidValue: input,
          message: 'ticker_symbol is required',
        ),
      );
    }

    // Normalize to uppercase
    final normalized = trimmed.toUpperCase();

    // Check for valid characters (only A-Z) before checking length
    final validPattern = RegExp(r'^[A-Z]+$');
    if (!validPattern.hasMatch(normalized)) {
      return Left(
        ValidationError(
          field: 'ticker_symbol',
          invalidValue: input,
          message: 'ticker_symbol must contain only letters A-Z',
        ),
      );
    }

    // Check length after validating characters
    if (normalized.length > 5) {
      return Left(
        ValidationError.invalidLength(
          field: 'ticker_symbol',
          invalidValue: input,
          maxLength: 5,
        ),
      );
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
