import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/errors/domain_error.dart';

void main() {
  group('FormatValidationError', () {
    group('basic properties', () {
      test('provides expected format description', () {
        const error = TestFormatError(
          expectedFormat: 'valid email address',
          actualValue: 'not-an-email',
          fieldContext: 'email',
        );

        expect(error.expectedFormat, 'valid email address');
      });

      test('provides actual invalid value', () {
        const error = TestFormatError(
          expectedFormat: 'phone number',
          actualValue: '123',
          fieldContext: 'phone',
        );

        expect(error.actualValue, '123');
      });

      test('provides field context', () {
        const error = TestFormatError(
          expectedFormat: 'valid format',
          actualValue: 'invalid',
          fieldContext: 'user input',
        );

        expect(error.fieldContext, 'user input');
      });
    });

    group('real-world scenarios', () {
      test('email validation error', () {
        const error = TestFormatError(
          expectedFormat: 'valid email address (e.g., user@example.com)',
          actualValue: 'user@',
          fieldContext: 'email address',
        );

        expect(error.expectedFormat, contains('valid email'));
        expect(error.actualValue, 'user@');
        expect(error.fieldContext, 'email address');
      });

      test('phone number validation error', () {
        const error = TestFormatError(
          expectedFormat: 'phone number in format XXX-XXX-XXXX',
          actualValue: '12345',
          fieldContext: 'contact phone',
        );

        expect(error.expectedFormat, contains('XXX-XXX-XXXX'));
      });

      test('stock symbol validation error', () {
        const error = TestFormatError(
          expectedFormat: '1-5 uppercase letters',
          actualValue: 'apple123',
          fieldContext: 'ticker symbol',
        );

        expect(error.expectedFormat, '1-5 uppercase letters');
        expect(error.actualValue, 'apple123');
      });
    });

    group('interface flexibility', () {
      test('supports complex format descriptions', () {
        const error = TestFormatError(
          expectedFormat: 'alphanumeric with optional hyphens and '
              'underscores, starting with a letter',
          actualValue: '123-test',
          fieldContext: 'username',
        );

        expect(error.expectedFormat, contains('alphanumeric'));
        expect(error.expectedFormat, contains('starting with a letter'));
      });

      test('supports empty actual values', () {
        const error = TestFormatError(
          expectedFormat: 'non-empty string',
          actualValue: '',
          fieldContext: 'required field',
        );

        expect(error.actualValue, isEmpty);
      });

      test('supports special characters in actual values', () {
        const error = TestFormatError(
          expectedFormat: 'alphanumeric only',
          actualValue: r'test@#$%',
          fieldContext: 'code',
        );

        expect(error.actualValue, r'test@#$%');
      });
    });

    group('equality', () {
      test('TestFormatError equality works correctly', () {
        const error1 = TestFormatError(
          expectedFormat: 'valid format',
          actualValue: 'test',
          fieldContext: 'field',
        );
        const error2 = TestFormatError(
          expectedFormat: 'valid format',
          actualValue: 'test',
          fieldContext: 'field',
        );
        const error3 = TestFormatError(
          expectedFormat: 'valid format',
          actualValue: 'different',
          fieldContext: 'field',
        );

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });
    });
  });
}
