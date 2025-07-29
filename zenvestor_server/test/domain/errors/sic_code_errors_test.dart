import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/errors/domain_error.dart';

void main() {
  group('SicCodeError', () {
    group('SicCodeEmpty', () {
      test('should create error with provided value', () {
        const error = SicCodeEmpty('  ');

        expect(error.providedValue, '  ');
        expect(error.fieldContext, 'SIC code');
        expect(error.message, 'SIC code is required');
      });

      test('should create error without provided value', () {
        const error = SicCodeEmpty();

        expect(error.providedValue, isNull);
        expect(error.fieldContext, 'SIC code');
        expect(error.message, 'SIC code is required');
      });

      test('should have correct toString representation', () {
        const error = SicCodeEmpty('');

        expect(error.toString(), 'SicCodeEmpty(providedValue: )');
      });

      test('should support equality', () {
        const error1 = SicCodeEmpty('');
        const error2 = SicCodeEmpty('');
        const error3 = SicCodeEmpty(' ');

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });
    });

    group('SicCodeInvalidLength', () {
      test('should create error with actual length', () {
        const error = SicCodeInvalidLength(3);

        expect(error.actualLength, 3);
        expect(error.minLength, 4);
        expect(error.maxLength, 4);
        expect(error.fieldContext, 'SIC code');
        expect(error.message, 'SIC code must be exactly 4 digits (was 3)');
      });

      test('should have correct toString representation', () {
        const error = SicCodeInvalidLength(5);

        expect(error.toString(), 'SicCodeInvalidLength(actualLength: 5)');
      });

      test('should support equality', () {
        const error1 = SicCodeInvalidLength(3);
        const error2 = SicCodeInvalidLength(3);
        const error3 = SicCodeInvalidLength(5);

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });
    });

    group('SicCodeInvalidFormat', () {
      test('should create error with actual value', () {
        const error = SicCodeInvalidFormat('73A2');

        expect(error.actualValue, '73A2');
        expect(error.expectedFormat, '4 numeric digits');
        expect(error.fieldContext, 'SIC code');
        expect(error.message, 'SIC code must contain only numeric digits');
      });

      test('should have correct toString representation', () {
        const error = SicCodeInvalidFormat('ABCD');

        expect(error.toString(), 'SicCodeInvalidFormat(actualValue: ABCD)');
      });

      test('should support equality', () {
        const error1 = SicCodeInvalidFormat('73A2');
        const error2 = SicCodeInvalidFormat('73A2');
        const error3 = SicCodeInvalidFormat('AB12');

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });
    });

    group('SicCodeOutOfRange', () {
      test('should create error with actual value', () {
        const error = SicCodeOutOfRange('0000');

        expect(error.actualValue, '0000');
        expect(error.message, 'SIC code must be between 0100 and 9999');
      });

      test('should have correct toString representation', () {
        const error = SicCodeOutOfRange('0099');

        expect(error.toString(), 'SicCodeOutOfRange(actualValue: 0099)');
      });

      test('should support equality', () {
        const error1 = SicCodeOutOfRange('0000');
        const error2 = SicCodeOutOfRange('0000');
        const error3 = SicCodeOutOfRange('0099');

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });
    });

    group('polymorphism', () {
      test('all errors should be SicCodeError', () {
        const errors = [
          SicCodeEmpty(),
          SicCodeInvalidLength(3),
          SicCodeInvalidFormat('ABCD'),
          SicCodeOutOfRange('0000'),
        ];

        for (final error in errors) {
          expect(error, isA<SicCodeError>());
          expect(error, isA<DomainError>());
        }
      });

      test('errors should implement correct interfaces', () {
        const emptyError = SicCodeEmpty();
        const lengthError = SicCodeInvalidLength(3);
        const formatError = SicCodeInvalidFormat('ABCD');

        expect(emptyError, isA<RequiredFieldError>());
        expect(lengthError, isA<LengthValidationError>());
        expect(formatError, isA<FormatValidationError>());
      });
    });
  });
}
