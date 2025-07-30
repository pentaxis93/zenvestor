# Core Design Principles for Zenvestor Development

This document defines the fundamental design principles that guide all development decisions across Zenvestor agents. These principles ensure we build maintainable, focused, and valuable software.

## YAGNI (You Aren't Gonna Need It)

The most important principle for avoiding over-engineering and maintaining simplicity.

### Definition
Don't implement functionality until it's actually needed, not when you think you might need it.

### Application in Zenvestor

#### ✅ DO
- Implement only what's required for current user stories
- Create interfaces with only the methods currently used
- Add properties only when they serve an immediate purpose
- Write code that solves today's problems

#### ❌ DON'T
- Add "nice to have" features without requirements
- Create generic solutions for hypothetical future needs
- Include computed properties "just in case"
- Build abstractions for single use cases

### Examples

```dart
// ❌ BAD: Speculative generalization
abstract class DataStore<T> {
  Future<T> get(String id);
  Future<void> put(T item);
  Future<void> delete(String id);
  Future<List<T>> query(Query query);
  Future<void> batch(List<Operation> ops);
  Stream<T> watch(String id);
  // ... 10 more methods for "future flexibility"
}

// ✅ GOOD: What we actually need now
abstract class StockRepository {
  Future<Either<Error, Stock>> findByTicker(Ticker ticker);
  Future<Either<Error, void>> save(Stock stock);
}
```

```dart
// ❌ BAD: Computed properties without use
interface LengthValidationError {
  int get actualLength;
  int get maxLength;
  int get excessLength => actualLength - maxLength; // Not used anywhere!
  double get percentageOver => (excessLength / maxLength) * 100; // Speculative!
}

// ✅ GOOD: Only what's needed
interface LengthValidationError {
  int get actualLength;
  int get maxLength;
  String get fieldContext;
}
```

## KISS (Keep It Simple, Stupid)

Simplicity should be a key goal in design, and unnecessary complexity should be avoided.

### Application in Zenvestor

- Prefer clear, straightforward code over clever solutions
- Use well-known patterns instead of inventing new ones
- Choose readable names over short ones
- Avoid deep nesting and complex conditionals

### Examples

```dart
// ❌ BAD: Overly clever
final result = items
  .where((i) => i.active)
  .fold<Map<String, List<Item>>>({}, (map, item) => 
    map..[item.category] = (map[item.category] ?? [])..add(item))
  .entries
  .where((e) => e.value.length > 1)
  .map((e) => e.key);

// ✅ GOOD: Clear and simple
final categoryGroups = <String, List<Item>>{};
for (final item in items) {
  if (item.active) {
    categoryGroups.putIfAbsent(item.category, () => []).add(item);
  }
}
final duplicateCategories = categoryGroups.entries
  .where((entry) => entry.value.length > 1)
  .map((entry) => entry.key);
```

## DRY (Don't Repeat Yourself)

Every piece of knowledge must have a single, unambiguous, authoritative representation within a system.

### Application in Zenvestor

- Extract common validation patterns into shared interfaces
- Create reusable value objects for domain concepts
- Use shared test fixtures instead of duplicating test data
- Centralize business rules in domain entities

### Examples

```dart
// ❌ BAD: Duplicated validation logic
class EmailAddress {
  static Either<Error, EmailAddress> create(String input) {
    if (!input.contains('@') || !input.contains('.')) {
      return left(InvalidEmailError());
    }
    // ...
  }
}

class UserRegistration {
  void validateEmail(String email) {
    if (!email.contains('@') || !email.contains('.')) {
      throw ValidationException('Invalid email');
    }
  }
}

// ✅ GOOD: Single source of truth
class EmailAddress {
  static Either<EmailError, EmailAddress> create(String input) {
    // Single validation implementation
  }
}

class UserRegistration {
  Either<Error, void> register(String emailStr, ...) {
    return EmailAddress.create(emailStr).flatMap((email) => 
      // Use the validated email
    );
  }
}
```

## SOLID Principles

### Single Responsibility Principle (SRP)
A class should have one, and only one, reason to change.

```dart
// ❌ BAD: Multiple responsibilities
class StockService {
  // Database operations
  Future<void> saveStock(Stock stock) { }
  
  // API calls
  Future<Price> fetchPrice(Ticker ticker) { }
  
  // Business logic
  double calculatePE(Stock stock) { }
  
  // Formatting
  String formatForDisplay(Stock stock) { }
}

// ✅ GOOD: Single responsibility
class StockRepository { } // Persistence
class MarketDataService { } // External API
class StockAnalyzer { } // Business calculations
class StockFormatter { } // Display formatting
```

### Open/Closed Principle (OCP)
Software entities should be open for extension but closed for modification.

```dart
// ✅ GOOD: Extensible through abstraction
abstract class PricingStrategy {
  Money calculatePrice(Order order);
}

class StandardPricing implements PricingStrategy { }
class PremiumPricing implements PricingStrategy { }
class DiscountPricing implements PricingStrategy { }
```

