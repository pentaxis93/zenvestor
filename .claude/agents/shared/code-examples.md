# Reusable Code Pattern Library for Zenvestor

This document provides a comprehensive library of code patterns that all Zenvestor agents should use. These patterns ensure consistency and quality across the codebase.

## Value Object Patterns

### Basic Value Object Structure

```dart
import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';

class Amount extends Equatable {
  final double value;
  
  const Amount._(this.value);
  
  static Either<AmountError, Amount> create(double value) {
    if (value < 0) {
      return left(NegativeAmountError(value: value));
    }
    
    if (value > 1000000000) {
      return left(ExcessiveAmountError(value: value));
    }
    
    // Round to 2 decimal places for currency
    final rounded = (value * 100).round() / 100;
    return right(Amount._(rounded));
  }
  
  // Factory methods for common cases
  static Amount zero() => const Amount._(0);
  static Amount max() => const Amount._(1000000000);
  
  // Operations that maintain invariants
  Either<AmountError, Amount> add(Amount other) {
    return create(value + other.value);
  }
  
  Either<AmountError, Amount> multiply(double factor) {
    return create(value * factor);
  }
  
  // Comparison helpers
  bool isGreaterThan(Amount other) => value > other.value;
  bool isLessThan(Amount other) => value < other.value;
  bool isZero() => value == 0;
  
  @override
  List<Object?> get props => [value];
  
  @override
  String toString() => '\$${value.toStringAsFixed(2)}';
}

// Error types
sealed class AmountError {
  const AmountError();
}

class NegativeAmountError extends AmountError {
  final double value;
  const NegativeAmountError({required this.value});
  
  String get message => 'Amount cannot be negative: $value';
}

class ExcessiveAmountError extends AmountError {
  final double value;
  const ExcessiveAmountError({required this.value});
  
  String get message => 'Amount exceeds maximum allowed: $value';
}
```

### String Value Object with Format Validation

```dart
class Email extends Equatable {
  final String value;
  
  const Email._(this.value);
  
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static Either<EmailError, Email> create(String value) {
    final trimmed = value.trim().toLowerCase();
    
    if (trimmed.isEmpty) {
      return left(EmptyEmailError());
    }
    
    if (!_emailRegex.hasMatch(trimmed)) {
      return left(InvalidEmailFormatError(
        value: value,
        suggestion: 'Ensure format is: user@domain.com',
      ));
    }
    
    if (trimmed.length > 254) {
      return left(EmailTooLongError(
        value: value,
        maxLength: 254,
      ));
    }
    
    return right(Email._(trimmed));
  }
  
  // Domain-specific helpers
  String get domain => value.split('@').last;
  String get localPart => value.split('@').first;
  
  @override
  List<Object?> get props => [value];
}
```

### Composite Value Object

```dart
class StockSymbol extends Equatable {
  final String exchange;
  final String ticker;
  
  const StockSymbol._({
    required this.exchange,
    required this.ticker,
  });
  
  static Either<StockSymbolError, StockSymbol> create({
    required String exchange,
    required String ticker,
  }) {
    // Validate exchange
    final validatedExchange = _validateExchange(exchange);
    if (validatedExchange.isLeft()) {
      return left(validatedExchange.getLeft().getOrElse(() => 
        throw 'Unreachable'));
    }
    
    // Validate ticker
    final validatedTicker = _validateTicker(ticker);
    if (validatedTicker.isLeft()) {
      return left(validatedTicker.getLeft().getOrElse(() => 
        throw 'Unreachable'));
    }
    
    return right(StockSymbol._(
      exchange: validatedExchange.getOrElse(() => throw 'Unreachable'),
      ticker: validatedTicker.getOrElse(() => throw 'Unreachable'),
    ));
  }
  
  // Parse from string format "NASDAQ:AAPL"
  static Either<StockSymbolError, StockSymbol> parse(String value) {
    final parts = value.split(':');
    
    if (parts.length != 2) {
      return left(InvalidFormatError(
        value: value,
        expectedFormat: 'EXCHANGE:TICKER',
        example: 'NASDAQ:AAPL',
      ));
    }
    
    return create(exchange: parts[0], ticker: parts[1]);
  }
  
  String toFullSymbol() => '$exchange:$ticker';
  
  @override
  List<Object?> get props => [exchange, ticker];
}
```

