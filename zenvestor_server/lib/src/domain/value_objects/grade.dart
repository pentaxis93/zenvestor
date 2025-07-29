import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zenvestor_server/src/domain/errors/domain_error.dart';

/// Represents a stock quality grade using the traditional academic
/// grading scale.
///
/// Valid grades are exactly: A, B, C, D, or F (no plus/minus modifiers).
/// The grade is used to categorize stocks by quality/performance in the
/// trader's evaluation system.
///
/// Input is normalized by:
/// - Trimming whitespace
/// - Converting to uppercase
class Grade extends Equatable {
  /// Creates a new Grade instance with a validated value.
  ///
  /// This constructor is private to ensure all instances are created
  /// through the factory method with proper validation.
  const Grade._(this.value);

  /// The validated grade value (always uppercase).
  final String value;

  /// Set of valid grade values.
  static const Set<String> _validGrades = {'A', 'B', 'C', 'D', 'F'};

  /// Creates a Grade from a string value.
  ///
  /// The input is normalized by:
  /// - Trimming whitespace
  /// - Converting to uppercase
  ///
  /// Returns a Right with the Grade if valid, or a Left with
  /// a GradeError if the input violates validation rules.
  static Either<GradeError, Grade> create(String input) {
    final trimmed = input.trim();

    // Check if empty after trimming
    if (trimmed.isEmpty) {
      return Left(GradeEmpty(input));
    }

    // Normalize to uppercase
    final normalized = trimmed.toUpperCase();

    // Check if it's a valid grade
    if (!_validGrades.contains(normalized)) {
      return Left(GradeInvalidValue(input));
    }

    return Right(Grade._(normalized));
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'Grade($value)';
}
