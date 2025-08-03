import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zenvestor_server/src/domain/stock/stock_errors.dart';

/// Represents a valid SIC (Standard Industrial Classification) code.
///
/// SIC codes are 4-digit codes used to classify industries. Valid codes:
/// - Must be exactly 4 digits long
/// - Must contain only numeric characters (0-9)
/// - Must be within the range 0100-9999
/// - Leading zeros are preserved (stored as String)
///
/// The factory constructor normalizes input by trimming whitespace.
class SicCode extends Equatable {
  /// Creates a new SicCode instance with a validated value.
  ///
  /// This constructor is private to ensure all instances are created
  /// through the factory method with proper validation.
  const SicCode._(this.value);

  /// Regular expression pattern for valid SIC codes (4 digits).
  static final RegExp _validPattern = RegExp(r'^\d{4}$');

  /// Creates a SicCode from a string value.
  ///
  /// The input is normalized by:
  /// - Trimming whitespace
  /// - Padding with leading zeros if the input is 1-3 digits
  ///
  /// Returns a Right with the SicCode if valid, or a Left with
  /// a SicCodeError if the input violates any business rules.
  static Either<SicCodeError, SicCode> create(String input) {
    final trimmed = input.trim();

    // Check if empty after trimming
    if (trimmed.isEmpty) {
      return Left(SicCodeEmpty(input));
    }

    // Check if input contains only digits for normalization
    final isNumeric = RegExp(r'^\d+$').hasMatch(trimmed);

    var normalized = trimmed;

    // If numeric and less than 4 digits, pad with leading zeros
    if (isNumeric && trimmed.length < 4) {
      normalized = trimmed.padLeft(4, '0');
    }

    // Check length after normalization
    if (normalized.length != 4) {
      return Left(SicCodeInvalidLength(trimmed.length));
    }

    // Check for valid format (only digits)
    if (!_validPattern.hasMatch(normalized)) {
      return Left(SicCodeInvalidFormat(trimmed));
    }

    // Check range (0100-9999)
    final codeValue = int.parse(normalized);
    if (codeValue < 100 || codeValue > 9999) {
      // Pass the original trimmed input for better error messages
      return Left(SicCodeOutOfRange(trimmed));
    }

    return Right(SicCode._(normalized));
  }

  /// Creates a SicCode from a JSON value.
  ///
  /// This is a convenience method for deserialization that delegates
  /// to the main factory constructor.
  static Either<SicCodeError, SicCode> fromJson(String json) {
    return create(json);
  }

  /// The validated and normalized SIC code value.
  final String value;

  /// Converts this SicCode to a JSON-compatible value.
  String toJson() => value;

  @override
  List<Object> get props => [value];

  @override
  String toString() => 'SicCode($value)';
}