## Domain Entity Patterns

### Entity with State Machine

```dart
class Order extends Equatable {
  final OrderId id;
  final CustomerId customerId;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  
  const Order._({
    required this.id,
    required this.customerId,
    required this.items,
    required this.status,
    required this.createdAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
  });
  
  // Factory for new orders
  static Either<OrderError, Order> create({
    required CustomerId customerId,
    required List<OrderItem> items,
  }) {
    if (items.isEmpty) {
      return left(EmptyOrderError());
    }
    
    final totalAmount = items.fold(
      Amount.zero(),
      (sum, item) => sum.add(item.total).getOrElse(() => Amount.zero()),
    );
    
    if (totalAmount.isZero()) {
      return left(ZeroAmountOrderError());
    }
    
    return right(Order._(
      id: OrderId.generate(),
      customerId: customerId,
      items: List.unmodifiable(items),
      status: OrderStatus.draft,
      createdAt: DateTime.now(),
    ));
  }
  
  // State transitions
  Either<OrderError, Order> confirm() {
    return switch (status) {
      OrderStatus.draft => right(copyWith(
          status: OrderStatus.confirmed,
          confirmedAt: DateTime.now(),
        )),
      _ => left(InvalidStateTransitionError(
          currentState: status.name,
          attemptedTransition: 'confirm',
          allowedStates: ['draft'],
        )),
    };
  }
  
  Either<OrderError, Order> ship(ShippingInfo shippingInfo) {
    return switch (status) {
      OrderStatus.confirmed => right(copyWith(
          status: OrderStatus.shipped,
          shippedAt: DateTime.now(),
        )),
      _ => left(InvalidStateTransitionError(
          currentState: status.name,
          attemptedTransition: 'ship',
          allowedStates: ['confirmed'],
        )),
    };
  }
  
  // Query methods
  Amount get totalAmount => items.fold(
    Amount.zero(),
    (sum, item) => sum.add(item.total).getOrElse(() => Amount.zero()),
  );
  
  bool get canBeModified => status == OrderStatus.draft;
  bool get canBeCancelled => const [
    OrderStatus.draft,
    OrderStatus.confirmed,
  ].contains(status);
  
  // Business operations
  Either<OrderError, Order> addItem(OrderItem item) {
    if (!canBeModified) {
      return left(OrderNotModifiableError(
        orderId: id,
        currentStatus: status,
      ));
    }
    
    return right(copyWith(
      items: [...items, item],
    ));
  }
  
  @override
  List<Object?> get props => [
    id, customerId, items, status, createdAt,
    confirmedAt, shippedAt, deliveredAt, cancelledAt,
  ];
}

// Supporting types
enum OrderStatus {
  draft,
  confirmed,
  shipped,
  delivered,
  cancelled,
}

class OrderItem extends Equatable {
  final ProductId productId;
  final Quantity quantity;
  final Price unitPrice;
  
  Amount get total => unitPrice.multiply(quantity.value)
    .getOrElse(() => Amount.zero());
  
  @override
  List<Object?> get props => [productId, quantity, unitPrice];
}
```

### Aggregate Root Pattern

