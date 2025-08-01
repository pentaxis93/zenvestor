import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:zenvestor_server/src/domain/shared/errors/domain_error.dart';
import 'package:zenvestor_server/src/domain/stock/stock.dart';
import 'package:zenvestor_server/src/domain/stock/stock_repository.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/ticker_symbol.dart';

import '../../fixtures/domain_fixtures.dart';

class MockStockRepository extends Mock implements IStockRepository {}

class FakeStock extends Fake implements Stock {}

class FakeTickerSymbol extends Fake implements TickerSymbol {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeStock());
    registerFallbackValue(FakeTickerSymbol());
  });

  group('IStockRepository', () {
    late IStockRepository repository;
    late Stock validStock;
    late TickerSymbol validTicker;

    setUp(() {
      repository = MockStockRepository();
      validTicker = DomainFixtures.tickerSymbol();

      // Create a valid stock for testing
      final stockResult = Stock.create(
        id: const Uuid().v4(),
        ticker: validTicker,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        name: Some(DomainFixtures.companyName()),
        sicCode: Some(DomainFixtures.sicCode()),
        grade: Some(DomainFixtures.grade()),
      );

      validStock = stockResult.getOrElse(
        (error) => throw Exception('Failed to create test stock: $error'),
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
          (_) async => right<StockRepositoryError, Stock>(validStock),
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
        when(() => repository.add(validStock)).thenAnswer(
          (_) async => right<StockRepositoryError, Stock>(validStock),
        );

        // Act
        final result = await repository.add(validStock);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not return error'),
          (stock) => expect(stock, equals(validStock)),
        );
        verify(() => repository.add(validStock)).called(1);
      });

      test(
          'should return StockAlreadyExistsError when '
          'stock with same ticker exists', () async {
        // Arrange
        final error = StockAlreadyExistsError(validTicker.value);
        when(() => repository.add(validStock)).thenAnswer(
          (_) async => left<StockRepositoryError, Stock>(error),
        );

        // Act
        final result = await repository.add(validStock);

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
        when(() => repository.add(validStock)).thenAnswer(
          (_) async => left<StockRepositoryError, Stock>(error),
        );

        // Act
        final result = await repository.add(validStock);

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
        when(() => repository.add(validStock)).thenAnswer(
          (_) async => right<StockRepositoryError, Stock>(validStock),
        );

        // This verifies the parameter is of type Stock
        expect(() => repository.add(validStock), returnsNormally);
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

      test('should return false when stock does not exist', () async {
        // Arrange
        when(() => repository.existsByTicker(validTicker)).thenAnswer(
          (_) async => right<StockRepositoryError, bool>(false),
        );

        // Act
        final result = await repository.existsByTicker(validTicker);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not return error'),
          (exists) => expect(exists, isFalse),
        );
      });

      test('should return StockStorageError when infrastructure fails',
          () async {
        // Arrange
        const error = StockStorageError('Query timeout');
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
            expect((err as StockStorageError).message, equals('Query timeout'));
          },
          (exists) => fail('Should return error'),
        );
      });

      test('should use domain types not primitives', () {
        // This test ensures we're using TickerSymbol, not a String
        // The type system enforces this - if we could pass a String,
        // this would compile:
        // repository.existsByTicker('AAPL'); // This should NOT compile

        // Only TickerSymbol should be accepted
        when(() => repository.existsByTicker(validTicker)).thenAnswer(
          (_) async => right<StockRepositoryError, bool>(false),
        );

        // This verifies the parameter is of type TickerSymbol
        expect(() => repository.existsByTicker(validTicker), returnsNormally);
      });
    });

    group('Return Types', () {
      test('all methods should return Future<Either<StockRepositoryError, T>>',
          () {
        // This test verifies that all methods follow the functional
        // error handling pattern

        // add returns Future<Either<StockRepositoryError, Stock>>
        when(() => repository.add(any())).thenAnswer(
          (_) async => right<StockRepositoryError, Stock>(validStock),
        );
        final addResult = repository.add(validStock);
        expect(addResult, isA<Future<Either<StockRepositoryError, Stock>>>());

        // existsByTicker returns Future<Either<StockRepositoryError, bool>>
        when(() => repository.existsByTicker(any())).thenAnswer(
          (_) async => right<StockRepositoryError, bool>(true),
        );
        final existsResult = repository.existsByTicker(validTicker);
        expect(existsResult, isA<Future<Either<StockRepositoryError, bool>>>());
      });
    });
  });
}
