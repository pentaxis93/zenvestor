# Comprehensive Error Handling Patterns for Zenvestor

This document provides the complete guide to error handling patterns used across all Zenvestor agents. All agents must follow these patterns to ensure consistency and maintainability.

## Core Error Handling Philosophy

1. **Errors are values, not exceptions**
2. **Make impossible states unrepresentable**
3. **Fail fast with descriptive errors**
4. **Errors should guide users to solutions**

## The Hybrid Validation Error Pattern

All Zenvestor domain objects use a hybrid approach that combines:
- Sealed classes for error types (compile-time safety)
- Error codes for serialization (runtime flexibility)
- Descriptive messages for debugging

### Pattern Structure

```dart
import 'package:fpdart/fpdart.dart';

// 1. Define sealed error hierarchy
sealed class StockError {
  const StockError();
  
  String get message;
  String get code;
}

// 2. Implement specific error types
class InvalidTickerError extends StockError {
  final String attemptedTicker;
  final String reason;
  
  const InvalidTickerError({
    required this.attemptedTicker, 
    required this.reason,
  });
  
  @override
  String get message => 'Invalid ticker "$attemptedTicker": $reason';
  
  @override
  String get code => 'INVALID_TICKER';
}

// 3. Create smart constructors returning Either
class Stock {
  final String ticker;
  
  const Stock._(this.ticker);
  
  static Either<StockError, Stock> create(String ticker) {
    if (ticker.isEmpty) {
      return left(InvalidTickerError(
        attemptedTicker: ticker,
        reason: 'Ticker cannot be empty',
      ));
    }
    
    if (ticker.length > 5) {
      return left(InvalidTickerError(
        attemptedTicker: ticker,
        reason: 'Ticker cannot exceed 5 characters',
      ));
    }
    
    return right(Stock._(ticker.toUpperCase()));
  }
}
```

## Error Categories and Patterns

### 1. Validation Errors

Used for domain rule violations and input validation.

```dart
sealed class ValidationError {
  const ValidationError();
}

class RangeError extends ValidationError {
  final num actualValue;
  final num minValue;
  final num maxValue;
  
  String get message => 
    'Value $actualValue is outside valid range [$minValue, $maxValue]';
}

class FormatError extends ValidationError {
  final String value;
  final String expectedFormat;
  final String? example;
  
  String get message => example != null
    ? 'Invalid format for "$value". Expected: $expectedFormat (e.g., $example)'
    : 'Invalid format for "$value". Expected: $expectedFormat';
}
```

### 2. Business Rule Errors

Used for domain logic violations and state machine errors.

```dart
sealed class BusinessRuleError {
  const BusinessRuleError();
}

class InvalidStateTransitionError extends BusinessRuleError {
  final String currentState;
  final String attemptedTransition;
  final List<String> allowedTransitions;
  
  String get message => 
    'Cannot $attemptedTransition from $currentState state. '
    'Allowed transitions: ${allowedTransitions.join(", ")}';
}

class InvariantViolationError extends BusinessRuleError {
  final String invariant;
  final String context;
  
  String get message => 
    'Invariant violation: $invariant in context: $context';
}
```

### 3. Integration Errors

Used for external system failures and infrastructure issues.

```dart
sealed class IntegrationError {
  const IntegrationError();
}

class ApiError extends IntegrationError {
  final int? statusCode;
  final String endpoint;
  final String? responseBody;
  
  String get message => statusCode != null
    ? 'API error $statusCode from $endpoint'
    : 'API error from $endpoint: connection failed';
}

class DatabaseError extends IntegrationError {
  final String operation;
  final String? details;
  
  String get message => 
    'Database error during $operation${details != null ? ": $details" : ""}';
}
```

## Error Composition Patterns

### Combining Multiple Validations

```dart
static Either<ValueError, CompositeValue> create(
  String part1,
  String part2,
  int quantity,
) {
  // Validate each component
  final validatedPart1 = NonEmptyString.create(part1);
  final validatedPart2 = NonEmptyString.create(part2);
  final validatedQuantity = PositiveInt.create(quantity);
  
  // Combine validations
  return validatedPart1.flatMap((p1) =>
    validatedPart2.flatMap((p2) =>
      validatedQuantity.map((q) =>
        CompositeValue._(p1, p2, q)
      )
    )
  );
}
```

### Collecting Multiple Errors

```dart
static Either<List<ValidationError>, ValidatedForm> validate(
  Map<String, dynamic> formData,
) {
  final errors = <ValidationError>[];
  
  // Validate each field
  final name = NonEmptyString.create(formData['name'] ?? '');
  if (name.isLeft()) {
    errors.add(FieldError(field: 'name', reason: 'Required field'));
  }
  
  final email = Email.create(formData['email'] ?? '');
  if (email.isLeft()) {
    errors.add(FieldError(field: 'email', reason: 'Invalid email format'));
  }
  
  // Return errors or success
  return errors.isEmpty
    ? right(ValidatedForm._(
        name: name.getOrElse(() => throw 'Unreachable'),
        email: email.getOrElse(() => throw 'Unreachable'),
      ))
    : left(errors);
}
```

