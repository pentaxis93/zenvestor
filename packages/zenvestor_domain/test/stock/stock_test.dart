import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';
import 'package:zenvestor_domain/src/stock/stock.dart';
import 'package:zenvestor_domain/src/stock/value_objects/company_name.dart';
import 'package:zenvestor_domain/src/stock/value_objects/grade.dart';
import 'package:zenvestor_domain/src/stock/value_objects/sic_code.dart';
import 'package:zenvestor_domain/src/stock/value_objects/ticker_symbol.dart';

void main() {
  group('Stock Entity', () {
    late TickerSymbol validTicker;
    late CompanyName validName;
    late SicCode validSicCode;
    late Grade validGrade;

    setUp(() {
      validTicker = TickerSymbol.create('AAPL').getOrElse(
        (error) => throw Exception('Failed to create ticker: $error'),
      );
      validName = CompanyName.create('Apple Inc.').getOrElse(
        (error) => throw Exception('Failed to create name: $error'),
      );
      validSicCode = SicCode.create('3571').getOrElse(
        (error) => throw Exception('Failed to create SIC code: $error'),
      );
      validGrade = Grade.create('A').getOrElse(
        (error) => throw Exception('Failed to create grade: $error'),
      );
    });

    group('Construction', () {
      test('should create a valid stock with all fields', () {
        final result = Stock.create(
          ticker: validTicker,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not fail: $error'),
          (stock) {
            expect(stock.ticker, equals(validTicker));
            expect(stock.name, equals(Some(validName)));
            expect(stock.sicCode, equals(Some(validSicCode)));
            expect(stock.grade, equals(Some(validGrade)));
          },
        );
      });

      test('should create a valid stock with only required fields', () {
        final result = Stock.create(
          ticker: validTicker,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not fail: $error'),
          (stock) {
            expect(stock.ticker, equals(validTicker));
            expect(stock.name, equals(const None()));
            expect(stock.sicCode, equals(const None()));
            expect(stock.grade, equals(const None()));
          },
        );
      });

      test('should create a valid stock with partial optional fields', () {
        final result = Stock.create(
          ticker: validTicker,
          name: Some(validName),
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (error) => fail('Should not fail: $error'),
          (stock) {
            expect(stock.ticker, equals(validTicker));
            expect(stock.name, equals(Some(validName)));
            expect(stock.sicCode, equals(const None()));
            expect(stock.grade, equals(const None()));
          },
        );
      });

      test('should create stock with different combinations of optional fields',
          () {
        // Test with only sicCode
        var result = Stock.create(
          ticker: validTicker,
          sicCode: Some(validSicCode),
        );
        expect(result.isRight(), isTrue);

        // Test with only grade
        result = Stock.create(
          ticker: validTicker,
          grade: Some(validGrade),
        );
        expect(result.isRight(), isTrue);

        // Test with name and sicCode
        result = Stock.create(
          ticker: validTicker,
          name: Some(validName),
          sicCode: Some(validSicCode),
        );
        expect(result.isRight(), isTrue);

        // Test with sicCode and grade
        result = Stock.create(
          ticker: validTicker,
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        );
        expect(result.isRight(), isTrue);
      });
    });

    group('Equality', () {
      test('should be equal when all fields are the same', () {
        final stock1 = Stock.create(
          ticker: validTicker,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        ).getOrElse((l) => throw Exception('Failed to create stock1'));

        final stock2 = Stock.create(
          ticker: validTicker,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        ).getOrElse((l) => throw Exception('Failed to create stock2'));

        expect(stock1, equals(stock2));
        expect(stock1.hashCode, equals(stock2.hashCode));
      });

      test('should not be equal when ticker is different', () {
        final differentTicker = TickerSymbol.create('MSFT').getOrElse(
          (error) => throw Exception('Failed to create ticker: $error'),
        );

        final stock1 = Stock.create(
          ticker: validTicker,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        ).getOrElse((l) => throw Exception('Failed to create stock1'));

        final stock2 = Stock.create(
          ticker: differentTicker,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        ).getOrElse((l) => throw Exception('Failed to create stock2'));

        expect(stock1, isNot(equals(stock2)));
      });

      test('should not be equal when name is different', () {
        final differentName = CompanyName.create('Microsoft Corp.').getOrElse(
          (error) => throw Exception('Failed to create name: $error'),
        );

        final stock1 = Stock.create(
          ticker: validTicker,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        ).getOrElse((l) => throw Exception('Failed to create stock1'));

        final stock2 = Stock.create(
          ticker: validTicker,
          name: Some(differentName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        ).getOrElse((l) => throw Exception('Failed to create stock2'));

        expect(stock1, isNot(equals(stock2)));
      });

      test('should not be equal when one has name and other does not', () {
        final stock1 = Stock.create(
          ticker: validTicker,
          name: Some(validName),
        ).getOrElse((l) => throw Exception('Failed to create stock1'));

        final stock2 = Stock.create(
          ticker: validTicker,
          name: const None(),
        ).getOrElse((l) => throw Exception('Failed to create stock2'));

        expect(stock1, isNot(equals(stock2)));
      });

      test('should be equal when both have no optional fields', () {
        final stock1 = Stock.create(
          ticker: validTicker,
        ).getOrElse((l) => throw Exception('Failed to create stock1'));

        final stock2 = Stock.create(
          ticker: validTicker,
        ).getOrElse((l) => throw Exception('Failed to create stock2'));

        expect(stock1, equals(stock2));
        expect(stock1.hashCode, equals(stock2.hashCode));
      });
    });

    group('copyWith', () {
      late Stock originalStock;

      setUp(() {
        originalStock = Stock.create(
          ticker: validTicker,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        ).getOrElse((l) => throw Exception('Failed to create stock'));
      });

      test('should update ticker when specified', () {
        final newTicker = TickerSymbol.create('MSFT').getOrElse(
          (error) => throw Exception('Failed to create ticker: $error'),
        );
        final updatedStock = originalStock.copyWith(ticker: newTicker);

        expect(updatedStock.ticker, equals(newTicker));
        expect(updatedStock.name, equals(originalStock.name));
        expect(updatedStock.sicCode, equals(originalStock.sicCode));
        expect(updatedStock.grade, equals(originalStock.grade));
      });

      test('should update name when specified', () {
        final newName = CompanyName.create('New Company Inc').getOrElse(
          (error) => throw Exception('Failed to create name: $error'),
        );
        final updatedStock = originalStock.copyWith(name: Some(newName));

        expect(updatedStock.name, equals(Some(newName)));
        expect(updatedStock.ticker, equals(originalStock.ticker));
        expect(updatedStock.sicCode, equals(originalStock.sicCode));
        expect(updatedStock.grade, equals(originalStock.grade));
      });

      test('should clear name when None is specified', () {
        final updatedStock = originalStock.copyWith(name: const None());

        expect(updatedStock.name, equals(const None()));
        expect(updatedStock.ticker, equals(originalStock.ticker));
        expect(updatedStock.sicCode, equals(originalStock.sicCode));
        expect(updatedStock.grade, equals(originalStock.grade));
      });

      test('should update sicCode when specified', () {
        final newSicCode = SicCode.create('5555').getOrElse(
          (error) => throw Exception('Failed to create SIC code: $error'),
        );
        final updatedStock = originalStock.copyWith(sicCode: Some(newSicCode));

        expect(updatedStock.sicCode, equals(Some(newSicCode)));
        expect(updatedStock.ticker, equals(originalStock.ticker));
        expect(updatedStock.name, equals(originalStock.name));
        expect(updatedStock.grade, equals(originalStock.grade));
      });

      test('should update grade when specified', () {
        final newGrade = Grade.create('B').getOrElse(
          (error) => throw Exception('Failed to create grade: $error'),
        );
        final updatedStock = originalStock.copyWith(grade: Some(newGrade));

        expect(updatedStock.grade, equals(Some(newGrade)));
        expect(updatedStock.ticker, equals(originalStock.ticker));
        expect(updatedStock.name, equals(originalStock.name));
        expect(updatedStock.sicCode, equals(originalStock.sicCode));
      });

      test('should update multiple fields when specified', () {
        final newTicker = TickerSymbol.create('GOOGL').getOrElse(
          (error) => throw Exception('Failed to create ticker: $error'),
        );
        final newGrade = Grade.create('C').getOrElse(
          (error) => throw Exception('Failed to create grade: $error'),
        );

        final updatedStock = originalStock.copyWith(
          ticker: newTicker,
          grade: Some(newGrade),
        );

        expect(updatedStock.ticker, equals(newTicker));
        expect(updatedStock.grade, equals(Some(newGrade)));
        expect(updatedStock.name, equals(originalStock.name));
        expect(updatedStock.sicCode, equals(originalStock.sicCode));
      });

      test('should return same instance when no fields are updated', () {
        final updatedStock = originalStock.copyWith();
        expect(identical(updatedStock, originalStock), isTrue);
      });

      test('should handle clearing multiple optional fields', () {
        final updatedStock = originalStock.copyWith(
          name: const None(),
          sicCode: const None(),
          grade: const None(),
        );

        expect(updatedStock.ticker, equals(originalStock.ticker));
        expect(updatedStock.name, equals(const None()));
        expect(updatedStock.sicCode, equals(const None()));
        expect(updatedStock.grade, equals(const None()));
      });
    });

    group('toString', () {
      test('should provide a readable string representation with all fields',
          () {
        final stock = Stock.create(
          ticker: validTicker,
          name: Some(validName),
          sicCode: Some(validSicCode),
          grade: Some(validGrade),
        ).getOrElse((l) => throw Exception('Failed to create stock'));

        final stringRep = stock.toString();
        expect(stringRep, contains('Stock'));
        expect(stringRep, contains(validTicker.value));
        expect(stringRep, contains(validName.value));
        expect(stringRep, contains(validSicCode.value));
        expect(stringRep, contains(validGrade.value));
      });

      test(
          'should provide a readable string representation with minimal fields',
          () {
        final stock = Stock.create(
          ticker: validTicker,
        ).getOrElse((l) => throw Exception('Failed to create stock'));

        final stringRep = stock.toString();
        expect(stringRep, contains('Stock'));
        expect(stringRep, contains(validTicker.value));
        expect(stringRep, contains('None'));
      });
    });
  });
}
