import 'package:zenvestor_domain/shared/errors.dart' show DomainError;

// Re-export value object errors from shared domain
export 'package:zenvestor_domain/zenvestor_domain.dart'
    show
        // Company name errors
        CompanyNameEmpty,
        CompanyNameError,
        CompanyNameInvalidCharacters,
        CompanyNameNoAlphanumeric,
        CompanyNameTooLong,
        CompanyNameTooShort,
        // Grade errors
        GradeEmpty,
        GradeError,
        GradeInvalidValue,
        // SIC code errors
        SicCodeEmpty,
        SicCodeError,
        SicCodeInvalidFormat,
        SicCodeInvalidLength,
        SicCodeOutOfRange,
        // Ticker errors
        TickerSymbolEmpty,
        TickerSymbolError,
        TickerSymbolInvalidFormat,
        TickerSymbolTooLong,
        TickerSymbolTooShort;

// ============================================================================
// Server-Specific Stock Entity Errors
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
