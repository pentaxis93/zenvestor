import 'package:fpdart/fpdart.dart';
import 'package:serverpod/serverpod.dart';
import 'package:zenvestor_server/src/domain/shared/errors/domain_error.dart';
import 'package:zenvestor_server/src/domain/stock/stock.dart';
import 'package:zenvestor_server/src/domain/stock/stock_repository.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/ticker_symbol.dart';
import 'package:zenvestor_server/src/generated/infrastructure/stock/stock_model.dart'
    as serverpod_model;
import 'package:zenvestor_server/src/infrastructure/stock/mappers/stock_mapper.dart';

/// Serverpod implementation of the stock repository.
///
/// This class bridges the domain layer's IStockRepository interface
/// with Serverpod's database operations, handling all persistence
/// concerns for Stock entities.
class StockRepositoryServerpod implements IStockRepository {
  /// Creates a new instance of the Serverpod stock repository.
  ///
  /// The [_session] is used for all database operations.
  StockRepositoryServerpod(this._session);

  final Session _session;

  // coverage:ignore-start
  // This method cannot be unit tested because it uses Serverpod's static
  // database methods (Stock.db.insertRow) which cannot be mocked.
  // Proper testing would require integration tests with a real database.
  @override
  Future<Either<StockRepositoryError, Stock>> add(Stock stock) async {
    try {
      // Check if ticker already exists
      final existsResult = await existsByTicker(stock.ticker);
      if (existsResult.isLeft()) {
        return existsResult.map((exists) => throw Exception('Unreachable'));
      }

      final exists =
          existsResult.getOrElse((l) => throw Exception('Unreachable'));
      if (exists) {
        return Left(StockAlreadyExistsError(stock.ticker.value));
      }

      // Convert domain entity to Serverpod model
      final serverpodStock = StockMapper.toServerpod(stock, null);

      // Insert into database
      final insertedStock = await serverpod_model.Stock.db.insertRow(
        _session,
        serverpodStock,
      );

      // Convert back to domain entity
      final domainResult = StockMapper.toDomain(insertedStock, stock.id);

      return domainResult.mapLeft((error) {
        // This shouldn't happen as we're mapping back our own data,
        // but handle it gracefully
        _session.log(
          'Failed to map inserted stock back to domain',
          level: LogLevel.error,
          exception: error,
        );
        return StockStorageError(
          'Failed to map inserted stock: $error',
        );
      });
    } on DatabaseException catch (e) {
      // Handle specific database exceptions
      if (e.message.contains('unique constraint') ||
          e.message.contains('duplicate key')) {
        return Left(StockAlreadyExistsError(stock.ticker.value));
      }

      _session.log(
        'Database error while adding stock',
        level: LogLevel.error,
        exception: e,
      );

      return Left(StockStorageError(
        'Database error: ${e.message}',
      ));
    } on Exception catch (e, stackTrace) {
      // Handle any other exceptions
      _session.log(
        'Unexpected error while adding stock',
        level: LogLevel.error,
        exception: e,
        stackTrace: stackTrace,
      );

      return Left(StockStorageError(
        'Unexpected error: $e',
      ));
    }
    // coverage:ignore-end
  }

  // coverage:ignore-start
  // This method cannot be unit tested because it uses Serverpod's static
  // database methods (Stock.db.find) which cannot be mocked.
  // Proper testing would require integration tests with a real database.
  @override
  Future<Either<StockRepositoryError, bool>> existsByTicker(
    TickerSymbol ticker,
  ) async {
    try {
      // Query for stocks with the given ticker
      final stocks = await serverpod_model.Stock.db.find(
        _session,
        where: (stock) => stock.tickerSymbol.equals(ticker.value),
        limit: 1,
      );

      return Right(stocks.isNotEmpty);
    } on DatabaseException catch (e) {
      _session.log(
        'Database error while checking ticker existence',
        level: LogLevel.error,
        exception: e,
      );

      return Left(StockStorageError(
        'Database error: ${e.message}',
      ));
    } on Exception catch (e, stackTrace) {
      _session.log(
        'Unexpected error while checking ticker existence',
        level: LogLevel.error,
        exception: e,
        stackTrace: stackTrace,
      );

      return Left(StockStorageError(
        'Unexpected error: $e',
      ));
    }
    // coverage:ignore-end
  }
}
