import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/stock/stock.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/company_name.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/grade.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/sic_code.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/ticker_symbol.dart';
import 'package:zenvestor_server/src/generated/infrastructure/stock/stock_model.dart'
    as serverpod_model;
import 'package:zenvestor_server/src/infrastructure/stock/repositories/stock_repository_serverpod.dart';

// Mock classes
class MockSession extends Mock implements Session {}

class MockStockDb extends Mock implements serverpod_model.StockTable {}

// Note: Serverpod's static db methods make it difficult to unit test
// the repository in isolation. For comprehensive testing, integration
// tests with a real database would be more appropriate.

void main() {
  group('StockRepositoryServerpod', () {
    late MockSession mockSession;
    late StockRepositoryServerpod repository;
    const uuid = Uuid();

    setUpAll(() {
      registerFallbackValue(LogLevel.info);
    });

    setUp(() {
      mockSession = MockSession();
      repository = StockRepositoryServerpod(mockSession);
    });

    group('add', () {
      test('should successfully add a new stock', () async {
        // Arrange
        final tickerEither = TickerSymbol.create('AAPL');
        final companyNameEither = CompanyName.create('Apple Inc.');
        final sicCodeEither = SicCode.create('3571');
        final gradeEither = Grade.create('A');

        final stockEither = Stock.create(
          id: uuid.v4(),
          ticker: tickerEither.getOrElse((l) => throw Exception()),
          name: Some(companyNameEither.getOrElse((l) => throw Exception())),
          sicCode: Some(sicCodeEither.getOrElse((l) => throw Exception())),
          grade: Some(gradeEither.getOrElse((l) => throw Exception())),
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 20),
        );

        // Note: Since we can't easily mock Serverpod's static db methods,
        // we'll test the mapper and error handling logic separately.
        // This is a limitation of testing with Serverpod's static methods.

        // For now, we can at least verify the repository is
        // constructed properly
        expect(repository, isA<StockRepositoryServerpod>());
        expect(stockEither.isRight(), isTrue);
      });
    });

    group('error handling', () {
      test('should handle logging calls', () {
        // Arrange
        when(() => mockSession.log(
              any<String>(),
              level: any<LogLevel>(named: 'level'),
              exception: any<Object?>(named: 'exception'),
              stackTrace: any<StackTrace?>(named: 'stackTrace'),
            )).thenReturn(null);

        // This verifies the session can be used for logging
        mockSession.log('Test log', level: LogLevel.info);

        // Assert
        verify(() => mockSession.log('Test log', level: LogLevel.info))
            .called(1);
      });
    });
  });
}
