part of 'domain_error.dart';

/// Base class for all stock-related domain errors.
abstract class StockError extends DomainError {
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
