part of '../../shared/errors/domain_error.dart';

/// Base class for all stock repository-related errors.
///
/// This abstract class serves as the foundation for errors that can occur
/// during stock repository operations such as adding stocks or checking
/// for existence. All stock repository errors should extend this class
/// to ensure consistent error handling in the domain layer.
abstract class StockRepositoryError extends DomainError {
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
  final TickerSymbol ticker;

  @override
  List<Object?> get props => [ticker];

  @override
  String toString() => 'StockAlreadyExistsError(ticker: ${ticker.value})';
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
