import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;
import 'package:zenvestor_server/src/domain/stock/stock.dart';

void main() {
  group('Stock (Server Domain)', () {
    // Test data setup
    late shared.TickerSymbol validTicker;
    late Option<shared.CompanyName> validName;
    late Option<shared.SicCode> validSicCode;
    late Option<shared.Grade> validGrade;
    late shared.Stock validSharedStock;
    late String validId;
    late DateTime createdAt;
    late DateTime updatedAt;

    setUp(() {
      validTicker = shared.TickerSymbol.create('AAPL').toNullable()!;
      validName = some(
        shared.CompanyName.create('Apple Inc.').toNullable()!,
      );
      validSicCode = some(
        shared.SicCode.create('3571').toNullable()!,
      );
      validGrade = some(
        shared.Grade.create('A').toNullable()!,
      );
      validSharedStock = shared.Stock.create(
        ticker: validTicker,
        name: validName,
        sicCode: validSicCode,
        grade: validGrade,
      ).toNullable()!;
      validId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
      createdAt = DateTime(2024, 1, 1, 12);
      updatedAt = DateTime(2024, 1, 2, 14, 30);
    });

    group('constructor', () {
      test('creates Stock with all required fields', () {
        final stock = Stock(
          id: validId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sharedStock: validSharedStock,
        );

        expect(stock.id, equals(validId));
        expect(stock.createdAt, equals(createdAt));
        expect(stock.updatedAt, equals(updatedAt));
        expect(stock.sharedStock, equals(validSharedStock));
        expect(stock.ticker, equals(validTicker));
        expect(stock.name, equals(validName));
        expect(stock.sicCode, equals(validSicCode));
        expect(stock.grade, equals(validGrade));
      });

      test('creates Stock with optional fields as None', () {
        final minimalSharedStock = shared.Stock.create(
          ticker: validTicker,
          name: none(),
          sicCode: none(),
          grade: none(),
        ).toNullable()!;

        final stock = Stock(
          id: validId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sharedStock: minimalSharedStock,
        );

        expect(stock.id, equals(validId));
        expect(stock.ticker, equals(validTicker));
        expect(stock.name, equals(none<shared.CompanyName>()));
        expect(stock.sicCode, equals(none<shared.SicCode>()));
        expect(stock.grade, equals(none<shared.Grade>()));
      });

      test('wraps shared domain Stock properly', () {
        final stock = Stock(
          id: validId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sharedStock: validSharedStock,
        );

        // Verify it wraps the shared stock
        expect(stock.sharedStock, equals(validSharedStock));

        // Verify delegation works
        expect(stock.ticker, equals(validSharedStock.ticker));
        expect(stock.name, equals(validSharedStock.name));
        expect(stock.sicCode, equals(validSharedStock.sicCode));
        expect(stock.grade, equals(validSharedStock.grade));
      });

      test('creates Stock using fromSharedStock factory', () {
        final stock = Stock.fromSharedStock(
          id: validId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sharedStock: validSharedStock,
        );

        expect(stock.id, equals(validId));
        expect(stock.createdAt, equals(createdAt));
        expect(stock.updatedAt, equals(updatedAt));
        expect(stock.sharedStock, equals(validSharedStock));
        expect(stock.ticker, equals(validTicker));
        expect(stock.name, equals(validName));
        expect(stock.sicCode, equals(validSicCode));
        expect(stock.grade, equals(validGrade));
      });
    });

    group('copyWith', () {
      late Stock originalStock;

      setUp(() {
        originalStock = Stock(
          id: validId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sharedStock: validSharedStock,
        );
      });

      test('returns same instance when no changes', () {
        final copy = originalStock.copyWith();

        expect(copy.id, equals(originalStock.id));
        expect(copy.createdAt, equals(originalStock.createdAt));
        expect(copy.updatedAt, equals(originalStock.updatedAt));
        expect(copy.ticker, equals(originalStock.ticker));
      });

      test('updates infrastructure fields', () {
        const newId = 'e72ac10b-48cc-5372-b567-1e02b2c3d480';
        final newUpdatedAt = DateTime(2024, 1, 3, 10);

        final copy = originalStock.copyWith(
          id: newId,
          updatedAt: newUpdatedAt,
        );

        expect(copy.id, equals(newId));
        expect(copy.createdAt, equals(originalStock.createdAt));
        expect(copy.updatedAt, equals(newUpdatedAt));
        expect(copy.ticker, equals(originalStock.ticker));
      });

      test('updates business fields', () {
        final newTicker = shared.TickerSymbol.create('MSFT').toNullable()!;
        final newGrade = some(shared.Grade.create('B').toNullable()!);

        final copy = originalStock.copyWith(
          ticker: newTicker,
          grade: newGrade,
        );

        expect(copy.id, equals(originalStock.id));
        expect(copy.ticker, equals(newTicker));
        expect(copy.grade, equals(newGrade));
        expect(copy.name, equals(originalStock.name));
      });

      test('can set optional fields to None', () {
        final copy = originalStock.copyWith(
          name: none(),
          sicCode: none(),
          grade: none(),
        );

        expect(copy.name, equals(none<shared.CompanyName>()));
        expect(copy.sicCode, equals(none<shared.SicCode>()));
        expect(copy.grade, equals(none<shared.Grade>()));
      });
    });

    group('equality', () {
      test('considers all fields for equality', () {
        final stock1 = Stock(
          id: validId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sharedStock: validSharedStock,
        );

        final stock2 = Stock(
          id: validId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sharedStock: validSharedStock,
        );

        expect(stock1, equals(stock2));
        expect(stock1.hashCode, equals(stock2.hashCode));
      });

      test('different id makes stocks unequal', () {
        final stock1 = Stock(
          id: validId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sharedStock: validSharedStock,
        );

        final stock2 = Stock(
          id: 'different-id',
          createdAt: createdAt,
          updatedAt: updatedAt,
          sharedStock: validSharedStock,
        );

        expect(stock1, isNot(equals(stock2)));
      });

      test('different timestamps make stocks unequal', () {
        final stock1 = Stock(
          id: validId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sharedStock: validSharedStock,
        );

        final stock2 = Stock(
          id: validId,
          createdAt: DateTime(2024, 2),
          updatedAt: updatedAt,
          sharedStock: validSharedStock,
        );

        expect(stock1, isNot(equals(stock2)));
      });

      test('different business fields make stocks unequal', () {
        final stock1 = Stock(
          id: validId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sharedStock: validSharedStock,
        );

        final differentSharedStock = shared.Stock.create(
          ticker: shared.TickerSymbol.create('GOOGL').toNullable()!,
          name: validName,
          sicCode: validSicCode,
          grade: validGrade,
        ).toNullable()!;

        final stock2 = Stock(
          id: validId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sharedStock: differentSharedStock,
        );

        expect(stock1, isNot(equals(stock2)));
      });
    });

    group('toString', () {
      test('includes key fields in string representation', () {
        final stock = Stock(
          id: validId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sharedStock: validSharedStock,
        );

        final str = stock.toString();

        expect(str, contains('Stock('));
        expect(str, contains('id: $validId'));
        expect(str, contains('ticker: AAPL'));
        expect(str, contains('createdAt: $createdAt'));
        expect(str, contains('updatedAt: $updatedAt'));
      });
    });

    group('integration with persistence model', () {
      test('can be created from StockPersistenceModel data', () {
        // This test documents the expected usage pattern
        final stock = Stock(
          id: validId,
          createdAt: createdAt,
          updatedAt: updatedAt,
          sharedStock: validSharedStock,
        );

        // The repository would typically:
        // 1. Get StockPersistenceModel from database
        // 2. Extract the shared.Stock and infrastructure data
        // 3. Create server domain Stock combining both

        expect(stock.id, equals(validId));
        expect(stock.ticker, equals(validTicker));
        expect(stock.sharedStock, equals(validSharedStock));
      });
    });
  });
}
