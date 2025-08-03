import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:zenvestor_server/src/application/shared/errors/application_error.dart';
import 'package:zenvestor_server/src/application/stock/dtos/add_stock_request.dart'
    as app_dto;
import 'package:zenvestor_server/src/application/stock/dtos/add_stock_response.dart'
    as app_dto;
import 'package:zenvestor_server/src/application/stock/use_cases/add_stock_use_case.dart';
import 'package:zenvestor_server/src/endpoints/stock_endpoint.dart';
import 'package:zenvestor_server/src/generated/protocols/stock/add_stock_request.dart';
import 'package:zenvestor_server/src/generated/protocols/stock/add_stock_response.dart';
import 'package:zenvestor_server/src/generated/protocols/stock/stock_duplicate_exception.dart';
import 'package:zenvestor_server/src/generated/protocols/stock/stock_service_exception.dart';
import 'package:zenvestor_server/src/generated/protocols/stock/stock_validation_exception.dart';
import 'package:zenvestor_server/src/generated/protocols/stock/stock_validation_type.dart';

class MockAddStockUseCase extends Mock implements AddStockUseCase {}

class MockSession extends Mock implements Session {}

// Test-specific endpoint that allows injecting the use case
class TestableStockEndpoint extends StockEndpoint {
  TestableStockEndpoint(this.testUseCase);

  final AddStockUseCase testUseCase;

  @override
  Future<AddStockResponse> addStock(
    Session session,
    AddStockRequest request,
  ) async {
    // Override to use injected use case instead of creating one
    addStockUseCase = testUseCase;
    return super.addStock(session, request);
  }
}

class FakeAddStockRequest extends Fake implements app_dto.AddStockRequest {}

