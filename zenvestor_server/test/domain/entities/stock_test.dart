import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'package:zenvestor_server/src/domain/entities/stock.dart';
import 'package:zenvestor_server/src/domain/errors/domain_error.dart';
import 'package:zenvestor_server/src/domain/value_objects/company_name.dart';
import 'package:zenvestor_server/src/domain/value_objects/grade.dart';
import 'package:zenvestor_server/src/domain/value_objects/sic_code.dart';
import 'package:zenvestor_server/src/domain/value_objects/ticker_symbol.dart';

import '../../fixtures/domain_fixtures.dart';

void main() {
  group('Stock Entity', () {
    late TickerSymbol validTicker;
    late CompanyName validName;
    late SicCode validSicCode;
    late Grade validGrade;
    late String validId;
    late DateTime validCreatedAt;
    late DateTime validUpdatedAt;

    setUp(() {
      validTicker = DomainFixtures.tickerSymbol();
      validName = DomainFixtures.companyName();
      validSicCode = DomainFixtures.sicCode();
      validGrade = DomainFixtures.grade();
      validId = const Uuid().v4();
      validCreatedAt = DateTime.now().subtract(const Duration(days: 1));
      validUpdatedAt = DateTime.now();
    });

    group('Construction', () {
      test('should create a valid stock with all fields', () {
        final result = Stock.create(
          id: validId,
          ticker: validTicker,
          createdAt: validCreatedAt,
          updatedAt: validUpdatedAt,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not fail: $error'),
          (stock) {
            expect(stock.id, equals(validId));
            expect(stock.ticker, equals(validTicker));
            expect(stock.name, equals(Some(validName)));
            expect(stock.sicCode, equals(Some(validSicCode)));
            expect(stock.grade, equals(Some(validGrade)));
            expect(stock.createdAt, equals(validCreatedAt));
            expect(stock.updatedAt, equals(validUpdatedAt));
          },
        );
      });

      test('should create a valid stock with only required fields', () {
        final result = Stock.create(
          id: validId,
          ticker: validTicker,
          createdAt: validCreatedAt,
          updatedAt: validUpdatedAt,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not fail: $error'),
          (stock) {
            expect(stock.id, equals(validId));
            expect(stock.ticker, equals(validTicker));
            expect(stock.name, equals(const None()));
            expect(stock.sicCode, equals(const None()));
            expect(stock.grade, equals(const None()));
            expect(stock.createdAt, equals(validCreatedAt));
            expect(stock.updatedAt, equals(validUpdatedAt));
          },
        );
      });

      test('should create a valid stock with partial optional fields', () {
        final result = Stock.create(
          id: validId,
          ticker: validTicker,
          createdAt: validCreatedAt,
          updatedAt: validUpdatedAt,
          name: Some(validName),
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not fail: $error'),
          (stock) {
            expect(stock.id, equals(validId));
            expect(stock.ticker, equals(validTicker));
            expect(stock.name, equals(Some(validName)));
            expect(stock.sicCode, equals(const None()));
            expect(stock.grade, equals(const None()));
            expect(stock.createdAt, equals(validCreatedAt));
            expect(stock.updatedAt, equals(validUpdatedAt));
          },
        );
      });

      test('should fail when id is empty', () {
        const emptyId = '';
        final result = Stock.create(
          id: emptyId,
          ticker: validTicker,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
          createdAt: validCreatedAt,
          updatedAt: validUpdatedAt,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<StockInvalidId>());
            final stockError = error as StockInvalidId;
            expect(stockError.invalidId, equals(emptyId));
            expect(stockError.toString(), contains(emptyId));
          },
          (_) => fail('Should not succeed'),
        );
      });

      test('should fail when id is not a valid UUID', () {
        const invalidId = 'not-a-uuid';
        final result = Stock.create(
          id: invalidId,
          ticker: validTicker,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
          createdAt: validCreatedAt,
          updatedAt: validUpdatedAt,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<StockInvalidId>());
            final stockError = error as StockInvalidId;
            expect(stockError.invalidId, equals(invalidId));
            expect(stockError.toString(), contains(invalidId));
          },
          (_) => fail('Should not succeed'),
        );
      });

      test('should fail when createdAt is after updatedAt', () {
        final invalidCreatedAt = DateTime.now();
        final invalidUpdatedAt =
            DateTime.now().subtract(const Duration(days: 1));

        final result = Stock.create(
          id: validId,
          ticker: validTicker,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
          createdAt: invalidCreatedAt,
          updatedAt: invalidUpdatedAt,
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) {
            expect(error, isA<StockInvalidTimestamps>());
            final timestampError = error as StockInvalidTimestamps;
            expect(timestampError.createdAt, equals(invalidCreatedAt));
            expect(timestampError.updatedAt, equals(invalidUpdatedAt));
            expect(timestampError.toString(), contains('createdAt:'));
            expect(timestampError.toString(), contains('updatedAt:'));
          },
          (_) => fail('Should not succeed'),
        );
      });

      test('should succeed when createdAt equals updatedAt', () {
        final sameTime = DateTime.now();
        final result = Stock.create(
          id: validId,
          ticker: validTicker,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
          createdAt: sameTime,
          updatedAt: sameTime,
        );

        expect(result.isRight(), isTrue);
      });
    });

    group('Equality', () {
      test('should be equal when IDs are the same', () {
        final stock1 = Stock.create(
          id: validId,
          ticker: validTicker,
          createdAt: validCreatedAt,
          updatedAt: validUpdatedAt,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        ).getOrElse((l) => throw Exception('Failed to create stock1'));

        final stock2 = Stock.create(
          id: validId,
          ticker: DomainFixtures.tickerSymbol(symbol: 'DIFF'),
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          name: Some(DomainFixtures.companyName(name: 'Different Corp')),
          sicCode: Some(DomainFixtures.sicCode(code: '9999')),
          grade: Some(DomainFixtures.grade(letter: 'F')),
        ).getOrElse((l) => throw Exception('Failed to create stock2'));

        expect(stock1, equals(stock2));
        expect(stock1.hashCode, equals(stock2.hashCode));
      });

      test('should not be equal when IDs are different', () {
        final stock1 = Stock.create(
          id: validId,
          ticker: validTicker,
          createdAt: validCreatedAt,
          updatedAt: validUpdatedAt,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        ).getOrElse((l) => throw Exception('Failed to create stock1'));

        final stock2 = Stock.create(
          id: const Uuid().v4(),
          ticker: validTicker,
          createdAt: validCreatedAt,
          updatedAt: validUpdatedAt,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        ).getOrElse((l) => throw Exception('Failed to create stock2'));

        expect(stock1, isNot(equals(stock2)));
        expect(stock1.hashCode, isNot(equals(stock2.hashCode)));
      });
    });

    group('copyWith', () {
      late Stock originalStock;

      setUp(() {
        originalStock = Stock.create(
          id: validId,
          ticker: validTicker,
          createdAt: validCreatedAt,
          updatedAt: validUpdatedAt,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        ).getOrElse((l) => throw Exception('Failed to create stock'));
      });

      test('should update ticker when specified', () {
        final newTicker = DomainFixtures.tickerSymbol(symbol: 'MSFT');
        final updatedStock = originalStock.copyWith(ticker: newTicker);

        expect(updatedStock.ticker, equals(newTicker));
        expect(updatedStock.id, equals(originalStock.id));
        expect(updatedStock.name, equals(originalStock.name));
        expect(updatedStock.sicCode, equals(originalStock.sicCode));
        expect(updatedStock.grade, equals(originalStock.grade));
        expect(updatedStock.createdAt, equals(originalStock.createdAt));
        expect(updatedStock.updatedAt, equals(originalStock.updatedAt));
      });

      test('should update name when specified', () {
        final newName = DomainFixtures.companyName(name: 'New Company Inc');
        final updatedStock = originalStock.copyWith(name: Some(newName));

        expect(updatedStock.name, equals(Some(newName)));
        expect(updatedStock.ticker, equals(originalStock.ticker));
      });

      test('should clear name when None is specified', () {
        final updatedStock = originalStock.copyWith(name: const None());

        expect(updatedStock.name, equals(const None()));
        expect(updatedStock.ticker, equals(originalStock.ticker));
      });

      test('should update sicCode when specified', () {
        final newSicCode = DomainFixtures.sicCode(code: '5555');
        final updatedStock = originalStock.copyWith(sicCode: Some(newSicCode));

        expect(updatedStock.sicCode, equals(Some(newSicCode)));
        expect(updatedStock.ticker, equals(originalStock.ticker));
      });

      test('should update grade when specified', () {
        final newGrade = DomainFixtures.grade(letter: 'A');
        final updatedStock = originalStock.copyWith(grade: Some(newGrade));

        expect(updatedStock.grade, equals(Some(newGrade)));
        expect(updatedStock.ticker, equals(originalStock.ticker));
      });

      test('should update updatedAt when specified', () {
        final newUpdatedAt = DateTime.now().add(const Duration(days: 1));
        final updatedStock = originalStock.copyWith(updatedAt: newUpdatedAt);

        expect(updatedStock.updatedAt, equals(newUpdatedAt));
        expect(updatedStock.createdAt, equals(originalStock.createdAt));
      });

      test('should update multiple fields when specified', () {
        final newTicker = DomainFixtures.tickerSymbol(symbol: 'GOOGL');
        final newGrade = DomainFixtures.grade();
        final newUpdatedAt = DateTime.now().add(const Duration(days: 1));

        final updatedStock = originalStock.copyWith(
          ticker: newTicker,
          grade: Some(newGrade),
          updatedAt: newUpdatedAt,
        );

        expect(updatedStock.ticker, equals(newTicker));
        expect(updatedStock.grade, equals(Some(newGrade)));
        expect(updatedStock.updatedAt, equals(newUpdatedAt));
        expect(updatedStock.name, equals(originalStock.name));
        expect(updatedStock.sicCode, equals(originalStock.sicCode));
        expect(updatedStock.createdAt, equals(originalStock.createdAt));
      });

      test('should return same instance when no fields are updated', () {
        final updatedStock = originalStock.copyWith();
        expect(identical(updatedStock, originalStock), isTrue);
      });
    });

    group('toString', () {
      test('should provide a readable string representation', () {
        final stock = Stock.create(
          id: validId,
          ticker: validTicker,
          createdAt: validCreatedAt,
          updatedAt: validUpdatedAt,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        ).getOrElse((l) => throw Exception('Failed to create stock'));

        final stringRep = stock.toString();
        expect(stringRep, contains('Stock'));
        expect(stringRep, contains(validId));
        expect(stringRep, contains(validTicker.value));
      });
    });
  });
}
