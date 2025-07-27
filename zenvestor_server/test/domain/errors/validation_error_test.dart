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

    group('factory constructors', () {
      test('missingRequired creates error for missing field', () {
        final error = ValidationError.missingRequired('portfolioName');

        expect(error.field, equals('portfolioName'));
        expect(error.invalidValue, isNull);
        expect(error.message, equals('portfolioName is required'));
      });

      test('invalidFormat creates error for format violations', () {
        final error = ValidationError.invalidFormat(
          field: 'email',
          invalidValue: 'not-an-email',
          expectedFormat: 'valid email address',
        );

        expect(error.field, equals('email'));
        expect(error.invalidValue, equals('not-an-email'));
        expect(error.message, equals('email must be a valid email address'));
      });

      test('invalidLength creates error for length constraints', () {
        final error = ValidationError.invalidLength(
          field: 'description',
          invalidValue: 'abc',
          minLength: 10,
          maxLength: 100,
        );

        expect(error.field, equals('description'));
        expect(error.invalidValue, equals('abc'));
        expect(
          error.message,
          equals('description must be between 10 and 100 characters'),
        );
      });

      test('invalidLength with only minLength', () {
        final error = ValidationError.invalidLength(
          field: 'password',
          invalidValue: '123',
          minLength: 8,
        );

        expect(error.field, equals('password'));
        expect(error.invalidValue, equals('123'));
        expect(error.message, equals('password must be at least 8 characters'));
      });

      test('invalidLength with only maxLength', () {
        final error = ValidationError.invalidLength(
          field: 'ticker',
          invalidValue: 'TOOLONG',
          maxLength: 5,
        );

        expect(error.field, equals('ticker'));
        expect(error.invalidValue, equals('TOOLONG'));
        expect(error.message, equals('ticker must be at most 5 characters'));
      });

      test('invalidLength throws when neither minLength nor maxLength provided',
          () {
        expect(
          () => ValidationError.invalidLength(
            field: 'test',
            invalidValue: 'value',
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'At least one of minLength or maxLength must be provided',
          )),
        );
      });

      test('outOfRange creates error for numeric range violations', () {
        final error = ValidationError.outOfRange(
          field: 'quantity',
          invalidValue: 150,
          min: 1,
          max: 100,
        );

        expect(error.field, equals('quantity'));
        expect(error.invalidValue, equals(150));
        expect(error.message, equals('quantity must be between 1 and 100'));
      });

      test('outOfRange with only min', () {
        final error = ValidationError.outOfRange(
          field: 'price',
          invalidValue: 0,
          min: 0.01,
        );

        expect(error.field, equals('price'));
        expect(error.invalidValue, equals(0));
        expect(error.message, equals('price must be at least 0.01'));
      });

      test('outOfRange with only max', () {
        final error = ValidationError.outOfRange(
          field: 'allocation',
          invalidValue: 110,
          max: 100,
        );

        expect(error.field, equals('allocation'));
        expect(error.invalidValue, equals(110));
        expect(error.message, equals('allocation must be at most 100'));
      });

      test('outOfRange throws when neither min nor max provided', () {
        expect(
          () => ValidationError.outOfRange(
            field: 'test',
            invalidValue: 42,
          ),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'At least one of min or max must be provided',
          )),
        );
      });

      test('invalidStockSymbol creates error for invalid ticker symbols', () {
        final error = ValidationError.invalidStockSymbol(
          field: 'symbol',
          invalidValue: 'abc123',
        );

        expect(error.field, equals('symbol'));
        expect(error.invalidValue, equals('abc123'));
        expect(
          error.message,
          equals('Stock symbol must be 1-5 uppercase letters'),
        );
      });

      test('invalidPercentage creates error for percentage out of range', () {
        final error = ValidationError.invalidPercentage(
          field: 'stopLoss',
          invalidValue: 150.5,
        );

        expect(error.field, equals('stopLoss'));
        expect(error.invalidValue, equals(150.5));
        expect(error.message, equals('stopLoss must be between 0 and 100'));
      });

      test('invalidPrice creates error for negative prices', () {
        final error = ValidationError.invalidPrice(
          field: 'pivotPrice',
          invalidValue: -10.50,
        );

        expect(error.field, equals('pivotPrice'));
        expect(error.invalidValue, equals(-10.50));
        expect(error.message, equals('pivotPrice must be a positive number'));
      });

      test('invalidQuantity creates error for invalid lot sizes', () {
        final error = ValidationError.invalidQuantity(
          field: 'lotSize',
          invalidValue: 0,
        );

        expect(error.field, equals('lotSize'));
        expect(error.invalidValue, equals(0));
        expect(error.message, equals('lotSize must be a positive integer'));
      });

      test('invalidQuantity creates error for non-integer quantities', () {
        final error = ValidationError.invalidQuantity(
          field: 'shares',
          invalidValue: 10.5,
        );

        expect(error.field, equals('shares'));
        expect(error.invalidValue, equals(10.5));
        expect(error.message, equals('shares must be a positive integer'));
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
