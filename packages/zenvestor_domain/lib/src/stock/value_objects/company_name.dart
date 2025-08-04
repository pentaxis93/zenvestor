import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../stock_errors.dart';

/// A value object representing a company name.
///
/// Company names must:
/// - Be between 1 and 255 characters (after normalization)
/// - Contain at least one alphanumeric character
/// - Only contain allowed characters: letters, numbers, spaces, and
///   business punctuation (.,'-&())
/// - Not be empty or contain only whitespace
///
/// The value is normalized by:
/// - Trimming leading and trailing whitespace
/// - Replacing multiple consecutive spaces with single spaces
class CompanyName extends Equatable {
  const CompanyName._(this.value);

  /// The normalized company name value.
  final String value;

  /// Regular expression pattern for valid company name characters.
  ///
  /// Allowed characters:
  /// - Letters: a-z, A-Z (e.g., "Apple", "IBM")
  /// - Numbers: 0-9 (e.g., "3M", "21st Century Fox")
  /// - Spaces: for multi-word names (e.g., "General Motors")
  /// - Period: . (e.g., "Amazon.com, Inc.")
  /// - Comma: , (e.g., "Smith, Jones & Associates")
  /// - Apostrophe: ' (e.g., "McDonald's", "O'Reilly")
  /// - Hyphen: - (e.g., "Coca-Cola", "Rolls-Royce")
  /// - Ampersand: & (e.g., "AT&T", "Johnson & Johnson")
  /// - Parentheses: () (e.g., "Alphabet (Class A)", "Parent (Subsidiary)")
  ///
  /// Pattern: ^[a-zA-Z0-9\s.,'\-&()]+$
  static final RegExp _validCharactersPattern =
      RegExp(r"^[a-zA-Z0-9\s.,'\-&()]+$");

  /// Creates a [CompanyName] from the given [input].
  ///
  /// Returns [Right] with a valid [CompanyName] if the input is valid,
  /// or [Left] with a [CompanyNameError] if validation fails.
  static Either<CompanyNameError, CompanyName> create(String input) {
    // Normalize the input
    final normalized = _normalize(input);

    // Check if empty after normalization
    if (normalized.isEmpty) {
      return Left(CompanyNameEmpty(input));
    }

    // Check length constraint
    if (normalized.length > 255) {
      return Left(CompanyNameTooLong(normalized.length));
    }

    // Check for at least one alphanumeric character
    if (!_hasAlphanumeric(normalized)) {
      return Left(CompanyNameNoAlphanumeric(normalized));
    }

    // Check for valid characters
    if (!_hasOnlyValidCharacters(normalized)) {
      return Left(CompanyNameInvalidCharacters(normalized));
    }

    return Right(CompanyName._(normalized));
  }

  /// Normalizes the input string by trimming whitespace and collapsing
  /// multiple spaces.
  static String _normalize(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Checks if the string contains at least one alphanumeric character.
  static bool _hasAlphanumeric(String value) {
    return RegExp('[a-zA-Z0-9]').hasMatch(value);
  }

  /// Checks if the string contains only valid characters.
  static bool _hasOnlyValidCharacters(String value) {
    return _validCharactersPattern.hasMatch(value);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'CompanyName($value)';
}
