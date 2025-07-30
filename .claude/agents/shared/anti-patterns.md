# Common Anti-Patterns to Avoid in Zenvestor Development

This document catalogs anti-patterns that all agents must avoid. Each anti-pattern includes recognition criteria, examples, and the correct approach.

## Domain Layer Anti-Patterns

### 1. Anemic Domain Model

**Recognition**: Entities with only getters/setters and no behavior.

```dart
// ❌ ANTI-PATTERN: Anemic model
class User {
  String id;
  String email;
  String status;
  
  User({required this.id, required this.email, required this.status});
}

// Behavior is outside the model
class UserService {
  void activateUser(User user) {
    user.status = 'active';
  }
}
```

```dart
// ✅ CORRECT: Rich domain model
class User {
  final UserId id;
  final Email email;
  final UserStatus status;
  
  const User._({required this.id, required this.email, required this.status});
  
  Either<UserError, User> activate() {
    if (status != UserStatus.pending) {
      return left(InvalidStateError(
        current: status,
        attempted: 'activate',
      ));
    }
    return right(copyWith(status: UserStatus.active));
  }
}
```

### 2. Primitive Obsession

**Recognition**: Using primitive types for domain concepts.

```dart
// ❌ ANTI-PATTERN: Primitives everywhere
class Stock {
  String ticker;      // Should be Ticker value object
  double price;       // Should be Price value object  
  String exchange;    // Should be Exchange value object
  int sharesOutstanding; // Should be Quantity value object
}

// Problems:
// - No validation
// - No type safety
// - Business logic scattered
```

```dart
// ✅ CORRECT: Value objects for domain concepts
class Stock {
  final Ticker ticker;
  final Price currentPrice;
  final Exchange exchange;
  final Quantity sharesOutstanding;
  
  // All validation happens in value objects
  static Either<StockError, Stock> create({
    required String ticker,
    required double price,
    required String exchange,
    required int shares,
  }) {
    return Ticker.create(ticker).flatMap((t) =>
      Price.create(price).flatMap((p) =>
        Exchange.create(exchange).flatMap((e) =>
          Quantity.create(shares).map((s) =>
            Stock._(
              ticker: t,
              currentPrice: p,
              exchange: e,
              sharesOutstanding: s,
            )
          )
        )
      )
    );
  }
}
```

### 3. Domain Logic in Wrong Layer

**Recognition**: Business rules in controllers, services, or infrastructure.

```dart
// ❌ ANTI-PATTERN: Validation in controller
class StockController {
  Response addStock(Request request) {
    final ticker = request.body['ticker'];
    
    // Domain logic in controller!
    if (ticker == null || ticker.length > 5) {
      return Response.badRequest('Invalid ticker');
    }
    
    if (!RegExp(r'^[A-Z]+$').hasMatch(ticker)) {
      return Response.badRequest('Ticker must be uppercase');
    }
    
    // More domain logic that doesn't belong here...
  }
}
```

```dart
// ✅ CORRECT: Domain logic in domain layer
class StockController {
  Response addStock(Request request) {
    final result = Stock.create(
      ticker: request.body['ticker'] ?? '',
      // other fields...
    );
    
    return result.fold(
      (error) => Response.badRequest(error.message),
      (stock) => Response.ok(stock.toJson()),
    );
  }
}
```

## Error Handling Anti-Patterns

### 4. Throwing Exceptions for Validation

**Recognition**: Using throw for expected failures.

```dart
// ❌ ANTI-PATTERN: Exceptions for validation
class Email {
  final String value;
  
  Email(String value) {
    if (!value.contains('@')) {
      throw ArgumentError('Invalid email'); // Don't throw!
    }
    this.value = value;
  }
}

// Forces try-catch everywhere
try {
  final email = Email(userInput);
} catch (e) {
  // Handle error
}
```

