import 'package:fpdart/fpdart.dart';
import 'package:serverpod/serverpod.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;
import 'package:zenvestor_server/src/domain/stock/stock.dart';
import 'package:zenvestor_server/src/domain/stock/stock_errors.dart';
import 'package:zenvestor_server/src/domain/stock/stock_repository.dart';
import 'package:zenvestor_server/src/generated/infrastructure/stock/stock_model.dart'
    as serverpod_model;
import 'package:zenvestor_server/src/infrastructure/persistence/stock/stock_persistence_model.dart';
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
  Future<Either<StockRepositoryError, Stock>> add(shared.Stock stock) async {
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

      // Create persistence model with generated infrastructure data
      final now = DateTime.now();
      final stockId = const Uuid().v4();

      final persistenceModelResult = StockPersistenceModel.create(
        id: stockId,
        ticker: stock.ticker,
        name: stock.name,
        sicCode: stock.sicCode,
        grade: stock.grade,
        createdAt: now,
        updatedAt: now,
      );

      if (persistenceModelResult.isLeft()) {
        // Map infrastructure errors to domain repository errors
        final error = persistenceModelResult.getLeft().toNullable()!;
        return Left(StockStorageError(
          'Failed to create persistence model: $error',
        ));
      }

      final persistenceModel = persistenceModelResult.toNullable()!;

      // Convert persistence model to Serverpod model
      final serverpodStock = StockMapper.toServerpod(persistenceModel, null);

      // Insert into database
      final insertedStock = await serverpod_model.Stock.db.insertRow(
        _session,
        serverpodStock,
      );

      // Convert back to domain entity via persistence model
      final persistenceResult = StockMapper.toPersistenceModel(
        insertedStock,
        stockId,
      );

      if (persistenceResult.isLeft()) {
        _session.log(
          'Failed to map inserted stock back to persistence model',
          level: LogLevel.error,
          exception: persistenceResult.getLeft().toNullable(),
        );
        final leftError = persistenceResult.getLeft().toNullable();
        return Left(StockStorageError(
          'Failed to map inserted stock: $leftError',
        ));
      }

      final mappedPersistenceModel = persistenceResult.toNullable()!;

      // Create server domain Stock with infrastructure data
      final serverStock = Stock.fromSharedStock(
        id: mappedPersistenceModel.id,
        createdAt: mappedPersistenceModel.createdAt,
        updatedAt: mappedPersistenceModel.updatedAt,
        sharedStock: mappedPersistenceModel.stock,
      );

      return Right(serverStock);
      // This shouldn't happen as we're mapping back our own data,
      // but handle it gracefully
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
    shared.TickerSymbol ticker,
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
