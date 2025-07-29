// We're testing the deprecated ValidationError class and its members,
// so we need to use them despite the deprecation warnings
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/errors/domain_error.dart';

void main() {
  group('ValidationError', () {
    group('constructor', () {
      test('creates error with all required fields', () {
        const error = ValidationError(
          field: 'symbol',
          invalidValue: 'INVALID123',
          message: 'Stock symbol must be 1-5 uppercase letters',
        );

        expect(error.field, equals('symbol'));
        expect(error.invalidValue, equals('INVALID123'));
        expect(
          error.message,
          equals('Stock symbol must be 1-5 uppercase letters'),
        );
      });

      test('supports null invalid value', () {
        const error = ValidationError(
          field: 'name',
          invalidValue: null,
          message: 'Name is required',
        );

        expect(error.field, equals('name'));
        expect(error.invalidValue, isNull);
        expect(error.message, equals('Name is required'));
      });
    });

    group('equality', () {
      test('equals when all fields are the same', () {
        const error1 = ValidationError(
          field: 'symbol',
          invalidValue: 'ABC',
          message: 'Invalid symbol',
        );

        const error2 = ValidationError(
          field: 'symbol',
          invalidValue: 'ABC',
          message: 'Invalid symbol',
        );

        expect(error1, equals(error2));
        expect(error1.hashCode, equals(error2.hashCode));
      });

      test('not equals when field differs', () {
        const error1 = ValidationError(
          field: 'symbol',
          invalidValue: 'ABC',
          message: 'Invalid symbol',
        );

        const error2 = ValidationError(
          field: 'name',
          invalidValue: 'ABC',
          message: 'Invalid symbol',
        );

        expect(error1, isNot(equals(error2)));
      });

      test('not equals when invalidValue differs', () {
        const error1 = ValidationError(
          field: 'symbol',
          invalidValue: 'ABC',
          message: 'Invalid symbol',
        );

        const error2 = ValidationError(
          field: 'symbol',
          invalidValue: 'XYZ',
          message: 'Invalid symbol',
        );

        expect(error1, isNot(equals(error2)));
      });

      test('not equals when message differs', () {
        const error1 = ValidationError(
          field: 'symbol',
          invalidValue: 'ABC',
          message: 'Invalid symbol',
        );

        const error2 = ValidationError(
          field: 'symbol',
          invalidValue: 'ABC',
          message: 'Different message',
        );

        expect(error1, isNot(equals(error2)));
      });
    });

    group('toString', () {
      test('includes all fields in string representation', () {
        const error = ValidationError(
          field: 'symbol',
          invalidValue: 'INVALID',
          message: 'Stock symbol must be 1-5 uppercase letters',
        );

        final string = error.toString();
        expect(string, contains('ValidationError'));
        expect(string, contains('field: symbol'));
        expect(string, contains('invalidValue: INVALID'));
        expect(
          string,
          contains('message: Stock symbol must be 1-5 uppercase letters'),
        );
      });

      test('handles null invalidValue in string representation', () {
        const error = ValidationError(
          field: 'name',
          invalidValue: null,
          message: 'Name is required',
        );

        final string = error.toString();
        expect(string, contains('invalidValue: null'));
      });
    });

    group('Either integration', () {
      test('works with Either.left for single error', () {
        const error = ValidationError(
          field: 'symbol',
          invalidValue: 'invalid',
          message: 'Invalid symbol',
        );

        final result = Either<ValidationError, String>.left(error);

        expect(result.isLeft(), isTrue);
        expect(result.getLeft().toNullable(), equals(error));
      });

      test('can be mapped in Either context', () {
        const error = ValidationError(
          field: 'price',
          invalidValue: -10,
          message: 'Price must be positive',
        );

        final result = Either<ValidationError, double>.left(error);
        final mapped = result.mapLeft((e) => e.message);

        expect(mapped.getLeft().toNullable(), equals('Price must be positive'));
      });
    });
  });

  group('ValidationErrors', () {
    test('creates empty errors collection', () {
      const errors = ValidationErrors([]);

      expect(errors.errors, isEmpty);
      expect(errors.hasErrors, isFalse);
      expect(errors.isEmpty, isTrue);
    });

    test('creates errors collection with single error', () {
      const error = ValidationError(
        field: 'symbol',
        invalidValue: 'invalid',
        message: 'Invalid symbol',
      );
      const errors = ValidationErrors([error]);

      expect(errors.errors, hasLength(1));
      expect(errors.errors.first, equals(error));
      expect(errors.hasErrors, isTrue);
      expect(errors.isEmpty, isFalse);
    });

    test('creates errors collection with multiple errors', () {
      const error1 = ValidationError(
        field: 'symbol',
        invalidValue: 'invalid',
        message: 'Invalid symbol',
      );
      const error2 = ValidationError(
        field: 'price',
        invalidValue: -10,
        message: 'Price must be positive',
      );
      const errors = ValidationErrors([error1, error2]);

      expect(errors.errors, hasLength(2));
      expect(errors.errors, contains(error1));
      expect(errors.errors, contains(error2));
      expect(errors.hasErrors, isTrue);
    });

    test('add method creates new instance with additional error', () {
      const error1 = ValidationError(
        field: 'symbol',
        invalidValue: 'invalid',
        message: 'Invalid symbol',
      );
      const error2 = ValidationError(
        field: 'price',
        invalidValue: -10,
        message: 'Price must be positive',
      );

      const errors1 = ValidationErrors([error1]);
      final errors2 = errors1.add(error2);

      expect(errors1.errors, hasLength(1));
      expect(errors2.errors, hasLength(2));
      expect(errors2.errors, containsAll([error1, error2]));
    });

    test('addAll method creates new instance with additional errors', () {
      const error1 = ValidationError(
        field: 'symbol',
        invalidValue: 'invalid',
        message: 'Invalid symbol',
      );
      const error2 = ValidationError(
        field: 'price',
        invalidValue: -10,
        message: 'Price must be positive',
      );
      const error3 = ValidationError(
        field: 'quantity',
        invalidValue: 0,
        message: 'Quantity must be positive',
      );

      const errors1 = ValidationErrors([error1]);
      final errors2 = errors1.addAll([error2, error3]);

      expect(errors1.errors, hasLength(1));
      expect(errors2.errors, hasLength(3));
      expect(errors2.errors, containsAll([error1, error2, error3]));
    });

    test('getErrorsForField returns errors for specific field', () {
      const symbolError1 = ValidationError(
        field: 'symbol',
        invalidValue: '',
        message: 'Symbol is required',
      );
      const symbolError2 = ValidationError(
        field: 'symbol',
        invalidValue: 'abc123',
        message: 'Symbol format invalid',
      );
      const priceError = ValidationError(
        field: 'price',
        invalidValue: -10,
        message: 'Price must be positive',
      );

      const errors = ValidationErrors([symbolError1, symbolError2, priceError]);
      final symbolErrors = errors.getErrorsForField('symbol');

      expect(symbolErrors, hasLength(2));
      expect(symbolErrors, containsAll([symbolError1, symbolError2]));
    });

    test('getErrorsForField returns empty list for field with no errors', () {
      const error = ValidationError(
        field: 'symbol',
        invalidValue: 'invalid',
        message: 'Invalid symbol',
      );

      const errors = ValidationErrors([error]);
      final priceErrors = errors.getErrorsForField('price');

      expect(priceErrors, isEmpty);
    });

    test('equals when errors are the same', () {
      const error1 = ValidationError(
        field: 'symbol',
        invalidValue: 'invalid',
        message: 'Invalid symbol',
      );
      const error2 = ValidationError(
        field: 'price',
        invalidValue: -10,
        message: 'Price must be positive',
      );

      const errors1 = ValidationErrors([error1, error2]);
      const errors2 = ValidationErrors([error1, error2]);

      expect(errors1, equals(errors2));
      expect(errors1.hashCode, equals(errors2.hashCode));
    });

    test('not equals when errors differ', () {
      const error1 = ValidationError(
        field: 'symbol',
        invalidValue: 'invalid',
        message: 'Invalid symbol',
      );
      const error2 = ValidationError(
        field: 'price',
        invalidValue: -10,
        message: 'Price must be positive',
      );

      const errors1 = ValidationErrors([error1]);
      const errors2 = ValidationErrors([error2]);

      expect(errors1, isNot(equals(errors2)));
    });

    test('toString includes all errors', () {
      const error1 = ValidationError(
        field: 'symbol',
        invalidValue: 'invalid',
        message: 'Invalid symbol',
      );
      const error2 = ValidationError(
        field: 'price',
        invalidValue: -10,
        message: 'Price must be positive',
      );

      const errors = ValidationErrors([error1, error2]);
      final string = errors.toString();

      expect(string, contains('ValidationErrors'));
      expect(string, contains('2 errors'));
      expect(string, contains(error1.toString()));
      expect(string, contains(error2.toString()));
    });

    test('toString handles empty errors', () {
      const errors = ValidationErrors([]);
      final string = errors.toString();

      expect(string, contains('ValidationErrors'));
      expect(string, contains('0 errors'));
    });

    test('works with Either.left for validation errors', () {
      const error1 = ValidationError(
        field: 'symbol',
        invalidValue: 'invalid',
        message: 'Invalid symbol',
      );
      const error2 = ValidationError(
        field: 'price',
        invalidValue: -10,
        message: 'Price must be positive',
      );

      const errors = ValidationErrors([error1, error2]);
      final result = Either<ValidationErrors, String>.left(errors);

      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), equals(errors));
      expect(result.getLeft().toNullable()?.errors, hasLength(2));
    });
  });
}
