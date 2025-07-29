import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/errors/domain_error.dart';

void main() {
  group('RequiredFieldError', () {
    group('basic properties', () {
      test('provides field context', () {
        const error = TestRequiredError(
          fieldContext: 'email address',
        );

        expect(error.fieldContext, 'email address');
      });

      test('provides the actual provided value', () {
        const error = TestRequiredError(
          fieldContext: 'username',
          providedValue: '',
        );

        expect(error.providedValue, '');
      });

      test('handles null provided value', () {
        const error = TestRequiredError(
          fieldContext: 'password',
        );

        expect(error.providedValue, isNull);
      });

      test('handles non-string provided values', () {
        const error = TestRequiredError(
          fieldContext: 'count',
          providedValue: 0,
        );

        expect(error.providedValue, 0);
      });
    });

    group('equality', () {
      test('TestRequiredError equality works correctly', () {
        const error1 = TestRequiredError(
          fieldContext: 'email',
          providedValue: '',
        );
        const error2 = TestRequiredError(
          fieldContext: 'email',
          providedValue: '',
        );
        const error3 = TestRequiredError(
          fieldContext: 'email',
        );

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });
    });
  });
}
