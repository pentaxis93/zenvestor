import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:zenvestor_server/src/domain/stock/stock.dart';
import 'package:zenvestor_server/src/domain/stock/stock_errors.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/company_name.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/grade.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/sic_code.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/ticker_symbol.dart';
import 'package:zenvestor_server/src/generated/infrastructure/stock/stock_model.dart'
    as serverpod_model;
import 'package:zenvestor_server/src/infrastructure/stock/mappers/stock_mapper.dart';

void main() {
  group('StockMapper', () {
    const uuid = Uuid();

    group('toDomain', () {
      test(
          'should successfully map Serverpod Stock to domain Stock '
          'with all fields', () {
        // Arrange
        final stockId = uuid.v4();
        final serverpodStock = serverpod_model.Stock(
          id: 42,
          tickerSymbol: 'AAPL',
          companyName: 'Apple Inc.',
          sicCode: '3571',
          grade: 'A',
          createdAt: DateTime(2024, 1, 15, 10, 30),
          updatedAt: DateTime(2024, 1, 20, 14, 45),
        );

        // Act
        final result = StockMapper.toDomain(serverpodStock, stockId);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Expected success but got error: $error'),
          (stock) {
            expect(stock.id, equals(stockId));
            expect(stock.ticker.value, equals('AAPL'));
            expect(stock.name.isSome(), isTrue);
            stock.name.fold(
              () => fail('Expected company name to be Some'),
              (name) => expect(name.value, equals('Apple Inc.')),
            );
            expect(stock.sicCode.isSome(), isTrue);
            stock.sicCode.fold(
              () => fail('Expected sicCode to be Some'),
              (sicCode) => expect(sicCode.value, equals('3571')),
            );
            expect(stock.grade.isSome(), isTrue);
            stock.grade.fold(
              () => fail('Expected grade to be Some'),
              (grade) => expect(grade.value, equals('A')),
            );
            expect(stock.createdAt, equals(DateTime(2024, 1, 15, 10, 30)));
            expect(stock.updatedAt, equals(DateTime(2024, 1, 20, 14, 45)));
          },
        );
      });

      test('should successfully map with null optional fields', () {
        // Arrange
        final stockId = uuid.v4();
        final serverpodStock = serverpod_model.Stock(
          id: 1,
          tickerSymbol: 'TSLA',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );

        // Act
        final result = StockMapper.toDomain(serverpodStock, stockId);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Expected success but got error: $error'),
          (stock) {
            expect(stock.name, equals(const None()));
            expect(stock.grade, equals(const None()));
            expect(stock.sicCode, equals(const None()));
          },
        );
      });

      test('should return error when ticker is invalid', () {
        // Arrange
        final stockId = uuid.v4();
        final serverpodStock = serverpod_model.Stock(
          id: 1,
          tickerSymbol: '', // Invalid empty ticker
          companyName: 'Invalid Company',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final result = StockMapper.toDomain(serverpodStock, stockId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<TickerSymbolEmpty>());
            expect((error as TickerSymbolEmpty).message,
                equals('Ticker symbol is required'));
          },
          (stock) => fail('Expected error but got success'),
        );
      });

      test('should treat empty company name as None', () {
        // Arrange
        final stockId = uuid.v4();
        final serverpodStock = serverpod_model.Stock(
          id: 1,
          tickerSymbol: 'VALID',
          companyName: '', // Empty company name should be treated as None
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final result = StockMapper.toDomain(serverpodStock, stockId);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Expected success but got error: $error'),
          (stock) {
            expect(stock.name, equals(const None()));
          },
        );
      });

      test('should return error when company name is too long', () {
        // Arrange
        final stockId = uuid.v4();
        final serverpodStock = serverpod_model.Stock(
          id: 1,
          tickerSymbol: 'VALID',
          companyName: 'A' * 256, // Company name exceeds max length
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final result = StockMapper.toDomain(serverpodStock, stockId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<CompanyNameTooLong>());
          },
          (stock) => fail('Expected error but got success'),
        );
      });

      test('should return error when grade value is invalid', () {
        // Arrange
        final stockId = uuid.v4();
        final serverpodStock = serverpod_model.Stock(
          id: 1,
          tickerSymbol: 'AAPL',
          companyName: 'Apple Inc.',
          grade: 'Z', // Invalid grade value
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final result = StockMapper.toDomain(serverpodStock, stockId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<GradeInvalidValue>());
            expect(error.toString(), contains('GradeInvalidValue'));
          },
          (stock) => fail('Expected error but got success'),
        );
      });

      test('should return error when SIC code has invalid length', () {
        // Arrange
        final stockId = uuid.v4();
        final serverpodStock = serverpod_model.Stock(
          id: 1,
          tickerSymbol: 'AAPL',
          companyName: 'Apple Inc.',
          sicCode: '12A', // Invalid SIC code - wrong length
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final result = StockMapper.toDomain(serverpodStock, stockId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<SicCodeInvalidLength>());
            expect((error as SicCodeInvalidLength).actualLength, equals(3));
          },
          (stock) => fail('Expected error but got success'),
        );
      });

      test('should return error when SIC code has invalid format', () {
        // Arrange
        final stockId = uuid.v4();
        final serverpodStock = serverpod_model.Stock(
          id: 1,
          tickerSymbol: 'AAPL',
          companyName: 'Apple Inc.',
          sicCode: 'ABCD', // Invalid SIC code - non-numeric
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final result = StockMapper.toDomain(serverpodStock, stockId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<SicCodeInvalidFormat>());
          },
          (stock) => fail('Expected error but got success'),
        );
      });

      test('should return error when domain id is invalid', () {
        // Arrange
        final serverpodStock = serverpod_model.Stock(
          id: 1,
          tickerSymbol: 'AAPL',
          companyName: 'Apple Inc.',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final result = StockMapper.toDomain(serverpodStock, 'invalid-uuid');

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<StockInvalidId>());
          },
          (stock) => fail('Expected error but got success'),
        );
      });

      test('should normalize grade to uppercase', () {
        // Arrange
        final stockId = uuid.v4();
        final serverpodStock = serverpod_model.Stock(
          id: 1,
          tickerSymbol: 'AAPL',
          companyName: 'Apple Inc.',
          grade: 'b', // lowercase grade
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final result = StockMapper.toDomain(serverpodStock, stockId);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Expected success but got error: $error'),
          (stock) {
            expect(stock.grade.isSome(), isTrue);
            stock.grade.fold(
              () => fail('Expected grade to be Some'),
              (grade) => expect(grade.value, equals('B')),
            );
          },
        );
      });
    });

    group('toServerpod', () {
      test(
          'should successfully map domain Stock to Serverpod Stock '
          'with all fields', () {
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

        final domainStock = stockEither.getOrElse((l) => throw Exception());

        // Act
        final serverpodStock = StockMapper.toServerpod(domainStock, 42);

        // Assert
        expect(serverpodStock.id, equals(42));
        expect(serverpodStock.tickerSymbol, equals('AAPL'));
        expect(serverpodStock.companyName, equals('Apple Inc.'));
        expect(serverpodStock.grade, equals('A'));
        expect(serverpodStock.sicCode, equals('3571'));
        expect(serverpodStock.createdAt, equals(domainStock.createdAt));
        expect(serverpodStock.updatedAt, equals(domainStock.updatedAt));
      });

      test('should successfully map with None optional fields', () {
        // Arrange
        final tickerEither = TickerSymbol.create('TSLA');
        final stockEither = Stock.create(
          id: uuid.v4(),
          ticker: tickerEither.getOrElse((l) => throw Exception()),
          name: const None(),
          sicCode: const None(),
          grade: const None(),
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );

        final domainStock = stockEither.getOrElse((l) => throw Exception());

        // Act
        final serverpodStock = StockMapper.toServerpod(domainStock, null);

        // Assert
        expect(serverpodStock.id, isNull);
        expect(serverpodStock.companyName, isNull);
        expect(serverpodStock.grade, isNull);
        expect(serverpodStock.sicCode, isNull);
      });

      test('should map all grade values correctly', () {
        // Test each grade value
        final gradeValues = ['A', 'B', 'C', 'D', 'F'];

        for (final gradeValue in gradeValues) {
          // Arrange
          final tickerEither = TickerSymbol.create('TEST');
          final gradeEither = Grade.create(gradeValue);
          final stockEither = Stock.create(
            id: uuid.v4(),
            ticker: tickerEither.getOrElse((l) => throw Exception()),
            grade: Some(gradeEither.getOrElse((l) => throw Exception())),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          final domainStock = stockEither.getOrElse((l) => throw Exception());

          // Act
          final serverpodStock = StockMapper.toServerpod(domainStock, 1);

          // Assert
          expect(serverpodStock.grade, equals(gradeValue),
              reason: 'Grade $gradeValue should map correctly');
        }
      });
    });

    group('bidirectional mapping', () {
      test('should maintain data integrity when mapping back and forth', () {
        // Arrange
        final originalId = uuid.v4();
        final serverpodStock = serverpod_model.Stock(
          id: 123,
          tickerSymbol: 'GOOGL',
          companyName: 'Alphabet Inc.',
          sicCode: '7370',
          grade: 'B',
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 20),
        );

        // Act
        final domainResult = StockMapper.toDomain(serverpodStock, originalId);
        expect(domainResult.isRight(), isTrue);

        final domainStock = domainResult.getOrElse((l) => throw Exception());
        final resultServerpod =
            StockMapper.toServerpod(domainStock, serverpodStock.id);

        // Assert
        expect(resultServerpod.id, equals(serverpodStock.id));
        expect(
            resultServerpod.tickerSymbol, equals(serverpodStock.tickerSymbol));
        expect(resultServerpod.companyName, equals(serverpodStock.companyName));
        expect(resultServerpod.sicCode, equals(serverpodStock.sicCode));
        expect(resultServerpod.grade, equals(serverpodStock.grade));
        expect(resultServerpod.createdAt, equals(serverpodStock.createdAt));
        expect(resultServerpod.updatedAt, equals(serverpodStock.updatedAt));
      });
    });
  });
}
