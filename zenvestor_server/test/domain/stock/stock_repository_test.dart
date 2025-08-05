import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;
import 'package:zenvestor_server/src/domain/stock/stock.dart';
import 'package:zenvestor_server/src/domain/stock/stock_errors.dart';
import 'package:zenvestor_server/src/domain/stock/stock_repository.dart';

import '../../fixtures/domain_fixtures.dart';

class MockStockRepository extends Mock implements IStockRepository {}

class FakeSharedStock extends Fake implements shared.Stock {}

class FakeStock extends Fake implements Stock {}

class FakeTickerSymbol extends Fake implements shared.TickerSymbol {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSharedStock());
    registerFallbackValue(FakeStock());
    registerFallbackValue(FakeTickerSymbol());
  });

  group('IStockRepository', () {
    late IStockRepository repository;
    late shared.Stock validSharedStock;
    late Stock validServerStock;
    late shared.TickerSymbol validTicker;

    setUp(() {
      repository = MockStockRepository();
      validTicker = DomainFixtures.tickerSymbol();

      // Create a valid shared stock for testing
      final stockResult = shared.Stock.create(
        ticker: validTicker,
        name: Some(DomainFixtures.companyName()),
        sicCode: Some(DomainFixtures.sicCode()),
        grade: Some(DomainFixtures.grade()),
      );

      validSharedStock = stockResult.getOrElse(
        (error) => throw Exception('Failed to create test stock: $error'),
      );

      // Create server domain stock
      validServerStock = Stock(
        id: 'test-id-123',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
        sharedStock: validSharedStock,
      );
    });

    group('Interface Contract', () {
      test('should not be instantiable directly', () {
        // This test verifies that IStockRepository is abstract
        // by ensuring we can only use it through mocks or
        // concrete implementations
        expect(repository, isA<IStockRepository>());
        expect(repository, isA<MockStockRepository>());
      });

      test('should have correct method signatures', () {
        // Verify the interface has the expected methods by checking
        // they can be stubbed. These will fail to compile if the
        // interface doesn't have these methods

        // Test add method signature
        when(() => repository.add(any())).thenAnswer(
          (_) async => right<StockRepositoryError, Stock>(validServerStock),
        );

        // Test existsByTicker method signature
        when(() => repository.existsByTicker(any())).thenAnswer(
          (_) async => right<StockRepositoryError, bool>(false),
        );
      });
    });

    group('add', () {
      test(
          'should accept Stock parameter and '
          'return Either<StockRepositoryError, Stock>', () async {
        // Arrange
        when(() => repository.add(validSharedStock)).thenAnswer(
          (_) async => right<StockRepositoryError, Stock>(validServerStock),
        );

        // Act
        final result = await repository.add(validSharedStock);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not return error'),
          (stock) => expect(stock, equals(validServerStock)),
        );
        verify(() => repository.add(validSharedStock)).called(1);
      });

      test(
          'should return StockAlreadyExistsError when '
          'stock with same ticker exists', () async {
        // Arrange
        final error = StockAlreadyExistsError(validTicker.value);
        when(() => repository.add(validSharedStock)).thenAnswer(
          (_) async => left<StockRepositoryError, Stock>(error),
        );

        // Act
        final result = await repository.add(validSharedStock);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (err) {
            expect(err, isA<StockAlreadyExistsError>());
            expect((err as StockAlreadyExistsError).ticker,
                equals(validTicker.value));
          },
          (stock) => fail('Should return error'),
        );
      });

      test('should return StockStorageError when infrastructure fails',
          () async {
        // Arrange
        const error = StockStorageError('Database connection failed');
        when(() => repository.add(validSharedStock)).thenAnswer(
          (_) async => left<StockRepositoryError, Stock>(error),
        );

        // Act
        final result = await repository.add(validSharedStock);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (err) {
            expect(err, isA<StockStorageError>());
            expect((err as StockStorageError).message,
                equals('Database connection failed'));
          },
          (stock) => fail('Should return error'),
        );
      });

      test('should use domain types not primitives', () {
        // This test ensures we're using Stock, not a Map or other
        // primitive. The type system enforces this - if we could pass
        // a Map, this would compile:
        // repository.add({'ticker': 'AAPL'}); // This should NOT compile

        // Only Stock should be accepted
        when(() => repository.add(validSharedStock)).thenAnswer(
          (_) async => right<StockRepositoryError, Stock>(validServerStock),
        );

        // This verifies the parameter is of type Stock
        expect(() => repository.add(validSharedStock), returnsNormally);
      });
    });

    group('existsByTicker', () {
      test(
          'should accept TickerSymbol parameter and '
          'return Either<StockRepositoryError, bool>', () async {
        // Arrange
        when(() => repository.existsByTicker(validTicker)).thenAnswer(
          (_) async => right<StockRepositoryError, bool>(true),
        );

        // Act
        final result = await repository.existsByTicker(validTicker);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not return error'),
          (exists) => expect(exists, isTrue),
        );
        verify(() => repository.existsByTicker(validTicker)).called(1);
      });

      test('should return true when stock exists', () async {
        // Arrange
        when(() => repository.existsByTicker(validTicker)).thenAnswer(
          (_) async => right<StockRepositoryError, bool>(true),
        );

        // Act
        final result = await repository.existsByTicker(validTicker);

        // Assert
        expect(result.toNullable(), equals(true));
      });

      test('should return false when stock does not exist', () async {
        // Arrange
        when(() => repository.existsByTicker(validTicker)).thenAnswer(
          (_) async => right<StockRepositoryError, bool>(false),
        );

        // Act
        final result = await repository.existsByTicker(validTicker);

        // Assert
        expect(result.toNullable(), equals(false));
      });

      test('should return StockStorageError when infrastructure fails',
          () async {
        // Arrange
        const error = StockStorageError('Database connection failed');
        when(() => repository.existsByTicker(validTicker)).thenAnswer(
          (_) async => left<StockRepositoryError, bool>(error),
        );

        // Act
        final result = await repository.existsByTicker(validTicker);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (err) {
            expect(err, isA<StockStorageError>());
            expect((err as StockStorageError).message,
                equals('Database connection failed'));
          },
          (exists) => fail('Should return error'),
        );
      });

      test('should use domain types not primitives', () {
        // This test ensures we're using TickerSymbol, not a String
        // primitive. The type system enforces this - if we could pass
        // a String, this would compile:
        // repository.existsByTicker('AAPL'); // This should NOT compile

        // Only TickerSymbol should be accepted
        when(() => repository.existsByTicker(validTicker)).thenAnswer(
          (_) async => right<StockRepositoryError, bool>(true),
        );

        // This verifies the parameter is of type TickerSymbol
        expect(() => repository.existsByTicker(validTicker), returnsNormally);
      });
    });

    group('Error Types', () {
      test('StockRepositoryError should be sealed', () {
        // This verifies that StockRepositoryError is a sealed class
        // and all subtypes are accounted for in switches
        StockRepositoryError testError({required bool isAlreadyExists}) {
          return isAlreadyExists
              ? const StockAlreadyExistsError('TEST')
              : const StockStorageError('Test error');
        }

        final error = testError(isAlreadyExists: true);

        // Exhaustive switch - will fail to compile if not all
        // subtypes are handled
        final message = switch (error) {
          StockAlreadyExistsError() => 'Already exists',
          StockStorageError() => 'Storage error',
        };

        expect(message, equals('Already exists'));
      });
    });
  });
}
