# Test Writing Guide for Zenvestor

This guide outlines best practices for writing tests in the Zenvestor project using our testing stack: mocktail for mocking, alchemist for golden testing, and custom fixtures for domain-specific test data.

## Table of Contents

1. [Test-Driven Development (TDD) Workflow](#test-driven-development-tdd-workflow)
2. [Using Mocktail for Mocking](#using-mocktail-for-mocking)
3. [Golden Testing with Alchemist](#golden-testing-with-alchemist)
4. [Domain-Specific Test Fixtures](#domain-specific-test-fixtures)
5. [Integration Testing](#integration-testing)
6. [Test Organization](#test-organization)

## Test-Driven Development (TDD) Workflow

Follow this workflow for all new features:

1. **Write a failing test** that defines the expected behavior
2. **Run the test** to ensure it fails (red phase)
3. **Implement minimal code** to make the test pass (green phase)
4. **Refactor** while keeping tests green
5. **Add more tests** for edge cases and error scenarios

### Example TDD Flow

```dart
// Step 1: Write failing test
test('should calculate stock grade based on performance metrics', () {
  final stock = StockBuilder()
      .withSymbol('AAPL')
      .withPerformanceScore(85)
      .build();
  
  expect(stock.grade, equals(Grade.A));
});

// Step 2: Run test - it fails because Grade calculation doesn't exist

// Step 3: Implement minimal code
enum Grade { A, B, C, D, F }

class Stock {
  Grade get grade {
    if (performanceScore >= 80) return Grade.A;
    // ... other grades
  }
}

// Step 4: Refactor if needed
// Step 5: Add edge case tests
```

## Using Mocktail for Mocking

Use mocktail when you need to:
- Mock repository interfaces
- Simulate external service responses
- Control the behavior of dependencies in unit tests

### When to Use Mocks

✅ **DO mock:**
- Repository interfaces
- External API clients
- Services with side effects (email, notifications)
- Time-dependent operations

❌ **DON'T mock:**
- Value objects
- Domain entities
- Pure functions
- Simple data structures

### Mocktail Examples

```dart
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Define mock class
class MockStockRepository extends Mock implements StockRepository {}

void main() {
  late MockStockRepository mockRepository;
  late GetStockBySymbolUseCase useCase;

  setUp(() {
    mockRepository = MockStockRepository();
    useCase = GetStockBySymbolUseCase(mockRepository);
  });

  test('should return stock when repository finds it', () async {
    // Arrange
    final expectedStock = StockFixture.apple();
    when(() => mockRepository.findBySymbol('AAPL'))
        .thenAnswer((_) async => Right(expectedStock));

    // Act
    final result = await useCase.execute('AAPL');

    // Assert
    expect(result.isRight(), true);
    expect(result.getOrElse(() => throw Exception()), equals(expectedStock));
    verify(() => mockRepository.findBySymbol('AAPL')).called(1);
  });

  test('should return failure when repository throws', () async {
    // Arrange
    when(() => mockRepository.findBySymbol(any()))
        .thenAnswer((_) async => Left(NotFoundFailure()));

    // Act
    final result = await useCase.execute('INVALID');

    // Assert
    expect(result.isLeft(), true);
  });
}
```

### Registering Fallback Values

For custom types, register fallback values in `setUpAll`:

```dart
class FakeStock extends Fake implements Stock {}

setUpAll(() {
  registerFallbackValue(FakeStock());
});
```

## Golden Testing with Alchemist

Use alchemist for visual regression testing of Flutter widgets. Golden tests capture screenshots of widgets and compare them against approved versions.

### When to Use Golden Tests

✅ **Golden test these:**
- Complex custom widgets
- Theme-dependent UI
- Charts and visualizations
- Complete screens/pages

❌ **Skip golden tests for:**
- Simple wrappers around Flutter widgets
- Rapidly changing prototypes
- Platform-specific UI

### Alchemist Setup

```dart
import 'package:alchemist/alchemist.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StockGradeIndicator Golden Tests', () {
    goldenTest(
      'renders all grade variations correctly',
      fileName: 'stock_grade_indicator',
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 200),
        children: [
          GoldenTestScenario(
            name: 'Grade A',
            child: StockGradeIndicator(grade: Grade.A),
          ),
          GoldenTestScenario(
            name: 'Grade B',
            child: StockGradeIndicator(grade: Grade.B),
          ),
          // ... other grades
        ],
      ),
    );

    goldenTest(
      'handles theme variations',
      fileName: 'stock_grade_indicator_themes',
      builder: () => GoldenTestGroup(
        children: [
          GoldenTestScenario(
            name: 'Light Theme',
            child: Theme(
              data: ThemeData.light(),
              child: StockGradeIndicator(grade: Grade.A),
            ),
          ),
          GoldenTestScenario(
            name: 'Dark Theme',
            child: Theme(
              data: ThemeData.dark(),
              child: StockGradeIndicator(grade: Grade.A),
            ),
          ),
        ],
      ),
    );
  });
}
```

### Running Golden Tests

```bash
# Generate golden files
flutter test --update-goldens

# Run golden tests
flutter test
```

## Domain-Specific Test Fixtures

Instead of using generic faker data, create domain-specific fixtures that represent realistic business scenarios.

### Fixture Structure

```dart
// test/fixtures/stock_fixtures.dart
class StockFixture {
  static Stock apple() => Stock(
    id: '1',
    symbol: StockSymbol('AAPL'),
    companyName: CompanyName('Apple Inc.'),
    sector: Sector.technology,
    industryGroup: IndustryGroup.hardware,
    grade: Grade.A,
    lastUpdated: DateTime(2024, 1, 15),
  );

  static Stock microsoft() => Stock(
    id: '2',
    symbol: StockSymbol('MSFT'),
    companyName: CompanyName('Microsoft Corporation'),
    sector: Sector.technology,
    industryGroup: IndustryGroup.software,
    grade: Grade.A,
    lastUpdated: DateTime(2024, 1, 15),
  );

  static List<Stock> techStocks() => [
    apple(),
    microsoft(),
    google(),
    amazon(),
  ];

  static List<Stock> diversifiedPortfolio() => [
    apple(),           // Tech
    jpMorgan(),        // Finance
    johnsonJohnson(),  // Healthcare
    walmart(),         // Consumer
  ];
}
```

### Test Data Builders

Use the builder pattern for flexible test data creation:

```dart
class StockBuilder {
  String _id = '1';
  String _symbol = 'TEST';
  String _companyName = 'Test Company';
  Sector _sector = Sector.technology;
  IndustryGroup _industryGroup = IndustryGroup.software;
  Grade _grade = Grade.B;
  DateTime _lastUpdated = DateTime.now();

  StockBuilder withId(String id) {
    _id = id;
    return this;
  }

  StockBuilder withSymbol(String symbol) {
    _symbol = symbol;
    return this;
  }

  StockBuilder withGrade(Grade grade) {
    _grade = grade;
    return this;
  }

  StockBuilder withSectorIndustry(Sector sector, IndustryGroup industry) {
    _sector = sector;
    _industryGroup = industry;
    return this;
  }

  Stock build() => Stock(
    id: _id,
    symbol: StockSymbol(_symbol),
    companyName: CompanyName(_companyName),
    sector: _sector,
    industryGroup: _industryGroup,
    grade: _grade,
    lastUpdated: _lastUpdated,
  );
}

// Usage in tests
final customStock = StockBuilder()
    .withSymbol('GOOGL')
    .withGrade(Grade.A)
    .withSectorIndustry(Sector.technology, IndustryGroup.internet)
    .build();
```

### Edge Case Fixtures

```dart
class EdgeCaseStockFixture {
  static Stock minimalStock() => Stock(
    id: '1',
    symbol: StockSymbol('X'),  // Single character symbol
    companyName: CompanyName('X'),
    sector: Sector.other,
    industryGroup: IndustryGroup.other,
    grade: Grade.F,
    lastUpdated: DateTime(1970, 1, 1),
  );

  static Stock maximalStock() => Stock(
    id: '999999',
    symbol: StockSymbol('ABCDE'),  // Max length symbol
    companyName: CompanyName('A' * 100),  // Max length name
    sector: Sector.technology,
    industryGroup: IndustryGroup.software,
    grade: Grade.A,
    lastUpdated: DateTime(2099, 12, 31),
  );

  static List<Stock> invalidStockAttempts() => [
    // These should be used to test validation
    () => StockBuilder().withSymbol('').build(),       // Empty symbol
    () => StockBuilder().withSymbol('ABC123').build(), // Invalid characters
    () => StockBuilder().withSymbol('ABCDEF').build(), // Too long
  ];
}
```

## Integration Testing

Integration tests verify the complete flow from UI through to the database.

### Serverpod Integration Tests

```dart
// integration_test/stock_endpoint_test.dart
import 'package:integration_test/integration_test.dart';
import 'package:serverpod_test/serverpod_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TestServerpod server;
  late TestClient client;

  setUpAll(() async {
    server = await TestServerpod.create();
    client = TestClient(server);
  });

  tearDownAll(() async {
    await server.close();
  });

  test('should create and retrieve stock', () async {
    // Arrange
    final stock = StockDto(
      symbol: 'AAPL',
      companyName: 'Apple Inc.',
      sector: 'Technology',
      industryGroup: 'Hardware',
    );

    // Act
    final created = await client.stock.create(stock);
    final retrieved = await client.stock.getBySymbol('AAPL');

    // Assert
    expect(created.id, isNotNull);
    expect(retrieved?.symbol, equals('AAPL'));
    expect(retrieved?.companyName, equals('Apple Inc.'));
  });
}
```

### Flutter Integration Tests

```dart
// integration_test/add_stock_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete add stock flow', (tester) async {
    // Start app with test configuration
    await tester.pumpWidget(MyApp(testMode: true));
    await tester.pumpAndSettle();

    // Navigate to add stock screen
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter stock details
    await tester.enterText(find.byKey(Key('symbolField')), 'AAPL');
    await tester.enterText(find.byKey(Key('nameField')), 'Apple Inc.');
    
    // Select sector and industry
    await tester.tap(find.byKey(Key('sectorDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Technology'));
    await tester.pumpAndSettle();

    // Submit form
    await tester.tap(find.byKey(Key('submitButton')));
    await tester.pumpAndSettle();

    // Verify navigation back to list
    expect(find.text('Apple Inc.'), findsOneWidget);
    expect(find.text('AAPL'), findsOneWidget);
  });
}
```

## Test Organization

### Directory Structure

```
zenvestor_server/
├── test/
│   ├── unit/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── use_cases/
│   │   └── infrastructure/
│   │       └── repositories/
│   ├── integration/
│   │   └── endpoints/
│   └── fixtures/
│       ├── stock_fixtures.dart
│       └── portfolio_fixtures.dart

zenvestor_flutter/
├── test/
│   ├── unit/
│   │   ├── view_models/
│   │   └── mappers/
│   ├── widget/
│   │   ├── components/
│   │   └── screens/
│   ├── golden/
│   │   └── goldens/
│   └── fixtures/
└── integration_test/
    └── flows/
```

### Test Naming Conventions

- **Unit tests**: `<class_name>_test.dart`
- **Widget tests**: `<widget_name>_widget_test.dart`
- **Golden tests**: `<component_name>_golden_test.dart`
- **Integration tests**: `<flow_name>_flow_test.dart`

### Test Descriptions

Use descriptive test names that explain the behavior:

```dart
// ✅ Good
test('should return error when stock symbol contains numbers', () {});
test('should calculate portfolio value as sum of all holdings', () {});

// ❌ Bad
test('test stock validation', () {});
test('portfolio calculation', () {});
```

## Running Tests

### All Tests
```bash
# Server
cd zenvestor_server && dart test

# Flutter
cd zenvestor_flutter && flutter test

# Integration
cd zenvestor_flutter && flutter test integration_test
```

### Specific Test Types
```bash
# Unit tests only
flutter test test/unit

# Widget tests only
flutter test test/widget

# Golden tests only
flutter test test/golden

# With coverage
flutter test --coverage
```

### Continuous Integration

Tests should run in this order in CI:
1. Static analysis (`dart analyze --fatal-infos`)
2. Unit tests
3. Widget tests
4. Golden tests
5. Integration tests

## Best Practices Summary

1. **Write tests first** - Follow TDD strictly
2. **Mock at boundaries** - Only mock external dependencies
3. **Use realistic fixtures** - Domain-specific test data over random data
4. **Keep tests focused** - One assertion per test when possible
5. **Test behavior, not implementation** - Tests should survive refactoring
6. **Maintain test quality** - Tests need the same care as production code
7. **Run tests frequently** - Before every commit
8. **Update goldens carefully** - Review visual changes before approving

Remember: Tests are documentation of intended behavior. Write them clearly and maintain them well.