```dart
class Portfolio extends AggregateRoot {
  final PortfolioId id;
  final UserId ownerId;
  final PortfolioName name;
  final List<Holding> holdings;
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final int version;
  
  const Portfolio._({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.holdings,
    required this.createdAt,
    required this.lastModifiedAt,
    required this.version,
    required List<DomainEvent> events,
  }) : super(events);
  
  // Aggregate creation
  static Either<PortfolioError, Portfolio> create({
    required UserId ownerId,
    required String name,
  }) {
    return PortfolioName.create(name).flatMap((validName) {
      final portfolio = Portfolio._(
        id: PortfolioId.generate(),
        ownerId: ownerId,
        name: validName,
        holdings: const [],
        createdAt: DateTime.now(),
        lastModifiedAt: DateTime.now(),
        version: 0,
        events: [
          PortfolioCreatedEvent(
            portfolioId: PortfolioId.generate(),
            ownerId: ownerId,
            name: validName,
            createdAt: DateTime.now(),
          ),
        ],
      );
      
      return right(portfolio);
    });
  }
  
  // Business operations that maintain invariants
  Either<PortfolioError, Portfolio> addStock({
    required StockId stockId,
    required Quantity quantity,
    required Price purchasePrice,
  }) {
    // Check if stock already exists
    final existingIndex = holdings.indexWhere(
      (h) => h.stockId == stockId,
    );
    
    if (existingIndex != -1) {
      // Update existing holding
      final existing = holdings[existingIndex];
      final newQuantity = existing.quantity.add(quantity);
      
      return newQuantity.fold(
        (error) => left(PortfolioError.fromQuantityError(error)),
        (validQuantity) {
          final updatedHolding = existing.copyWith(
            quantity: validQuantity,
            averageCost: _calculateNewAverageCost(
              existing,
              quantity,
              purchasePrice,
            ),
          );
          
          final newHoldings = List<Holding>.from(holdings);
          newHoldings[existingIndex] = updatedHolding;
          
          return right(_copyWithNewEvent(
            holdings: newHoldings,
            event: StockAddedEvent(
              portfolioId: id,
              stockId: stockId,
              quantity: quantity,
              purchasePrice: purchasePrice,
            ),
          ));
        },
      );
    } else {
      // Add new holding
      final newHolding = Holding(
        stockId: stockId,
        quantity: quantity,
        averageCost: purchasePrice,
      );
      
      return right(_copyWithNewEvent(
        holdings: [...holdings, newHolding],
        event: StockAddedEvent(
          portfolioId: id,
          stockId: stockId,
          quantity: quantity,
          purchasePrice: purchasePrice,
        ),
      ));
    }
  }
  
  // Aggregate consistency methods
  Price _calculateNewAverageCost(
    Holding existing,
    Quantity newQuantity,
    Price purchasePrice,
  ) {
    final totalCost = existing.totalCost.add(
      purchasePrice.multiply(newQuantity.value),
    );
    final totalQuantity = existing.quantity.add(newQuantity);
    
    return totalCost.divide(totalQuantity.value)
      .getOrElse(() => existing.averageCost);
  }
  
  Portfolio _copyWithNewEvent({
    List<Holding>? holdings,
    required DomainEvent event,
  }) {
    return Portfolio._(
      id: id,
      ownerId: ownerId,
      name: name,
      holdings: holdings ?? this.holdings,
      createdAt: createdAt,
      lastModifiedAt: DateTime.now(),
      version: version + 1,
      events: [...events, event],
    );
  }
}
```

## Use Case Patterns

### Basic Use Case Structure

```dart
class GetPortfolioDetailsUseCase {
  final PortfolioRepository _portfolioRepository;
  final StockRepository _stockRepository;
  final MarketDataService _marketDataService;
  
  const GetPortfolioDetailsUseCase({
    required PortfolioRepository portfolioRepository,
    required StockRepository stockRepository,
    required MarketDataService marketDataService,
  }) : _portfolioRepository = portfolioRepository,
       _stockRepository = stockRepository,
       _marketDataService = marketDataService;
  
  Future<Either<GetPortfolioError, PortfolioDetails>> execute({
    required PortfolioId portfolioId,
    required UserId requestingUserId,
  }) async {
    // Load portfolio
    final portfolioResult = await _portfolioRepository.findById(portfolioId);
    
    return portfolioResult.fold(
      (error) => left(GetPortfolioError.fromRepositoryError(error)),
      (portfolio) async {
        // Check permissions
        if (portfolio.ownerId != requestingUserId) {
          return left(PortfolioAccessDeniedError(
            portfolioId: portfolioId,
            userId: requestingUserId,
          ));
        }
        
        // Load stock details and current prices
        final stockDetails = await _loadStockDetails(portfolio.holdings);
        final currentPrices = await _loadCurrentPrices(portfolio.holdings);
        
        // Calculate metrics
        final details = PortfolioDetails(
          portfolio: portfolio,
          stockDetails: stockDetails,
          currentPrices: currentPrices,
          totalValue: _calculateTotalValue(portfolio.holdings, currentPrices),
          totalGainLoss: _calculateGainLoss(portfolio.holdings, currentPrices),
        );
        
        return right(details);
      },
    );
  }
  
  Future<Map<StockId, Stock>> _loadStockDetails(
    List<Holding> holdings,
  ) async {
    final stockIds = holdings.map((h) => h.stockId).toList();
    final stocks = await _stockRepository.findByIds(stockIds);
    
    return Map.fromEntries(
      stocks.map((stock) => MapEntry(stock.id, stock)),
    );
  }
}
```