```dart
// ✅ CORRECT: Return Either for expected failures
class Email {
  final String value;
  
  const Email._(this.value);
  
  static Either<EmailError, Email> create(String value) {
    if (!value.contains('@')) {
      return left(InvalidEmailFormat(value: value));
    }
    return right(Email._(value));
  }
}

// Clean error handling
final result = Email.create(userInput);
result.fold(
  (error) => showError(error.message),
  (email) => processEmail(email),
);
```

### 5. Generic Error Messages

**Recognition**: Errors without context or actionable information.

```dart
// ❌ ANTI-PATTERN: Useless error messages
return left(ValidationError('Invalid'));
return left(Error('Failed'));
return left(DomainError('Bad input'));
```

```dart
// ✅ CORRECT: Specific, actionable errors
return left(InvalidPriceError(
  value: -10.50,
  reason: 'Price cannot be negative',
  suggestion: 'Use a positive value or zero',
));

return left(TickerFormatError(
  value: 'aapl',
  expectedFormat: 'UPPERCASE',
  example: 'AAPL',
));
```

### 6. Swallowing Errors

**Recognition**: Ignoring errors or converting them to nulls/defaults.

```dart
// ❌ ANTI-PATTERN: Hiding errors
Future<Stock?> getStock(String ticker) async {
  try {
    return await repository.find(ticker);
  } catch (e) {
    return null; // Error information lost!
  }
}

// ❌ ANTI-PATTERN: Silent defaults
final price = Price.create(input).getOrElse(() => Price.zero());
// User never knows their input was invalid!
```

```dart
// ✅ CORRECT: Propagate errors properly
Future<Either<StockError, Stock>> getStock(Ticker ticker) async {
  final result = await repository.find(ticker);
  return result.mapLeft((dbError) => 
    StockNotFoundError(ticker: ticker, cause: dbError)
  );
}

// ✅ CORRECT: Explicit error handling
final result = Price.create(input);
result.fold(
  (error) => showValidationError(error),
  (price) => processPrice(price),
);
```

## Testing Anti-Patterns

### 7. Testing Implementation Details

**Recognition**: Tests that break when refactoring without changing behavior.

```dart
// ❌ ANTI-PATTERN: Testing privates
test('should set internal flag', () {
  final entity = MyEntity();
  entity._internalFlag = true; // Accessing private!
  expect(entity._internalFlag, true);
});

// ❌ ANTI-PATTERN: Testing exact error messages
test('should show error', () {
  final result = Email.create('bad');
  expect(result.getLeft(), 'Invalid email format'); // Brittle!
});
```

```dart
// ✅ CORRECT: Test behavior, not implementation
test('should be active after activation', () {
  final entity = MyEntity.create().activate();
  expect(entity.isActive, true);
});

// ✅ CORRECT: Test error types, not messages
test('should return InvalidEmailFormat error', () {
  final result = Email.create('bad');
  result.fold(
    (error) => expect(error, isA<InvalidEmailFormat>()),
    (_) => fail('Should not succeed'),
  );
});
```

### 8. Insufficient Test Coverage

**Recognition**: Missing edge cases, error paths, or state transitions.

```dart
// ❌ ANTI-PATTERN: Only happy path tested
test('should create email', () {
  final email = Email.create('test@example.com');
  expect(email.isRight(), true);
});
// Missing: empty, no @, too long, special chars, etc.
```

```dart
// ✅ CORRECT: Comprehensive test coverage
group('Email creation', () {
  test('should succeed with valid email', () {
    final result = Email.create('test@example.com');
    expect(result.isRight(), true);
  });
  
  test('should fail when empty', () {
    final result = Email.create('');
    expect(result.isLeft(), true);
  });
  
  test('should fail without @ symbol', () {
    final result = Email.create('testexample.com');
    expect(result.isLeft(), true);
  });
  
  test('should fail when too long', () {
    final result = Email.create('a' * 255 + '@example.com');
    expect(result.isLeft(), true);
  });
  
  // ... more edge cases
});
```

