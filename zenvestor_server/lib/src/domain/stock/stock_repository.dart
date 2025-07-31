import 'package:fpdart/fpdart.dart';
import 'package:zenvestor_server/src/domain/shared/errors/domain_error.dart';
import 'package:zenvestor_server/src/domain/stock/stock.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/ticker_symbol.dart';

/// Repository interface for managing stock entities in the domain layer.
///
/// This interface defines the contract for stock persistence operations
/// following Domain-Driven Design principles. It uses functional error
/// handling with Either types to represent success and failure cases
/// without throwing exceptions.
///
/// All implementations must respect the domain invariants and return
/// appropriate domain errors when operations fail. The interface is
/// technology-agnostic and contains no references to specific storage
/// mechanisms or infrastructure concerns.
abstract interface class IStockRepository {
  /// Adds a new stock to the repository.
  ///
  /// This operation persists the provided [stock] and returns the
  /// persisted version, which may include storage-generated fields
  /// such as updated timestamps or version numbers.
  ///
  /// The operation enforces the business rule that each stock must
  /// have a unique ticker symbol. Attempting to add a stock with a
  /// ticker that already exists will result in a failure.
  ///
  /// Returns:
  /// - [Right] containing the persisted [Stock] on success
  /// - [Left] containing [StockAlreadyExistsError] if a stock with
  ///   the same ticker already exists
  /// - [Left] containing [StockStorageError] if infrastructure
  ///   operations fail
  Future<Either<StockRepositoryError, Stock>> add(Stock stock);

  /// Checks whether a stock with the given ticker symbol exists.
  ///
  /// This operation provides a lightweight way to verify the existence
  /// of a stock without retrieving the full entity. It's particularly
  /// useful for validation before attempting to add a new stock.
  ///
  /// Returns:
  /// - [Right] containing `true` if a stock with the [ticker] exists
  /// - [Right] containing `false` if no stock with the [ticker] exists
  /// - [Left] containing [StockStorageError] if infrastructure
  ///   operations fail
  Future<Either<StockRepositoryError, bool>> existsByTicker(
    TickerSymbol ticker,
  );
}
