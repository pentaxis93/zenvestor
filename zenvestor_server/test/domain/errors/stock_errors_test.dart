import 'package:test/test.dart';
import 'package:zenvestor_domain/shared/errors.dart' show DomainError;
import 'package:zenvestor_server/src/domain/stock/stock_errors.dart';

void main() {
  group('StockError', () {
    group('StockInvalidId', () {
      test('extends StockError', () {
        const error = StockInvalidId('invalid-id');
        expect(error, isA<StockError>());
      });

      test('extends DomainError', () {
        const error = StockInvalidId('invalid-id');
        expect(error, isA<DomainError>());
      });

      test('props returns invalidId', () {
        const invalidId = 'invalid-id';
        const error = StockInvalidId(invalidId);
        expect(error.props, equals([invalidId]));
      });

      test('stores invalid ID value', () {
        const invalidId = 'not-a-uuid';
        const error = StockInvalidId(invalidId);
        expect(error.invalidId, equals(invalidId));
      });

      test('toString includes invalid ID', () {
        const invalidId = 'bad-id';
        const error = StockInvalidId(invalidId);
        expect(error.toString(), contains('StockInvalidId'));
        expect(error.toString(), contains(invalidId));
      });

      test('equality works correctly with same ID', () {
        const error1 = StockInvalidId('same-id');
        const error2 = StockInvalidId('same-id');
        expect(error1, equals(error2));
        expect(error1.hashCode, equals(error2.hashCode));
      });

      test('inequality works correctly with different IDs', () {
        const error1 = StockInvalidId('id-1');
        const error2 = StockInvalidId('id-2');
        expect(error1, isNot(equals(error2)));
        expect(error1.hashCode, isNot(equals(error2.hashCode)));
      });
    });

    group('StockInvalidTimestamps', () {
      late DateTime createdAt;
      late DateTime updatedAt;

      setUp(() {
        createdAt = DateTime.now();
        updatedAt = DateTime.now().subtract(const Duration(days: 1));
      });

      test('extends StockError', () {
        final error = StockInvalidTimestamps(
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        expect(error, isA<StockError>());
      });

      test('extends DomainError', () {
        final error = StockInvalidTimestamps(
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        expect(error, isA<DomainError>());
      });

      test('props returns both timestamps', () {
        final error = StockInvalidTimestamps(
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        expect(error.props, equals([createdAt, updatedAt]));
      });

      test('stores timestamp values', () {
        final error = StockInvalidTimestamps(
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        expect(error.createdAt, equals(createdAt));
        expect(error.updatedAt, equals(updatedAt));
      });

      test('toString includes both timestamps', () {
        final error = StockInvalidTimestamps(
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        expect(error.toString(), contains('StockInvalidTimestamps'));
        expect(error.toString(), contains('createdAt:'));
        expect(error.toString(), contains('updatedAt:'));
      });

      test('equality works correctly with same timestamps', () {
        final error1 = StockInvalidTimestamps(
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final error2 = StockInvalidTimestamps(
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        expect(error1, equals(error2));
        expect(error1.hashCode, equals(error2.hashCode));
      });

      test('inequality works correctly with different timestamps', () {
        final error1 = StockInvalidTimestamps(
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final error2 = StockInvalidTimestamps(
          createdAt: createdAt.add(const Duration(seconds: 1)),
          updatedAt: updatedAt,
        );
        expect(error1, isNot(equals(error2)));
        expect(error1.hashCode, isNot(equals(error2.hashCode)));
      });
    });

    group('error type relationships', () {
      test('errors are distinct types', () {
        const idError = StockInvalidId('invalid');
        final timestampError = StockInvalidTimestamps(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(idError.runtimeType, isNot(equals(timestampError.runtimeType)));
      });

      test('all errors extend base StockError', () {
        final errors = [
          const StockInvalidId('invalid'),
          StockInvalidTimestamps(
            createdAt: DateTime.now(),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];

        for (final error in errors) {
          expect(error, isA<StockError>());
          expect(error, isA<DomainError>());
        }
      });
    });
  });
}