### 9. Test Doubles for Value Objects

**Recognition**: Mocking immutable value objects.

```dart
// ❌ ANTI-PATTERN: Mocking value objects
class MockEmail extends Mock implements Email {}

test('should process email', () {
  final mockEmail = MockEmail();
  when(() => mockEmail.value).thenReturn('test@example.com');
  
  // This is unnecessarily complex!
});
```

```dart
// ✅ CORRECT: Use real value objects
test('should process email', () {
  final email = Email.create('test@example.com')
    .getOrElse(() => throw 'Test data should be valid');
  
  // Use the real object - it's immutable and safe!
});
```

## Architecture Anti-Patterns

### 10. Circular Dependencies

**Recognition**: Layers depending on each other circularly.

```dart
// ❌ ANTI-PATTERN: Domain depends on infrastructure
// In domain/stock.dart
import 'package:zenvestor/infrastructure/database.dart';

class Stock {
  Future<void> save() async {
    await Database.insert(this); // Domain shouldn't know about DB!
  }
}
```

```dart
// ✅ CORRECT: Dependency inversion
// In domain/stock_repository.dart
abstract class StockRepository {
  Future<Either<Error, void>> save(Stock stock);
}

// In infrastructure/postgres_stock_repository.dart
class PostgresStockRepository implements StockRepository {
  @override
  Future<Either<Error, void>> save(Stock stock) async {
    // Database-specific implementation
  }
}
```

### 11. Leaky Abstractions

**Recognition**: Infrastructure details leaking into domain.

```dart
// ❌ ANTI-PATTERN: SQL in domain layer
class Portfolio {
  List<Stock> getStocks(String sqlWhere) { // SQL leak!
    // ...
  }
}

// ❌ ANTI-PATTERN: HTTP codes in domain
class StockError {
  final int httpStatus; // HTTP leak!
}
```

```dart
// ✅ CORRECT: Domain-specific abstractions
class Portfolio {
  List<Stock> getStocksBySector(Sector sector) {
    // Domain-specific query
  }
}

class StockNotFoundError extends StockError {
  // No infrastructure details
}
```

### 12. Smart UI Anti-Pattern

**Recognition**: Business logic in UI components.

```dart
// ❌ ANTI-PATTERN: Business logic in widget
class StockPriceWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    // Business logic in UI!
    final isPriceValid = price > 0 && price < 10000;
    final formattedPrice = '\$${price.toStringAsFixed(2)}';
    final priceChange = (currentPrice - previousPrice) / previousPrice * 100;
    
    return Text(formattedPrice);
  }
}
```

```dart
// ✅ CORRECT: UI only displays, domain handles logic
class StockPriceWidget extends StatelessWidget {
  final StockPrice price; // Domain object with logic
  
  Widget build(BuildContext context) {
    return Text(price.formatted); // Domain object formats itself
  }
}
```

## Code Style Anti-Patterns

### 13. Inconsistent Naming

**Recognition**: Mixed naming conventions and unclear names.

```dart
// ❌ ANTI-PATTERN: Inconsistent naming
class stock_data {}      // snake_case class
class StockData2 {}      // Numbered class
class StkDta {}          // Abbreviated
interface IStockService {} // Hungarian notation
```

```dart
// ✅ CORRECT: Consistent, clear naming
class StockData {}
class StockDataV2 {}     // Version suffix if needed
class StockService {}    // No I prefix in Dart
class StockRepository {} // Clear, full names
```

### 14. Magic Numbers and Strings

**Recognition**: Hardcoded values without explanation.

```dart
// ❌ ANTI-PATTERN: Magic values
if (price > 1000000) { // What's special about 1M?
  return error('INVALID_PRICE'); // Magic string
}

if (ticker.length > 5) { // Why 5?
  return false;
}
```

