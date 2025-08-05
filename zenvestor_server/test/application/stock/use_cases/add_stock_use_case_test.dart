import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;
import 'package:zenvestor_server/src/application/shared/errors/application_error.dart';
import 'package:zenvestor_server/src/application/stock/dtos/add_stock_request.dart';
import 'package:zenvestor_server/src/application/stock/dtos/add_stock_response.dart';
import 'package:zenvestor_server/src/application/stock/use_cases/add_stock_use_case.dart';
import 'package:zenvestor_server/src/domain/stock/stock.dart';
import 'package:zenvestor_server/src/domain/stock/stock_errors.dart';
import 'package:zenvestor_server/src/domain/stock/stock_repository.dart';

class MockStockRepository extends Mock implements IStockRepository {}

class FakeTickerSymbol extends Fake implements shared.TickerSymbol {}

class FakeSharedStock extends Fake implements shared.Stock {}

class FakeStock extends Fake implements Stock {}

void main() {
  late MockStockRepository mockRepository;
  late AddStockUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeTickerSymbol());
    registerFallbackValue(FakeSharedStock());
    registerFallbackValue(FakeStock());
  });

  setUp(() {
    mockRepository = MockStockRepository();
    useCase = AddStockUseCase(repository: mockRepository);
  });

  group('AddStockUseCase', () {
    group('execute', () {
      test('should return AddStockResponse when stock is successfully added',
          () async {
        // Arrange
        const request = AddStockRequest(ticker: 'AAPL');
        final tickerSymbol = shared.TickerSymbol.create('AAPL').toNullable()!;
        final sharedStock = shared.Stock.create(
          ticker: tickerSymbol,
        ).toNullable()!;
        final serverStock = Stock(
          id: 'test-id-123',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
          sharedStock: sharedStock,
        );

        when(() => mockRepository.existsByTicker(any()))
            .thenAnswer((_) async => right(false));
        when(() => mockRepository.add(any()))
            .thenAnswer((_) async => right(serverStock));

        // Act
        final result = await useCase.execute(request);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Expected success but got $error'),
          (response) {
            expect(response, isA<AddStockResponse>());
            expect(response.id, equals('test-id-123'));
            expect(response.ticker, 'AAPL');
            expect(response.createdAt, equals(DateTime(2024)));
            expect(response.updatedAt, equals(DateTime(2024)));
          },
        );

        verify(() => mockRepository.existsByTicker(tickerSymbol)).called(1);
        verify(() => mockRepository.add(any())).called(1);
      });

      test('should return StockAlreadyExistsApplicationError when stock exists',
          () async {
        // Arrange
        const request = AddStockRequest(ticker: 'AAPL');
        final tickerSymbol = shared.TickerSymbol.create('AAPL').toNullable()!;

        when(() => mockRepository.existsByTicker(any()))
            .thenAnswer((_) async => right(true));

        // Act
        final result = await useCase.execute(request);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<StockAlreadyExistsApplicationError>());
            final typedError = error as StockAlreadyExistsApplicationError;
            expect(typedError.ticker, 'AAPL');
          },
          (response) => fail('Expected error but got $response'),
        );

        verify(() => mockRepository.existsByTicker(tickerSymbol)).called(1);
        verifyNever(() => mockRepository.add(any()));
      });

      test('should return StockValidationApplicationError for empty ticker',
          () async {
        // Arrange
        const request = AddStockRequest(ticker: '');

        // Act
        final result = await useCase.execute(request);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<StockValidationApplicationError>());
            final typedError = error as StockValidationApplicationError;
            expect(typedError.message, contains('required'));
          },
          (response) => fail('Expected error but got $response'),
        );

        verifyNever(() => mockRepository.existsByTicker(any()));
        verifyNever(() => mockRepository.add(any()));
      });

      test(
          'should return StockValidationApplicationError '
          'for invalid ticker format', () async {
        // Arrange
        const request = AddStockRequest(ticker: 'AAPL123');

        // Act
        final result = await useCase.execute(request);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<StockValidationApplicationError>());
            final typedError = error as StockValidationApplicationError;
            expect(typedError.message, contains('uppercase letters'));
          },
          (response) => fail('Expected error but got $response'),
        );

        verifyNever(() => mockRepository.existsByTicker(any()));
        verifyNever(() => mockRepository.add(any()));
      });

      test('should return StockValidationApplicationError for ticker too long',
          () async {
        // Arrange
        const request = AddStockRequest(ticker: 'TOOLONG');

        // Act
        final result = await useCase.execute(request);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<StockValidationApplicationError>());
            final typedError = error as StockValidationApplicationError;
            expect(typedError.message, contains('at most 5 characters'));
          },
          (response) => fail('Expected error but got $response'),
        );

        verifyNever(() => mockRepository.existsByTicker(any()));
        verifyNever(() => mockRepository.add(any()));
      });

      test(
          'should return StockStorageApplicationError '
          'when repository add fails', () async {
        // Arrange
        const request = AddStockRequest(ticker: 'AAPL');
        final tickerSymbol = shared.TickerSymbol.create('AAPL').toNullable()!;
        const storageError = StockStorageError('Database connection failed');

        when(() => mockRepository.existsByTicker(any()))
            .thenAnswer((_) async => right(false));
        when(() => mockRepository.add(any()))
            .thenAnswer((_) async => left(storageError));

        // Act
        final result = await useCase.execute(request);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<StockStorageApplicationError>());
            final typedError = error as StockStorageApplicationError;
            expect(typedError.message, 'Database connection failed');
          },
          (response) => fail('Expected error but got $response'),
        );

        verify(() => mockRepository.existsByTicker(tickerSymbol)).called(1);
        verify(() => mockRepository.add(any())).called(1);
      });

      test(
          'should return StockStorageApplicationError '
          'when existsByTicker fails', () async {
        // Arrange
        const request = AddStockRequest(ticker: 'AAPL');
        final tickerSymbol = shared.TickerSymbol.create('AAPL').toNullable()!;
        const storageError = StockStorageError('Network timeout');

        when(() => mockRepository.existsByTicker(any()))
            .thenAnswer((_) async => left(storageError));

        // Act
        final result = await useCase.execute(request);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<StockStorageApplicationError>());
            final typedError = error as StockStorageApplicationError;
            expect(typedError.message, 'Network timeout');
          },
          (response) => fail('Expected error but got $response'),
        );

        verify(() => mockRepository.existsByTicker(tickerSymbol)).called(1);
        verifyNever(() => mockRepository.add(any()));
      });

      test('should normalize ticker symbol to uppercase', () async {
        // Arrange
        const request = AddStockRequest(ticker: 'aapl');
        final tickerSymbol = shared.TickerSymbol.create('aapl').toNullable()!;
        final sharedStock = shared.Stock.create(
          ticker: tickerSymbol,
        ).toNullable()!;
        final serverStock = Stock(
          id: 'test-id-456',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
          sharedStock: sharedStock,
        );

        when(() => mockRepository.existsByTicker(any()))
            .thenAnswer((_) async => right(false));
        when(() => mockRepository.add(any()))
            .thenAnswer((_) async => right(serverStock));

        // Act
        final result = await useCase.execute(request);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Expected success but got $error'),
          (response) {
            expect(response.ticker, 'AAPL'); // Should be normalized
          },
        );
      });

      test('should handle whitespace in ticker input', () async {
        // Arrange
        const request = AddStockRequest(ticker: '  AAPL  ');
        final tickerSymbol =
            shared.TickerSymbol.create('  AAPL  ').toNullable()!;
        final sharedStock = shared.Stock.create(
          ticker: tickerSymbol,
        ).toNullable()!;
        final serverStock = Stock(
          id: 'test-id-789',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
          sharedStock: sharedStock,
        );

        when(() => mockRepository.existsByTicker(any()))
            .thenAnswer((_) async => right(false));
        when(() => mockRepository.add(any()))
            .thenAnswer((_) async => right(serverStock));

        // Act
        final result = await useCase.execute(request);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Expected success but got $error'),
          (response) {
            expect(response.ticker, 'AAPL'); // Should be trimmed
          },
        );
      });

      test(
          'should return StockAlreadyExistsApplicationError '
          'when repository returns StockAlreadyExistsError', () async {
        // Arrange
        const request = AddStockRequest(ticker: 'AAPL');
        final tickerSymbol = shared.TickerSymbol.create('AAPL').toNullable()!;
        const alreadyExistsError = StockAlreadyExistsError('AAPL');

        when(() => mockRepository.existsByTicker(any()))
            .thenAnswer((_) async => right(false));
        when(() => mockRepository.add(any()))
            .thenAnswer((_) async => left(alreadyExistsError));

        // Act
        final result = await useCase.execute(request);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<StockAlreadyExistsApplicationError>());
            final typedError = error as StockAlreadyExistsApplicationError;
            expect(typedError.ticker, 'AAPL');
          },
          (response) => fail('Expected error but got $response'),
        );

        verify(() => mockRepository.existsByTicker(tickerSymbol)).called(1);
        verify(() => mockRepository.add(any())).called(1);
      });

      test('should successfully add single-character ticker symbols', () async {
        // Arrange
        const request = AddStockRequest(ticker: 'A');
        final tickerSymbol = shared.TickerSymbol.create('A').toNullable()!;
        final sharedStock = shared.Stock.create(
          ticker: tickerSymbol,
        ).toNullable()!;
        final serverStock = Stock(
          id: 'test-id-999',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
          sharedStock: sharedStock,
        );

        when(() => mockRepository.existsByTicker(any()))
            .thenAnswer((_) async => right(false));
        when(() => mockRepository.add(any()))
            .thenAnswer((_) async => right(serverStock));

        // Act
        final result = await useCase.execute(request);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Expected success but got $error'),
          (response) {
            expect(response.ticker, 'A');
          },
        );
      });
    });
  });
}
