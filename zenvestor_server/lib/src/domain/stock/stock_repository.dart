import 'package:fpdart/fpdart.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;
import 'package:zenvestor_server/src/domain/stock/stock.dart';
import 'package:zenvestor_server/src/domain/stock/stock_errors.dart';

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
  /// This operation persists the provided [stock]. The repository
  /// implementation is responsible for handling infrastructure concerns
  /// such as generating IDs and managing timestamps.
  ///
  /// The operation enforces the business rule that each stock must
  /// have a unique ticker symbol. Attempting to add a stock with a
  /// ticker that already exists will result in a failure.
  ///
  /// Returns:
  /// - [Right] containing the server domain [Stock] with infrastructure
  ///   data (id, timestamps) on success
  /// - [Left] containing [StockAlreadyExistsError] if a stock with
  ///   the same ticker already exists
  /// - [Left] containing [StockStorageError] if infrastructure
  ///   operations fail
  Future<Either<StockRepositoryError, Stock>> add(shared.Stock stock);

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
    shared.TickerSymbol ticker,
  );
}