void main() {
  late MockAddStockUseCase mockUseCase;
  late StockEndpoint endpoint;
  late MockSession mockSession;

  setUpAll(() {
    registerFallbackValue(FakeAddStockRequest());
  });

  setUp(() {
    mockUseCase = MockAddStockUseCase();
    // Use testable endpoint that allows injecting the use case
    endpoint = TestableStockEndpoint(mockUseCase);
    mockSession = MockSession();
  });

  group('StockEndpoint', () {
    group('addStock', () {
      test('should return AddStockResponse on successful stock creation',
          () async {
        // Arrange
        final request = AddStockRequest(ticker: 'AAPL');
        final stockId = const Uuid().v4();
        final now = DateTime.now();
        final appResponse = app_dto.AddStockResponse(
          id: stockId,
          ticker: 'AAPL',
          createdAt: now,
          updatedAt: now,
        );

        when(() => mockUseCase.execute(any()))
            .thenAnswer((_) async => Right(appResponse));

        // Act
        final result = await endpoint.addStock(mockSession, request);

        // Assert
        expect(result, isA<AddStockResponse>());
        expect(result.id, stockId);
        expect(result.ticker, 'AAPL');
        expect(result.companyName, isNull);
        expect(result.sicCode, isNull);
        expect(result.grade, isNull);
        expect(result.createdAt, now);
        expect(result.updatedAt, now);

        // Verify the use case was called with correct parameters
        final capturedRequest = verify(
          () => mockUseCase.execute(captureAny()),
        ).captured.single as app_dto.AddStockRequest;
        expect(capturedRequest.ticker, 'AAPL');
      });

      test('should throw StockValidationException on validation error',
          () async {
        // Arrange
        final request = AddStockRequest(ticker: 'INVALID123');
        const validationError = StockValidationApplicationError(
          message: 'Ticker must contain only uppercase letters',
        );

        when(() => mockUseCase.execute(any()))
            .thenAnswer((_) async => const Left(validationError));

        // Act & Assert
        expect(
          () => endpoint.addStock(mockSession, request),
          throwsA(
            isA<StockValidationException>()
                .having(
                  (e) => e.message,
                  'message',
                  'Ticker must contain only uppercase letters',
                )
                .having((e) => e.fieldName, 'fieldName', 'ticker')
                .having(
                  (e) => e.validationType,
                  'validationType',
                  StockValidationType.invalidFormat,
                ),
          ),
        );

        verify(() => mockUseCase.execute(any())).called(1);
      });

      test('should throw StockDuplicateException when stock already exists',
          () async {
        // Arrange
        final request = AddStockRequest(ticker: 'AAPL');
        const alreadyExistsError = StockAlreadyExistsApplicationError('AAPL');

        when(() => mockUseCase.execute(any()))
            .thenAnswer((_) async => const Left(alreadyExistsError));

        // Act & Assert
        expect(
          () => endpoint.addStock(mockSession, request),
          throwsA(
            isA<StockDuplicateException>()
                .having((e) => e.ticker, 'ticker', 'AAPL')
                .having(
                  (e) => e.message,
                  'message',
                  'Stock with ticker AAPL already exists',
                ),
          ),
        );

        verify(() => mockUseCase.execute(any())).called(1);
      });

      test('should throw StockServiceException on storage error', () async {
        // Arrange
        final request = AddStockRequest(ticker: 'AAPL');
        const storageError = StockStorageApplicationError(
          'Database connection failed',
        );

        when(() => mockUseCase.execute(any()))
            .thenAnswer((_) async => const Left(storageError));

        // Act & Assert
        expect(
          () => endpoint.addStock(mockSession, request),
          throwsA(
            isA<StockServiceException>().having(
              (e) => e.message,
              'message',
              'Database connection failed',
            ),
          ),
        );

        verify(() => mockUseCase.execute(any())).called(1);
      });

      test(
          'should throw StockServiceException when storage error has null '
          'message', () async {
        // Arrange
        final request = AddStockRequest(ticker: 'AAPL');
        const storageError = StockStorageApplicationError();

        when(() => mockUseCase.execute(any()))
            .thenAnswer((_) async => const Left(storageError));

        // Act & Assert
        expect(
          () => endpoint.addStock(mockSession, request),
          throwsA(
            isA<StockServiceException>().having(
              (e) => e.message,
              'message',
              'Service temporarily unavailable',
            ),
          ),
        );

        verify(() => mockUseCase.execute(any())).called(1);
      });

      test('should pass through the ticker value from request to use case',
          () async {
        // Arrange
        final request = AddStockRequest(ticker: 'MSFT');
        final stockId = const Uuid().v4();
        final now = DateTime.now();
        final appResponse = app_dto.AddStockResponse(
          id: stockId,
          ticker: 'MSFT',
          createdAt: now,
          updatedAt: now,
        );

        when(() => mockUseCase.execute(any()))
            .thenAnswer((_) async => Right(appResponse));

        // Act
        await endpoint.addStock(mockSession, request);

        // Assert
        final capturedRequest = verify(
          () => mockUseCase.execute(captureAny()),
        ).captured.single as app_dto.AddStockRequest;
        expect(capturedRequest.ticker, 'MSFT');
      });

      test('should handle lowercase ticker input', () async {
        // Arrange
        final request = AddStockRequest(ticker: 'aapl');
        final stockId = const Uuid().v4();
        final now = DateTime.now();
        final appResponse = app_dto.AddStockResponse(
          id: stockId,
          ticker: 'AAPL', // Use case normalizes to uppercase
          createdAt: now,
          updatedAt: now,
        );

        when(() => mockUseCase.execute(any()))
            .thenAnswer((_) async => Right(appResponse));

        // Act
        final result = await endpoint.addStock(mockSession, request);

        // Assert
        expect(result.ticker, 'AAPL');

        final capturedRequest = verify(
          () => mockUseCase.execute(captureAny()),
        ).captured.single as app_dto.AddStockRequest;
        expect(capturedRequest.ticker, 'aapl');
      });

      test('should handle ticker with whitespace', () async {
        // Arrange
        final request = AddStockRequest(ticker: '  AAPL  ');
        final stockId = const Uuid().v4();
        final now = DateTime.now();
        final appResponse = app_dto.AddStockResponse(
          id: stockId,
          ticker: 'AAPL', // Use case trims whitespace
          createdAt: now,
          updatedAt: now,
        );

        when(() => mockUseCase.execute(any()))
            .thenAnswer((_) async => Right(appResponse));

        // Act
        final result = await endpoint.addStock(mockSession, request);

        // Assert
        expect(result.ticker, 'AAPL');

        final capturedRequest = verify(
          () => mockUseCase.execute(captureAny()),
        ).captured.single as app_dto.AddStockRequest;
        expect(capturedRequest.ticker, '  AAPL  ');
      });

      test('should handle single-character ticker symbols', () async {
        // Arrange
        final request = AddStockRequest(ticker: 'A');
        final stockId = const Uuid().v4();
        final now = DateTime.now();
        final appResponse = app_dto.AddStockResponse(
          id: stockId,
          ticker: 'A',
          createdAt: now,
          updatedAt: now,
        );

        when(() => mockUseCase.execute(any()))
            .thenAnswer((_) async => Right(appResponse));

        // Act
        final result = await endpoint.addStock(mockSession, request);

        // Assert
        expect(result.ticker, 'A');
      });

      test('should handle empty ticker with validation error', () async {
        // Arrange
        final request = AddStockRequest(ticker: '');
        const validationError = StockValidationApplicationError(
          message: 'Ticker is required',
        );

        when(() => mockUseCase.execute(any()))
            .thenAnswer((_) async => const Left(validationError));

        // Act & Assert
        expect(
          () => endpoint.addStock(mockSession, request),
          throwsA(
            isA<StockValidationException>()
                .having((e) => e.message, 'message', 'Ticker is required')
                .having((e) => e.fieldName, 'fieldName', 'ticker')
                .having(
                  (e) => e.validationType,
                  'validationType',
                  StockValidationType.emptyField,
                ),
          ),
        );
      });

      test('should handle ticker that is too long', () async {
        // Arrange
        final request = AddStockRequest(ticker: 'TOOLONG');
        const validationError = StockValidationApplicationError(
          message: 'Ticker must be at most 5 characters',
        );

        when(() => mockUseCase.execute(any()))
            .thenAnswer((_) async => const Left(validationError));

        // Act & Assert
        expect(
          () => endpoint.addStock(mockSession, request),
          throwsA(
            isA<StockValidationException>()
                .having(
                  (e) => e.message,
                  'message',
                  'Ticker must be at most 5 characters',
                )
                .having((e) => e.fieldName, 'fieldName', 'ticker')
                .having(
                  (e) => e.validationType,
                  'validationType',
                  StockValidationType.tooLong,
                ),
          ),
        );
      });
    });

    group('real endpoint (lazy initialization)', () {
      test('should lazily initialize use case on first call', () {
        // Test the real endpoint without injected use case to cover lazy init
        final realEndpoint = StockEndpoint();

        // Mock the session to throw an error when accessing db
        final lazySession = MockSession();
        when(() => lazySession.db).thenThrow(
          Exception('Test exception to verify lazy initialization'),
        );

        // This should trigger lazy initialization and then fail
        expect(
          () => realEndpoint.addStock(
            lazySession,
            AddStockRequest(ticker: 'TEST'),
          ),
          throwsA(isA<Exception>()),
        );

        // The test ensures the lazy initialization path is covered
        // by forcing an error after initialization
      });
    });
  });
}
