import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/shared/errors/domain_error.dart';

import '../../fixtures/sic_code_fixtures.dart';

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
        // Use first non-numeric code from fixtures
        final invalidCode = SicCodeFixtures.nonNumericCodes.first;
        final error = SicCodeInvalidFormat(invalidCode);

        expect(error.actualValue, invalidCode);
        expect(error.expectedFormat, '4 numeric digits');
        expect(error.fieldContext, 'SIC code');
        expect(error.message, 'SIC code must contain only numeric digits');
      });

      test('should have correct toString representation', () {
        // Use a fixture value
        final invalidCode = SicCodeFixtures.nonNumericCodes[0]; // 'ABCD'
        final error = SicCodeInvalidFormat(invalidCode);

        expect(error.toString(),
            'SicCodeInvalidFormat(actualValue: $invalidCode)');
      });

      test('should support equality', () {
        // Use fixture values
        final code2 = SicCodeFixtures.nonNumericCodes[2]; // 'A372'

        const error1 = SicCodeInvalidFormat('73A2');
        const error2 = SicCodeInvalidFormat('73A2');
        final error3 = SicCodeInvalidFormat(code2);

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });
    });

    group('SicCodeOutOfRange', () {
      test('should create error with actual value', () {
        // Use first out-of-range code from fixtures
        final outOfRangeCode = SicCodeFixtures.outOfRangeCodes.first;
        final error = SicCodeOutOfRange(outOfRangeCode);

        expect(error.actualValue, outOfRangeCode);
        expect(error.message, 'SIC code must be between 0100 and 9999');
      });

      test('should have correct toString representation', () {
        // Use a specific out-of-range value from fixtures
        final outOfRangeCode = SicCodeFixtures.outOfRangeCodes[3]; // '0099'
        final error = SicCodeOutOfRange(outOfRangeCode);

        expect(error.toString(),
            'SicCodeOutOfRange(actualValue: $outOfRangeCode)');
      });

      test('should support equality', () {
        // Use fixture values
        final code1 = SicCodeFixtures.outOfRangeCodes[0]; // '0000'
        final code2 = SicCodeFixtures.outOfRangeCodes[3]; // '0099'

        final error1 = SicCodeOutOfRange(code1);
        final error2 = SicCodeOutOfRange(code1);
        final error3 = SicCodeOutOfRange(code2);

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });
    });

    group('polymorphism', () {
      test('all errors should be SicCodeError', () {
        final errors = [
          const SicCodeEmpty(),
          const SicCodeInvalidLength(3),
          SicCodeInvalidFormat(SicCodeFixtures.nonNumericCodes.first),
          SicCodeOutOfRange(SicCodeFixtures.outOfRangeCodes.first),
        ];

        for (final error in errors) {
          expect(error, isA<SicCodeError>());
          expect(error, isA<DomainError>());
        }
      });

      test('errors should implement correct interfaces', () {
        const emptyError = SicCodeEmpty();
        const lengthError = SicCodeInvalidLength(3);
        final formatError =
            SicCodeInvalidFormat(SicCodeFixtures.nonNumericCodes.first);

        expect(emptyError, isA<RequiredFieldError>());
        expect(lengthError, isA<LengthValidationError>());
        expect(formatError, isA<FormatValidationError>());
      });
    });
  });
}
