import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:zenvestor_server/src/application/shared/errors/application_error.dart';
import 'package:zenvestor_server/src/application/stock/dtos/add_stock_request.dart';
import 'package:zenvestor_server/src/application/stock/dtos/add_stock_response.dart';
import 'package:zenvestor_server/src/domain/shared/errors/domain_error.dart';
import 'package:zenvestor_server/src/domain/stock/stock.dart';
import 'package:zenvestor_server/src/domain/stock/stock_repository.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/ticker_symbol.dart';

/// Use case for adding a new stock to the system.
///
/// This use case orchestrates the process of adding a stock with minimal
/// information (just the ticker symbol). It handles validation, duplicate
/// checking, and persistence while maintaining clean architecture boundaries.
///
/// The use case follows these steps:
/// 1. Validates the ticker symbol input
/// 2. Checks if a stock with the same ticker already exists
/// 3. Creates a new stock entity with generated ID and timestamps
/// 4. Persists the stock through the repository
/// 5. Returns a response DTO with the created stock information
///
/// Example usage:
/// ```dart
/// final useCase = AddStockUseCase(repository: stockRepository);
/// final result = await useCase.execute(AddStockRequest(ticker: 'AAPL'));
///
/// result.fold(
///   (error) => print('Failed to add stock: $error'),
///   (response) => print(
///       'Added stock ${response.ticker} with ID ${response.id}',
///   ),
/// );
/// ```
class AddStockUseCase {
  /// Creates an instance of the add stock use case.
  ///
  /// [repository] is the stock repository interface for persistence operations.
  const AddStockUseCase({
    required IStockRepository repository,
  }) : _repository = repository;

  final IStockRepository _repository;

  /// Executes the use case to add a new stock.
  ///
  /// Takes an [AddStockRequest] containing the ticker symbol and returns
  /// either a [StockApplicationError] on failure or an [AddStockResponse]
  /// on success.
  ///
  /// Possible errors:
  /// - [StockValidationApplicationError] if the ticker symbol is invalid
  ///   (empty, too long, or contains non-letter characters)
  /// - [StockAlreadyExistsApplicationError] if a stock with the ticker exists
  ///   (either detected during existence check or during add operation)
  /// - [StockStorageApplicationError] if infrastructure operations fail
  ///   (database connectivity, timeouts, etc.)
  ///
  /// The ticker symbol is automatically normalized by:
  /// - Trimming whitespace
  /// - Converting to uppercase
  Future<Either<StockApplicationError, AddStockResponse>> execute(
    AddStockRequest request,
  ) async {
    // Step 1: Validate and create ticker symbol value object
    final tickerResult = TickerSymbol.create(request.ticker);

    if (tickerResult.isLeft()) {
      final error = tickerResult.getLeft().toNullable()!;
      return left(
        StockValidationApplicationError(
          message: error.message,
        ),
      );
    }

    final tickerSymbol = tickerResult.toNullable()!;

    // Step 2: Check if stock already exists
    final existsResult = await _repository.existsByTicker(tickerSymbol);

    if (existsResult.isLeft()) {
      final error = existsResult.getLeft().toNullable()!;
      // existsByTicker only returns StockStorageError per repository
      // contract
      final storageError = error as StockStorageError;
      return left(StockStorageApplicationError(storageError.message));
    }

    final exists = existsResult.toNullable() ?? false;
    if (exists) {
      return left(StockAlreadyExistsApplicationError(tickerSymbol.value));
    }

    // Step 3: Create stock entity with generated data
    final now = DateTime.now();
    final stockId = const Uuid().v4();

    final stockResult = Stock.create(
      id: stockId,
      ticker: tickerSymbol,
      createdAt: now,
      updatedAt: now,
      // All optional fields default to None()
    );

    // coverage:ignore-start
    if (stockResult.isLeft()) {
      // TODO(defensive): This check handles an "impossible" case where
      // Stock.create fails with valid inputs. In practice, this should never
      // happen with valid ID and timestamps. To test this would require
      // injecting a Stock factory, which would add unnecessary complexity.
      return left(
        const StockValidationApplicationError(
          message: 'Failed to create stock entity',
        ),
      );
    }
    // coverage:ignore-end

    final stock = stockResult.toNullable()!;

    // Step 4: Persist the stock
    final addResult = await _repository.add(stock);

    if (addResult.isLeft()) {
      final error = addResult.getLeft().toNullable()!;
      // The repository contract specifies that add() can only return
      // StockAlreadyExistsError or StockStorageError, but we need
      // a default case for exhaustiveness since StockRepositoryError
      // is abstract (not sealed)
      return switch (error) {
        StockAlreadyExistsError() =>
          left(StockAlreadyExistsApplicationError(error.ticker)),
        StockStorageError() =>
          left(StockStorageApplicationError(error.message)),
        // coverage:ignore-start
        _ => left(const StockStorageApplicationError('Failed to add stock')),
        // coverage:ignore-end
      };
    }

    final savedStock = addResult.toNullable()!;

    // Step 5: Transform to response DTO
    return right(
      AddStockResponse(
        id: savedStock.id,
        ticker: savedStock.ticker.value,
        createdAt: savedStock.createdAt,
        updatedAt: savedStock.updatedAt,
      ),
    );
  }
}
