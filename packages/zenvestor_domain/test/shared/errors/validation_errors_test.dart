import 'package:test/test.dart';
import 'package:zenvestor_domain/shared/errors.dart';

// Test implementations to verify interface contracts
class _TestLengthValidationError extends DomainError
    implements LengthValidationError {
  const _TestLengthValidationError({
    required this.actualLength,
    required this.fieldContext,
    this.maxLength,
    this.minLength,
  });

  @override
  final int actualLength;

  @override
  final int? maxLength;

  @override
  final int? minLength;

  @override
  final String fieldContext;

  @override
  List<Object?> get props => [actualLength, maxLength, minLength, fieldContext];
}

class _TestFormatValidationError extends DomainError
    implements FormatValidationError {
  const _TestFormatValidationError({
    required this.expectedFormat,
    required this.actualValue,
    required this.fieldContext,
  });

  @override
  final String expectedFormat;

  @override
  final String actualValue;

  @override
  final String fieldContext;

  @override
  List<Object?> get props => [expectedFormat, actualValue, fieldContext];
}

class _TestRequiredFieldError extends DomainError
    implements RequiredFieldError {
  const _TestRequiredFieldError({
    required this.fieldContext,
    this.providedValue,
  });

  @override
  final String fieldContext;

  @override
  final Object? providedValue;

  @override
  List<Object?> get props => [fieldContext, providedValue];
}

void main() {
  group('LengthValidationError interface', () {
    test('can be implemented with all properties', () {
      const error = _TestLengthValidationError(
        actualLength: 10,
        maxLength: 5,
        minLength: 1,
        fieldContext: 'test field',
      );

      expect(error, isA<LengthValidationError>());
      expect(error, isA<DomainError>());
      expect(error.actualLength, 10);
      expect(error.maxLength, 5);
      expect(error.minLength, 1);
      expect(error.fieldContext, 'test field');
    });

    test('supports null max and min length', () {
      const error = _TestLengthValidationError(
        actualLength: 10,
        fieldContext: 'test field',
      );

      expect(error.maxLength, isNull);
      expect(error.minLength, isNull);
    });

    test('equals and hashCode work correctly', () {
      const error1 = _TestLengthValidationError(
        actualLength: 10,
        maxLength: 5,
        fieldContext: 'field1',
      );
      const error2 = _TestLengthValidationError(
        actualLength: 10,
        maxLength: 5,
        fieldContext: 'field1',
      );
      const error3 = _TestLengthValidationError(
        actualLength: 11,
        maxLength: 5,
        fieldContext: 'field1',
      );

      expect(error1, equals(error2));
      expect(error1.hashCode, equals(error2.hashCode));
      expect(error1, isNot(equals(error3)));
    });
  });

  group('FormatValidationError interface', () {
    test('can be implemented with all properties', () {
      const error = _TestFormatValidationError(
        expectedFormat: 'uppercase letters only',
        actualValue: 'abc123',
        fieldContext: 'test field',
      );

      expect(error, isA<FormatValidationError>());
      expect(error, isA<DomainError>());
      expect(error.expectedFormat, 'uppercase letters only');
      expect(error.actualValue, 'abc123');
      expect(error.fieldContext, 'test field');
    });

    test('equals and hashCode work correctly', () {
      const error1 = _TestFormatValidationError(
        expectedFormat: 'format1',
        actualValue: 'value1',
        fieldContext: 'field1',
      );
      const error2 = _TestFormatValidationError(
        expectedFormat: 'format1',
        actualValue: 'value1',
        fieldContext: 'field1',
      );
      const error3 = _TestFormatValidationError(
        expectedFormat: 'format1',
        actualValue: 'value2',
        fieldContext: 'field1',
      );

      expect(error1, equals(error2));
      expect(error1.hashCode, equals(error2.hashCode));
      expect(error1, isNot(equals(error3)));
    });
  });

  group('RequiredFieldError interface', () {
    test('can be implemented with field context only', () {
      const error = _TestRequiredFieldError(
        fieldContext: 'email address',
      );

      expect(error, isA<RequiredFieldError>());
      expect(error, isA<DomainError>());
      expect(error.fieldContext, 'email address');
      expect(error.providedValue, isNull);
    });

    test('can track provided value', () {
      const error = _TestRequiredFieldError(
        fieldContext: 'username',
        providedValue: '',
      );

      expect(error.providedValue, '');
    });

    test('can track various types of empty values', () {
      const emptyString = _TestRequiredFieldError(
        fieldContext: 'field1',
        providedValue: '',
      );
      const whitespace = _TestRequiredFieldError(
        fieldContext: 'field2',
        providedValue: '   ',
      );
      const nullValue = _TestRequiredFieldError(
        fieldContext: 'field3',
        providedValue: null,
      );

      expect(emptyString.providedValue, '');
      expect(whitespace.providedValue, '   ');
      expect(nullValue.providedValue, isNull);
    });

    test('equals and hashCode work correctly', () {
      const error1 = _TestRequiredFieldError(
        fieldContext: 'field1',
        providedValue: '',
      );
      const error2 = _TestRequiredFieldError(
        fieldContext: 'field1',
        providedValue: '',
      );
      const error3 = _TestRequiredFieldError(
        fieldContext: 'field1',
        providedValue: null,
      );

      expect(error1, equals(error2));
      expect(error1.hashCode, equals(error2.hashCode));
      expect(error1, isNot(equals(error3)));
    });
  });

  group('interface relationships', () {
    test('all validation errors extend DomainError', () {
      final errors = [
        const _TestLengthValidationError(
          actualLength: 10,
          fieldContext: 'field',
        ),
        const _TestFormatValidationError(
          expectedFormat: 'format',
          actualValue: 'value',
          fieldContext: 'field',
        ),
        const _TestRequiredFieldError(
          fieldContext: 'field',
        ),
      ];

      for (final error in errors) {
        expect(error, isA<DomainError>());
      }
    });

    test('interfaces are distinct', () {
      const lengthError = _TestLengthValidationError(
        actualLength: 10,
        fieldContext: 'field',
      );
      const formatError = _TestFormatValidationError(
        expectedFormat: 'format',
        actualValue: 'value',
        fieldContext: 'field',
      );
      const requiredError = _TestRequiredFieldError(
        fieldContext: 'field',
      );

      expect(lengthError, isNot(isA<FormatValidationError>()));
      expect(lengthError, isNot(isA<RequiredFieldError>()));
      expect(formatError, isNot(isA<LengthValidationError>()));
      expect(formatError, isNot(isA<RequiredFieldError>()));
      expect(requiredError, isNot(isA<LengthValidationError>()));
      expect(requiredError, isNot(isA<FormatValidationError>()));
    });
  });
}