## Error Recovery Patterns

### Providing Defaults

```dart
final result = StockPrice.create(userInput)
  .getOrElse(() => StockPrice.zero());
```

### Transforming Errors

```dart
final result = repository.findStock(ticker)
  .mapLeft((dbError) => DomainError(
    message: 'Could not load stock data',
    cause: dbError,
  ));
```

### Chain of Fallbacks

```dart
final price = await primaryApi.getPrice(ticker)
  .alt(() => secondaryApi.getPrice(ticker))
  .alt(() => cache.getPrice(ticker))
  .getOrElse(() => StockPrice.unknown());
```

## Testing Error Scenarios

### Test Every Error Path

```dart
group('validation errors', () {
  test('should return EmptyValueError for empty string', () {
    final result = NonEmptyString.create('');
    
    expect(result.isLeft(), true);
    result.fold(
      (error) => expect(error, isA<EmptyValueError>()),
      (_) => fail('Should not succeed'),
    );
  });
  
  test('should return LengthError for string exceeding max length', () {
    final tooLong = 'a' * 256;
    final result = ShortString.create(tooLong);
    
    expect(result.isLeft(), true);
    result.fold(
      (error) {
        expect(error, isA<LengthError>());
        expect(error.actualLength, 256);
        expect(error.maxLength, 255);
      },
      (_) => fail('Should not succeed'),
    );
  });
});
```

### Test Error Messages

```dart
test('should provide helpful error message with context', () {
  final result = Email.create('not-an-email');
  
  result.fold(
    (error) {
      expect(error.message, contains('not-an-email'));
      expect(error.message, contains('valid email format'));
      expect(error.message, contains('@'));
    },
    (_) => fail('Should not succeed'),
  );
});
```

## Error Documentation

### Document Error Conditions

```dart
/// Creates a new [StockPrice] instance.
/// 
/// Returns [Either<PriceError, StockPrice>] where:
/// - [NegativePriceError] if price < 0
/// - [ExcessivePriceError] if price > 1,000,000
/// - [PricePrecisionError] if more than 4 decimal places
/// 
/// Example:
/// ```dart
/// final price = StockPrice.create(99.99);
/// price.fold(
///   (error) => print('Invalid: ${error.message}'),
///   (price) => print('Valid price: \$${price.value}'),
/// );
/// ```
static Either<PriceError, StockPrice> create(double value) {
  // Implementation
}
```

## Anti-Patterns to Avoid

### 1. Generic Errors
```dart
// ❌ BAD: No context about what failed
return left(ValidationError('Invalid input'));

// ✅ GOOD: Specific error with context
return left(InvalidTickerError(
  attemptedTicker: input,
  reason: 'Contains invalid characters',
));
```

### 2. String-Based Errors
```dart
// ❌ BAD: Stringly-typed errors
return left('INVALID_EMAIL');

// ✅ GOOD: Type-safe errors
return left(InvalidEmailError(
  value: input,
  reason: 'Missing @ symbol',
));
```

### 3. Throwing Exceptions
```dart
// ❌ BAD: Throwing exceptions for validation
if (value < 0) {
  throw ArgumentError('Value cannot be negative');
}

// ✅ GOOD: Returning error values
if (value < 0) {
  return left(NegativeValueError(value: value));
}
```

### 4. Error Codes Without Context
```dart
// ❌ BAD: Just an error code
return left(ErrorCode.E1001);

// ✅ GOOD: Error with full context
return left(StockNotFoundError(
  ticker: ticker,
  searchedMarkets: ['NYSE', 'NASDAQ'],
));
```

## Integration with Infrastructure

### Serializing Errors for APIs

```dart
extension ErrorSerialization on DomainError {
  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'details': when(
      validation: (field, reason) => {'field': field, 'reason': reason},
      business: (rule, context) => {'rule': rule, 'context': context},
      integration: (system, cause) => {'system': system, 'cause': cause},
    ),
  };
}
```

### Logging Errors

```dart
extension ErrorLogging on DomainError {
  void log(Logger logger) {
    when(
      validation: (field, reason) => 
        logger.info('Validation failed for $field: $reason'),
      business: (rule, context) => 
        logger.warning('Business rule violated: $rule in $context'),
      integration: (system, cause) => 
        logger.error('Integration error with $system: $cause'),
    );
  }
}
```

## Summary

All Zenvestor agents must:
1. Use the hybrid validation pattern for all domain objects
2. Return Either types from factories and methods that can fail
3. Create specific error types for each failure scenario
4. Include all context needed to debug and fix issues
5. Test every error path with appropriate assertions
6. Document error conditions in public APIs

This ensures our codebase maintains high quality error handling that makes debugging easier and improves the developer experience.