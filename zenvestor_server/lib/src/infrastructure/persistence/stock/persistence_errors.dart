import 'package:zenvestor_domain/shared/errors.dart' show DomainError;

/// Base class for all persistence-related errors.
sealed class PersistenceError extends DomainError {
  /// Creates a [PersistenceError].
  const PersistenceError();
}

/// Error thrown when a stock ID is invalid.
class InvalidStockId extends PersistenceError {
  /// Creates a [InvalidStockId] error.
  ///
  /// [invalidId] is the ID value that failed validation.
  const InvalidStockId(this.invalidId);

  /// The invalid ID value that caused this error.
  final String invalidId;

  @override
  List<Object?> get props => [invalidId];

  @override
  String toString() => 'InvalidStockId(invalidId: $invalidId)';
}

/// Error thrown when stock timestamps are invalid.
class InvalidStockTimestamps extends PersistenceError {
  /// Creates a [InvalidStockTimestamps] error.
  ///
  /// [createdAt] is the creation timestamp.
  /// [updatedAt] is the update timestamp that is invalid (before createdAt).
  const InvalidStockTimestamps({
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
      'InvalidStockTimestamps(createdAt: $createdAt, updatedAt: $updatedAt)';
}

/// Error thrown when database storage operations fail.
class DatabaseStorageError extends PersistenceError {
  /// Creates a [DatabaseStorageError].
  ///
  /// [message] is an optional description of the storage failure.
  const DatabaseStorageError([this.message]);

  /// Optional message describing the storage failure.
  final String? message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message != null
      ? 'DatabaseStorageError(message: $message)'
      : 'DatabaseStorageError()';
}
