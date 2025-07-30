# Test-Driven Development Principles for Zenvestor Agents

This document defines the unified TDD approach that all Zenvestor agents must follow when implementing domain objects, use cases, and features.

## Core TDD Cycle

All agents follow the Red-Green-Refactor cycle:

1. **Red**: Write a failing test that defines expected behavior
2. **Green**: Write minimal code to make the test pass
3. **Refactor**: Improve code quality while keeping tests green

## Universal Test Structure

```dart
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('FeatureName', () {
    // Setup
    late MockDependency mockDependency;
    
    setUp(() {
      mockDependency = MockDependency();
    });
    
    // Test categories
    group('creation', () {
      test('should create valid instance with correct values', () {
        // Arrange
        const expectedValue = 'test';
        
        // Act
        final result = Feature.create(expectedValue);
        
        // Assert
        expect(result.isRight(), true);
        result.fold(
          (error) => fail('Should not fail'),
          (feature) => expect(feature.value, expectedValue),
        );
      });
    });
    
    group('validation', () {
      test('should fail with specific error for invalid input', () {
        // Test each validation rule
      });
    });
    
    group('behavior', () {
      test('should perform expected action', () {
        // Test business logic
      });
    });
  });
}
```

## Testing Priorities by Agent Type

### Value Object Engineer
1. **Validation Rules** (100% coverage required)
   - Each validation rule gets its own test
   - Test boundary conditions
   - Test error messages are specific and helpful

2. **Factory Methods**
   - Success paths with valid inputs
   - Failure paths with invalid inputs
   - Edge cases and special formats

3. **Equality and Comparison**
   - Value equality tests
   - Ordering tests if applicable

### Domain Entity Engineer
1. **State Transitions**
   - Valid state changes
   - Invalid state transitions
   - State machine completeness

2. **Business Rules**
   - Invariant protection
   - Aggregate consistency
   - Domain event generation

3. **Behavior Methods**
   - Command methods change state correctly
   - Query methods don't modify state
   - Side effects are explicit

### Domain Error Engineer
1. **Error Creation**
   - Each error scenario has dedicated error type
   - Error contains all context needed for debugging
   - Error messages are actionable

2. **Error Handling**
   - Errors compose well with Either type
   - Recovery strategies are testable
   - Error aggregation works correctly

### Code Review Expert
1. **Pattern Compliance**
   - Tests verify DDD patterns are followed
   - Clean Architecture boundaries respected
   - No infrastructure leakage

## Test Data Best Practices

### Use Domain-Specific Fixtures
```dart
// ❌ BAD: Generic faker data
final price = faker.randomGenerator.decimal();

// ✅ GOOD: Domain-specific test data
final price = StockPriceFixture.valid();
final invalidPrice = StockPriceFixture.negative();
```

### Fixture Organization
```
test/
├── fixtures/
│   ├── stock_fixtures.dart
│   ├── portfolio_fixtures.dart
│   └── value_object_fixtures.dart
├── unit/
├── widget/
└── integration/
```

## Test Naming Conventions

### Unit Tests
```dart
test('should [expected behavior] when [condition]', () {});
test('should return error when [invalid scenario]', () {});
test('should throw when [exceptional case]', () {});
```

### Widget Tests
```dart
testWidgets('should display [element] when [state]', (tester) async {});
testWidgets('should navigate to [screen] when [action]', (tester) async {});
```

### Integration Tests
```dart
test('should complete [workflow] successfully', () {});
test('should handle [error scenario] gracefully', () {});
```

## Coverage Requirements

1. **Minimum 80% coverage** for all production code
2. **100% coverage** for:
   - Value object validation
   - Domain entity state machines
   - Error handling paths
   - Public API methods

3. **Acceptable exclusions**:
   - Generated code
   - Simple getters/setters
   - toString/hashCode implementations

## Testing Anti-Patterns to Avoid

### 1. Testing Implementation Details
```dart
// ❌ BAD: Testing private methods or internal state
test('should set internal flag', () {
  entity._internalFlag = true;
  expect(entity._internalFlag, true);
});

// ✅ GOOD: Testing observable behavior
test('should be in active state after activation', () {
  final entity = entity.activate();
  expect(entity.isActive, true);
});
```

### 2. Overmocking
```dart
// ❌ BAD: Mocking value objects
final mockPrice = MockStockPrice();
when(() => mockPrice.value).thenReturn(100.0);

// ✅ GOOD: Using real value objects
final price = StockPrice.create(100.0).getOrElse(() => throw 'Invalid');
```

### 3. Multiple Assertions Without Context
```dart
// ❌ BAD: Multiple unrelated assertions
test('should work correctly', () {
  expect(result.isValid, true);
  expect(result.value, 42);
  expect(result.timestamp, isNotNull);
});

// ✅ GOOD: Focused tests with clear intent
test('should create valid result with correct value', () {
  expect(result.value, 42);
});

test('should set timestamp on creation', () {
  expect(result.timestamp, isNotNull);
});
```

## Integration with CI/CD

All agents must ensure their generated code:

1. Passes `dart analyze --fatal-infos`
2. Achieves required coverage thresholds
3. Follows team formatting standards
4. Includes tests in CI pipeline

## Measuring Test Quality

Good tests are:
- **Fast**: Run in milliseconds, not seconds
- **Isolated**: Don't depend on external state
- **Repeatable**: Same result every time
- **Self-validating**: Clear pass/fail
- **Timely**: Written before production code

## TDD Workflow Integration

1. Agent receives requirement
2. Agent writes failing test capturing requirement
3. Agent implements minimum code to pass
4. Agent refactors for clarity
5. Agent verifies all tests still pass
6. Agent commits with descriptive message

This cycle repeats for each requirement, building up comprehensive test coverage that documents the system's behavior.