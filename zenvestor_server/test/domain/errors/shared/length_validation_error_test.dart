import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/errors/domain_error.dart';

void main() {
  group('LengthValidationError', () {
    group('boundary conditions', () {
      test('handles exact max length', () {
        const error = TestLengthError(
          actualLength: 5,
          maxLength: 5,
          minLength: 1,
          fieldContext: 'test field',
        );

        expect(error.actualLength, 5);
        expect(error.maxLength, 5);
        expect(error.minLength, 1);
      });

      test('handles exact min length', () {
        const error = TestLengthError(
          actualLength: 1,
          maxLength: 5,
          minLength: 1,
          fieldContext: 'test field',
        );

        expect(error.actualLength, 1);
        expect(error.maxLength, 5);
        expect(error.minLength, 1);
      });

      test('handles both constraints violated (too short)', () {
        const error = TestLengthError(
          actualLength: 0,
          maxLength: 10,
          minLength: 5,
          fieldContext: 'test field',
        );

        expect(error.actualLength, 0);
        expect(error.maxLength, 10);
        expect(error.minLength, 5);
      });

      test('handles both constraints violated (too long)', () {
        const error = TestLengthError(
          actualLength: 15,
          maxLength: 10,
          minLength: 5,
          fieldContext: 'test field',
        );

        expect(error.actualLength, 15);
        expect(error.maxLength, 10);
        expect(error.minLength, 5);
      });
    });

    group('interface contract', () {
      test('fieldContext provides meaningful context', () {
        const error = TestLengthError(
          actualLength: 10,
          maxLength: 5,
          fieldContext: 'user email',
        );

        expect(error.fieldContext, 'user email');
      });

      test('actualLength reflects the actual value length', () {
        const error = TestLengthError(
          actualLength: 42,
          fieldContext: 'test field',
        );

        expect(error.actualLength, 42);
      });

      test('works with only max constraint', () {
        const error = TestLengthError(
          actualLength: 10,
          maxLength: 8,
          fieldContext: 'test field',
        );

        expect(error.maxLength, 8);
        expect(error.minLength, isNull);
        expect(error.actualLength, 10);
      });

      test('works with only min constraint', () {
        const error = TestLengthError(
          actualLength: 3,
          minLength: 5,
          fieldContext: 'test field',
        );

        expect(error.maxLength, isNull);
        expect(error.minLength, 5);
        expect(error.actualLength, 3);
      });
    });

    group('equality', () {
      test('TestLengthError equality works correctly', () {
        const error1 = TestLengthError(
          actualLength: 10,
          maxLength: 8,
          minLength: 2,
          fieldContext: 'test field',
        );
        const error2 = TestLengthError(
          actualLength: 10,
          maxLength: 8,
          minLength: 2,
          fieldContext: 'test field',
        );
        const error3 = TestLengthError(
          actualLength: 5,
          maxLength: 8,
          minLength: 2,
          fieldContext: 'test field',
        );

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });
    });
  });
}