### Liskov Substitution Principle (LSP)
Objects of a superclass should be replaceable with objects of subclasses without breaking the application.

### Interface Segregation Principle (ISP)
No code should be forced to depend on methods it does not use.

```dart
// ❌ BAD: Fat interface
abstract class Repository<T> {
  Future<T> findById(String id);
  Future<List<T>> findAll();
  Future<void> save(T item);
  Future<void> delete(String id);
  Future<void> bulkInsert(List<T> items);
  Future<int> count();
  Stream<T> watch();
}

// ✅ GOOD: Segregated interfaces
abstract class Readable<T> {
  Future<Either<Error, T>> findById(String id);
}

abstract class Writable<T> {
  Future<Either<Error, void>> save(T item);
}
```

### Dependency Inversion Principle (DIP)
Depend on abstractions, not concretions.

## Tell, Don't Ask

Objects should tell each other what to do, not ask for data and then act on it.

### Examples

```dart
// ❌ BAD: Asking for data
if (order.status == 'pending' && order.paymentId != null) {
  order.status = 'confirmed';
  order.confirmedAt = DateTime.now();
}

// ✅ GOOD: Telling to perform action
final result = order.confirmPayment(paymentId);
```

## Fail Fast

Detect and report errors as early as possible.

### Examples

```dart
// ✅ GOOD: Validate at construction
class Price {
  static Either<PriceError, Price> create(double value) {
    if (value < 0) {
      return left(NegativePriceError(value: value));
    }
    return right(Price._(value));
  }
}

// ❌ BAD: Defer validation
class Price {
  final double value;
  Price(this.value); // Allows invalid state
  
  bool validate() => value >= 0; // Checked later, maybe
}
```

## Composition Over Inheritance

Favor object composition over class inheritance for code reuse.

### Examples

```dart
// ❌ BAD: Deep inheritance hierarchy
class Entity { }
class AuditableEntity extends Entity { }
class VersionedAuditableEntity extends AuditableEntity { }
class Stock extends VersionedAuditableEntity { }

// ✅ GOOD: Composition
class Stock {
  final StockId id;
  final AuditInfo auditInfo;
  final VersionInfo versionInfo;
}
```

## Principle of Least Surprise

Code should behave in ways that users expect.

### Examples

```dart
// ❌ BAD: Surprising behavior
class Portfolio {
  void addStock(Stock stock) {
    stocks.add(stock);
    // Surprise! Also saves to database
    database.save(this);
  }
}

// ✅ GOOD: Expected behavior
class Portfolio {
  Either<Error, Portfolio> addStock(Stock stock) {
    // Returns new instance, no side effects
    return right(Portfolio._(
      stocks: [...stocks, stock],
    ));
  }
}
```

## Make Impossible States Unrepresentable

Use the type system to prevent invalid states.

### Examples

```dart
// ❌ BAD: Invalid states possible
class Order {
  String status; // 'pending', 'confirmed', 'shipped', etc.
  DateTime? confirmedAt; // Might be set when status != 'confirmed'
  DateTime? shippedAt; // Might be set incorrectly
}

// ✅ GOOD: Type-safe states
sealed class OrderState { }
class PendingOrder extends OrderState { }
class ConfirmedOrder extends OrderState {
  final DateTime confirmedAt;
  final PaymentId paymentId;
}
class ShippedOrder extends OrderState {
  final DateTime shippedAt;
  final TrackingNumber trackingNumber;
}
```

## Pragmatic Application

### When to Apply Principles

1. **Always Apply**:
   - YAGNI - Never build features without requirements
   - Fail Fast - Validate early and clearly
   - Type Safety - Make invalid states unrepresentable

2. **Apply Thoughtfully**:
   - DRY - Only when there's true duplication of knowledge
   - SOLID - When complexity justifies the abstraction
   - Composition - When inheritance creates deep hierarchies

3. **Balance Required**:
   - Perfect adherence vs. shipping features
   - Ideal patterns vs. team familiarity
   - Future flexibility vs. current simplicity

### Code Review Checklist

When reviewing code, ask:
- [ ] Is this solving a real, current problem? (YAGNI)
- [ ] Is this the simplest solution that works? (KISS)
- [ ] Is domain knowledge centralized? (DRY)
- [ ] Does each class have one clear purpose? (SRP)
- [ ] Are dependencies on abstractions? (DIP)
- [ ] Would another developer be surprised? (Least Surprise)
- [ ] Are invalid states prevented by types? (Type Safety)

## Anti-Patterns to Avoid

See `.claude/agents/shared/anti-patterns.md` for detailed examples of what NOT to do.

## Conclusion

These principles are tools, not rules. Apply them pragmatically to create code that is:
- Maintainable
- Testable  
- Understandable
- Focused on current needs
- Open to future changes

Remember: The best code is often the code you didn't write (YAGNI).