### Use Case with Transaction

```dart
class TransferStockUseCase {
  final PortfolioRepository _portfolioRepository;
  final TransactionManager _transactionManager;
  final EventBus _eventBus;
  
  Future<Either<TransferError, TransferResult>> execute({
    required PortfolioId fromPortfolioId,
    required PortfolioId toPortfolioId,
    required StockId stockId,
    required Quantity quantity,
    required UserId requestingUserId,
  }) async {
    return _transactionManager.runInTransaction(() async {
      // Load both portfolios
      final fromResult = await _portfolioRepository.findById(fromPortfolioId);
      final toResult = await _portfolioRepository.findById(toPortfolioId);
      
      // Combine results
      final portfoliosResult = fromResult.flatMap((from) =>
        toResult.map((to) => (from: from, to: to))
      );
      
      return portfoliosResult.fold(
        (error) => left(TransferError.fromRepositoryError(error)),
        (portfolios) async {
          // Validate permissions
          if (portfolios.from.ownerId != requestingUserId ||
              portfolios.to.ownerId != requestingUserId) {
            return left(TransferAccessDeniedError());
          }
          
          // Remove from source portfolio
          final removeResult = portfolios.from.removeStock(
            stockId: stockId,
            quantity: quantity,
          );
          
          return removeResult.fold(
            (error) => left(TransferError.fromDomainError(error)),
            (updatedFrom) async {
              // Add to destination portfolio
              final addResult = portfolios.to.addStock(
                stockId: stockId,
                quantity: quantity,
                purchasePrice: updatedFrom.holdings
                  .firstWhere((h) => h.stockId == stockId)
                  .averageCost,
              );
              
              return addResult.fold(
                (error) => left(TransferError.fromDomainError(error)),
                (updatedTo) async {
                  // Save both portfolios
                  await _portfolioRepository.save(updatedFrom);
                  await _portfolioRepository.save(updatedTo);
                  
                  // Publish events
                  for (final event in [...updatedFrom.events, ...updatedTo.events]) {
                    await _eventBus.publish(event);
                  }
                  
                  return right(TransferResult(
                    fromPortfolio: updatedFrom,
                    toPortfolio: updatedTo,
                    transferredQuantity: quantity,
                  ));
                },
              );
            },
          );
        },
      );
    });
  }
}
```

## Repository Patterns

### Repository Interface

```dart
abstract class StockRepository {
  Future<Either<RepositoryError, Stock>> findById(StockId id);
  Future<Either<RepositoryError, Stock>> findByTicker(Ticker ticker);
  Future<Either<RepositoryError, List<Stock>>> findByIds(List<StockId> ids);
  Future<Either<RepositoryError, List<Stock>>> search(StockSearchCriteria criteria);
  Future<Either<RepositoryError, void>> save(Stock stock);
  Future<Either<RepositoryError, void>> delete(StockId id);
}

// Search criteria value object
class StockSearchCriteria {
  final String? tickerPrefix;
  final Sector? sector;
  final Industry? industry;
  final MarketCap? minMarketCap;
  final MarketCap? maxMarketCap;
  final int limit;
  final int offset;
  
  const StockSearchCriteria({
    this.tickerPrefix,
    this.sector,
    this.industry,
    this.minMarketCap,
    this.maxMarketCap,
    this.limit = 50,
    this.offset = 0,
  });
}
```

### Repository Implementation

