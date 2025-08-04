import 'package:test/test.dart';
import 'package:zenvestor_server/src/infrastructure/persistence/stock/persistence_errors.dart';

void main() {
  group('PersistenceError', () {
    group('InvalidStockId', () {
      test('should have correct properties', () {
        const error = InvalidStockId('invalid-uuid');

        expect(error.invalidId, equals('invalid-uuid'));
        expect(error.props, equals(['invalid-uuid']));
      });

      test('should have meaningful toString', () {
        const error = InvalidStockId('bad-id-123');

        expect(
            error.toString(), equals('InvalidStockId(invalidId: bad-id-123)'));
      });

      test('should support equality', () {
        const error1 = InvalidStockId('id-1');
        const error2 = InvalidStockId('id-1');
        const error3 = InvalidStockId('id-2');

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });
    });

    group('InvalidStockTimestamps', () {
      late DateTime createdAt;
      late DateTime updatedAt;

      setUp(() {
        createdAt = DateTime(2024, 1, 15);
        updatedAt = DateTime(2024, 1, 10); // Before created
      });

      test('should have correct properties', () {
        final error = InvalidStockTimestamps(
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(error.createdAt, equals(createdAt));
        expect(error.updatedAt, equals(updatedAt));
        expect(error.props, equals([createdAt, updatedAt]));
      });

      test('should have meaningful toString', () {
        final error = InvalidStockTimestamps(
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(
          error.toString(),
          equals('InvalidStockTimestamps(createdAt: $createdAt, '
              'updatedAt: $updatedAt)'),
        );
      });

      test('should support equality', () {
        final error1 = InvalidStockTimestamps(
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final error2 = InvalidStockTimestamps(
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        final error3 = InvalidStockTimestamps(
          createdAt: createdAt,
          updatedAt: DateTime(2024, 1, 20),
        );

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });
    });

    group('DatabaseStorageError', () {
      test('should handle null message', () {
        const error = DatabaseStorageError();

        expect(error.message, isNull);
        expect(error.props, equals([null]));
        expect(error.toString(), equals('DatabaseStorageError()'));
      });

      test('should handle message', () {
        const error = DatabaseStorageError('Connection failed');

        expect(error.message, equals('Connection failed'));
        expect(error.props, equals(['Connection failed']));
        expect(error.toString(),
            equals('DatabaseStorageError(message: Connection failed)'));
      });

      test('should support equality', () {
        const error1 = DatabaseStorageError('Error 1');
        const error2 = DatabaseStorageError('Error 1');
        const error3 = DatabaseStorageError('Error 2');
        const error4 = DatabaseStorageError();
        const error5 = DatabaseStorageError();

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
        expect(error1, isNot(equals(error4)));
        expect(error4, equals(error5));
      });
    });

    group('PersistenceError hierarchy', () {
      test('all error types are PersistenceError subtypes', () {
        const invalidId = InvalidStockId('test');
        final invalidTimestamps = InvalidStockTimestamps(
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        const storageError = DatabaseStorageError('test');

        expect(invalidId, isA<PersistenceError>());
        expect(invalidTimestamps, isA<PersistenceError>());
        expect(storageError, isA<PersistenceError>());
      });
    });
  });
}