```dart
// ✅ CORRECT: Named constants with meaning
class StockConstraints {
  static const maxPrice = 1000000; // NYSE circuit breaker limit
  static const maxTickerLength = 5; // NYSE ticker format
}

class StockErrorCodes {
  static const invalidPrice = 'INVALID_PRICE';
}

if (price > StockConstraints.maxPrice) {
  return error(StockErrorCodes.invalidPrice);
}
```

### 15. God Objects

**Recognition**: Classes that do too much.

```dart
// ❌ ANTI-PATTERN: Class with too many responsibilities
class StockService {
  // Validation
  bool validateTicker(String ticker) {}
  bool validatePrice(double price) {}
  
  // Database operations
  Future<void> saveStock(Stock stock) {}
  Future<Stock> loadStock(String id) {}
  
  // API calls
  Future<double> fetchPrice(String ticker) {}
  Future<List<News>> fetchNews(String ticker) {}
  
  // Calculations
  double calculatePE(Stock stock) {}
  double calculateMarketCap(Stock stock) {}
  
  // Formatting
  String formatPrice(double price) {}
  String formatTicker(String ticker) {}
  
  // ... 50 more methods
}
```

```dart
// ✅ CORRECT: Single responsibility
class StockValidator {
  Either<Error, ValidatedStock> validate(RawStock raw) {}
}

class StockRepository {
  Future<Either<Error, Stock>> save(Stock stock) {}
  Future<Either<Error, Stock>> findById(StockId id) {}
}

class MarketDataService {
  Future<Either<Error, Price>> getCurrentPrice(Ticker ticker) {}
}

class StockCalculator {
  PriceEarningsRatio calculatePE(Stock stock, Earnings earnings) {}
}
```

## Performance Anti-Patterns

### 16. Premature Optimization

**Recognition**: Complex code for unproven performance gains.

```dart
// ❌ ANTI-PATTERN: Over-optimizing without measurement
class StockCache {
  final _l1Cache = <String, Stock>{};
  final _l2Cache = <String, WeakReference<Stock>>{};
  final _bloomFilter = BloomFilter<String>();
  
  Stock? get(String id) {
    if (!_bloomFilter.mightContain(id)) {
      return null; // Probably unnecessary complexity
    }
    // Complex multi-level cache logic...
  }
}
```

```dart
// ✅ CORRECT: Simple solution first
class StockCache {
  final _cache = <StockId, Stock>{};
  
  Stock? get(StockId id) => _cache[id];
  void put(StockId id, Stock stock) => _cache[id] = stock;
}
// Optimize only after profiling shows need
```

### 17. N+1 Query Problem

**Recognition**: Loading related data in loops.

```dart
// ❌ ANTI-PATTERN: Query in loop
Future<List<PortfolioValue>> getPortfolioValues(List<Portfolio> portfolios) async {
  final values = <PortfolioValue>[];
  
  for (final portfolio in portfolios) {
    // N+1 queries!
    final stocks = await stockRepo.findByPortfolioId(portfolio.id);
    for (final stock in stocks) {
      final price = await priceService.getPrice(stock.ticker);
      // More queries...
    }
  }
  return values;
}
```

```dart
// ✅ CORRECT: Batch loading
Future<List<PortfolioValue>> getPortfolioValues(List<Portfolio> portfolios) async {
  // Load all data in batch
  final allStocks = await stockRepo.findByPortfolioIds(
    portfolios.map((p) => p.id).toList()
  );
  
  final allPrices = await priceService.getPrices(
    allStocks.map((s) => s.ticker).toSet().toList()
  );
  
  // Process without additional queries
  return _calculateValues(portfolios, allStocks, allPrices);
}
```

## Summary

These anti-patterns represent the most common mistakes in domain-driven design and clean architecture. All agents must:

1. **Recognize** these patterns in existing code
2. **Avoid** introducing them in new code
3. **Refactor** them when encountered
4. **Educate** through code reviews

Remember: The goal is maintainable, testable, and understandable code that accurately models the business domain.