```dart
class PostgresStockRepository implements StockRepository {
  final Database _database;
  final StockMapper _mapper;
  
  const PostgresStockRepository({
    required Database database,
    required StockMapper mapper,
  }) : _database = database,
       _mapper = mapper;
  
  @override
  Future<Either<RepositoryError, Stock>> findById(StockId id) async {
    try {
      final query = '''
        SELECT * FROM stocks 
        WHERE id = @id AND deleted_at IS NULL
      ''';
      
      final result = await _database.query(
        query,
        parameters: {'id': id.value},
      );
      
      if (result.isEmpty) {
        return left(NotFoundError(
          entity: 'Stock',
          id: id.value,
        ));
      }
      
      final stockDto = StockDto.fromJson(result.first);
      final stock = _mapper.toDomain(stockDto);
      
      return stock.fold(
        (error) => left(MappingError(
          entity: 'Stock',
          cause: error.toString(),
        )),
        (stock) => right(stock),
      );
    } catch (e) {
      return left(DatabaseError(
        operation: 'findById',
        cause: e.toString(),
      ));
    }
  }
  
  @override
  Future<Either<RepositoryError, void>> save(Stock stock) async {
    try {
      final dto = _mapper.toDto(stock);
      
      final query = '''
        INSERT INTO stocks (id, ticker, name, sector, industry, created_at, updated_at)
        VALUES (@id, @ticker, @name, @sector, @industry, @created_at, @updated_at)
        ON CONFLICT (id) DO UPDATE SET
          ticker = EXCLUDED.ticker,
          name = EXCLUDED.name,
          sector = EXCLUDED.sector,
          industry = EXCLUDED.industry,
          updated_at = EXCLUDED.updated_at
      ''';
      
      await _database.execute(
        query,
        parameters: dto.toJson(),
      );
      
      return right(null);
    } catch (e) {
      return left(DatabaseError(
        operation: 'save',
        cause: e.toString(),
      ));
    }
  }
}
```

## Testing Patterns

### Test Fixtures

```dart
class StockFixtures {
  static Stock apple() => Stock.create(
    ticker: 'AAPL',
    name: 'Apple Inc.',
    sector: Sector.technology,
    industry: Industry.consumerElectronics,
  ).getOrElse(() => throw 'Invalid fixture');
  
  static Stock microsoft() => Stock.create(
    ticker: 'MSFT',
    name: 'Microsoft Corporation',
    sector: Sector.technology,
    industry: Industry.software,
  ).getOrElse(() => throw 'Invalid fixture');
  
  static Stock invalid() => Stock.create(
    ticker: '',  // Invalid ticker
    name: 'Invalid Stock',
    sector: Sector.technology,
    industry: Industry.software,
  ).getLeft().getOrElse(() => throw 'Should be invalid');
}

class PriceFixtures {
  static Price oneHundred() => Price.create(100.00)
    .getOrElse(() => throw 'Invalid fixture');
    
  static Price fifty() => Price.create(50.00)
    .getOrElse(() => throw 'Invalid fixture');
    
  static Price zero() => Price.zero();
  
  static Price negative() => Price.create(-10.00)
    .getLeft().getOrElse(() => throw 'Should be invalid');
}
```

### Mock Patterns

```dart
class MockStockRepository extends Mock implements StockRepository {}

class MockMarketDataService extends Mock implements MarketDataService {}

// Usage in tests
void main() {
  group('GetStockDetailsUseCase', () {
    late MockStockRepository mockStockRepository;
    late MockMarketDataService mockMarketDataService;
    late GetStockDetailsUseCase useCase;
    
    setUp(() {
      mockStockRepository = MockStockRepository();
      mockMarketDataService = MockMarketDataService();
      useCase = GetStockDetailsUseCase(
        stockRepository: mockStockRepository,
        marketDataService: mockMarketDataService,
      );
    });
    
    test('should return stock details with current price', () async {
      // Arrange
      final stock = StockFixtures.apple();
      final price = PriceFixtures.oneHundred();
      
      when(() => mockStockRepository.findById(stock.id))
        .thenAnswer((_) async => right(stock));
        
      when(() => mockMarketDataService.getCurrentPrice(stock.ticker))
        .thenAnswer((_) async => right(price));
      
      // Act
      final result = await useCase.execute(stockId: stock.id);
      
      // Assert
      expect(result.isRight(), true);
      result.fold(
        (error) => fail('Should not fail'),
        (details) {
          expect(details.stock, equals(stock));
          expect(details.currentPrice, equals(price));
        },
      );
      
      verify(() => mockStockRepository.findById(stock.id)).called(1);
      verify(() => mockMarketDataService.getCurrentPrice(stock.ticker)).called(1);
    });
  });
}
```

## Summary

This pattern library provides the foundation for consistent, high-quality code across the Zenvestor codebase. All agents should reference and use these patterns to ensure:

1. **Consistency**: Same patterns for similar problems
2. **Type Safety**: Compile-time guarantees
3. **Testability**: Easy to test in isolation
4. **Maintainability**: Clear, predictable code structure
5. **Domain Focus**: Business logic clearly expressed

When implementing new features, start by identifying which patterns apply and adapt them to your specific needs while maintaining the core principles.