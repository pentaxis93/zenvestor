part of '../../shared/errors/application_error.dart';

/// Base class for all stock-related application errors.
///
/// This abstract class serves as the foundation for errors that occur
/// during stock-related use case execution in the application layer.
sealed class StockApplicationError extends ApplicationError {
  /// Creates a stock application error.
  const StockApplicationError();
}

/// Error indicating that a stock with the given ticker already exists.
///
/// This error is returned when attempting to add a stock with a ticker
/// symbol that already exists in the repository.
class StockAlreadyExistsApplicationError extends StockApplicationError {
  /// Creates a stock already exists application error.
  ///
  /// [ticker] is the ticker symbol that already exists.
  const StockAlreadyExistsApplicationError(this.ticker);

  /// The ticker symbol that already exists.
  final String ticker;

  @override
  List<Object?> get props => [ticker];

  @override
  String toString() => 'StockAlreadyExistsApplicationError(ticker: $ticker)';
}

/// Error indicating validation failure when processing stock data.
///
/// This error is returned when input validation fails during use case
/// execution, such as invalid ticker symbols or malformed data.
class StockValidationApplicationError extends StockApplicationError {
  /// Creates a stock validation application error.
  ///
  /// [message] describes the validation failure.
  const StockValidationApplicationError({
    required this.message,
  });

  /// Description of the validation failure.
  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'StockValidationApplicationError(message: $message)';
}

/// Error indicating infrastructure-level storage operation failure.
///
/// This error represents failures during persistence operations
/// such as database errors or network issues.
class StockStorageApplicationError extends StockApplicationError {
  /// Creates a stock storage application error.
  ///
  /// [message] is an optional description of the storage failure.
  const StockStorageApplicationError([this.message]);

  /// Optional message describing the storage failure.
  final String? message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message != null
      ? 'StockStorageApplicationError(message: $message)'
      : 'StockStorageApplicationError()';
}
