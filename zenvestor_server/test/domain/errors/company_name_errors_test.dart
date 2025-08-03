import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/stock/stock_errors.dart';

import '../../fixtures/company_name_fixtures.dart';

void main() {
  group('CompanyNameError hierarchy', () {
    test('all errors extend CompanyNameError', () {
      const errors = [
        CompanyNameEmpty(),
        CompanyNameTooLong(300),
        CompanyNameTooShort(),
        CompanyNameInvalidCharacters(r'Company@#$'),
        CompanyNameNoAlphanumeric('...'),
      ];

      for (final error in errors) {
        expect(error, isA<CompanyNameError>());
      }
    });
  });

  group('CompanyNameEmpty', () {
    test('implements RequiredFieldError interface', () {
      const error = CompanyNameEmpty();

      expect(error.fieldContext, 'company name');
      expect(error.providedValue, isNull);
    });

    test('tracks provided value', () {
      const error = CompanyNameEmpty('');

      expect(error.providedValue, '');
    });

    test('tracks whitespace-only value', () {
      const error = CompanyNameEmpty('   ');

      expect(error.providedValue, '   ');
    });

    test('provides meaningful message', () {
      const error = CompanyNameEmpty();
      expect(error.message, 'Company name cannot be empty');
    });

    test('equality works correctly', () {
      const error1 = CompanyNameEmpty();
      const error2 = CompanyNameEmpty();
      const error3 = CompanyNameEmpty('');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = CompanyNameEmpty('  ');
      expect(error.toString(), 'CompanyNameEmpty(providedValue:   )');
    });
  });

  group('CompanyNameTooLong', () {
    test('implements LengthValidationError interface', () {
      const error = CompanyNameTooLong(300);

      expect(error.actualLength, 300);
      expect(error.maxLength, 255);
      expect(error.minLength, 1);
      expect(error.fieldContext, 'company name');
    });

    test('computed properties work correctly', () {
      const error = CompanyNameTooLong(300);

      expect(error.actualLength, 300);
      expect(error.maxLength, 255);
      expect(error.minLength, 1);
    });

    test('provides meaningful message', () {
      const error = CompanyNameTooLong(300);
      expect(error.message,
          'Company name must be at most 255 characters (was 300)');
    });

    test('equality works correctly', () {
      const error1 = CompanyNameTooLong(300);
      const error2 = CompanyNameTooLong(300);
      const error3 = CompanyNameTooLong(400);

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = CompanyNameTooLong(300);
      expect(error.toString(), 'CompanyNameTooLong(actualLength: 300)');
    });
  });

  group('CompanyNameTooShort', () {
    test('implements LengthValidationError interface', () {
      const error = CompanyNameTooShort();

      expect(error.actualLength, 0);
      expect(error.maxLength, 255);
      expect(error.minLength, 1);
      expect(error.fieldContext, 'company name');
    });

    test('computed properties work correctly', () {
      const error = CompanyNameTooShort();

      expect(error.actualLength, 0);
      expect(error.maxLength, 255);
      expect(error.minLength, 1);
    });

    test('provides meaningful message', () {
      const error = CompanyNameTooShort();
      expect(error.message, 'Company name must be at least 1 character');
    });

    test('equality works correctly', () {
      const error1 = CompanyNameTooShort();
      const error2 = CompanyNameTooShort();

      expect(error1, equals(error2));
      expect(error1.hashCode, equals(error2.hashCode));
      expect(error1.props, equals(error2.props));
    });

    test('toString provides useful debug info', () {
      const error = CompanyNameTooShort();
      expect(error.toString(), 'CompanyNameTooShort()');
    });
  });

  group('CompanyNameInvalidCharacters', () {
    test('implements FormatValidationError interface', () {
      const error = CompanyNameInvalidCharacters(r'Company@#$');

      expect(error.actualValue, r'Company@#$');
      expect(error.expectedFormat,
          "letters, numbers, spaces, and business punctuation (.,'-&())");
      expect(error.fieldContext, 'company name');
    });

    test('provides actual invalid value', () {
      const error = CompanyNameInvalidCharacters('Invalid!');

      expect(error.actualValue, 'Invalid!');
    });

    test('provides meaningful message', () {
      const error = CompanyNameInvalidCharacters(r'Company@#$');
      expect(
          error.message,
          'Company name contains invalid characters. Only letters, numbers, '
          "spaces, and business punctuation (.,'-&()) are allowed");
    });

    test('handles various invalid characters', () {
      // Use a representative sample from the fixtures
      final testCases = CompanyNameFixtures.invalidCharacterNames.take(7);

      for (final invalidValue in testCases) {
        final error = CompanyNameInvalidCharacters(invalidValue);
        expect(error.actualValue, invalidValue);
      }
    });

    test('equality works correctly', () {
      const error1 = CompanyNameInvalidCharacters('Company@');
      const error2 = CompanyNameInvalidCharacters('Company@');
      const error3 = CompanyNameInvalidCharacters('Company#');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = CompanyNameInvalidCharacters('Test@Corp');
      expect(error.toString(),
          'CompanyNameInvalidCharacters(actualValue: Test@Corp)');
    });
  });

  group('CompanyNameNoAlphanumeric', () {
    test('implements FormatValidationError interface', () {
      const error = CompanyNameNoAlphanumeric('...');

      expect(error.actualValue, '...');
      expect(error.expectedFormat, 'at least one letter or number');
      expect(error.fieldContext, 'company name');
    });

    test('provides actual invalid value', () {
      const error = CompanyNameNoAlphanumeric('---');

      expect(error.actualValue, '---');
    });

    test('provides meaningful message', () {
      const error = CompanyNameNoAlphanumeric('...');
      expect(error.message,
          'Company name must contain at least one alphanumeric character');
    });

    test('handles various non-alphanumeric strings', () {
      // Use all non-alphanumeric examples from fixtures
      for (final invalidValue in CompanyNameFixtures.noAlphanumericNames) {
        final error = CompanyNameNoAlphanumeric(invalidValue);
        expect(error.actualValue, invalidValue);
      }
    });

    test('equality works correctly', () {
      const error1 = CompanyNameNoAlphanumeric('...');
      const error2 = CompanyNameNoAlphanumeric('...');
      const error3 = CompanyNameNoAlphanumeric('---');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = CompanyNameNoAlphanumeric('...');
      expect(error.toString(), 'CompanyNameNoAlphanumeric(actualValue: ...)');
    });
  });

  group('error type relationships', () {
    test('errors are distinct types', () {
      const empty = CompanyNameEmpty();
      const tooLong = CompanyNameTooLong(300);
      const tooShort = CompanyNameTooShort();
      const invalidChars = CompanyNameInvalidCharacters('@@@');
      const noAlphanumeric = CompanyNameNoAlphanumeric('...');

      expect(empty.runtimeType, isNot(equals(tooLong.runtimeType)));
      expect(empty.runtimeType, isNot(equals(tooShort.runtimeType)));
      expect(empty.runtimeType, isNot(equals(invalidChars.runtimeType)));
      expect(empty.runtimeType, isNot(equals(noAlphanumeric.runtimeType)));
      expect(
          invalidChars.runtimeType, isNot(equals(noAlphanumeric.runtimeType)));
    });

    test('errors implement correct interfaces', () {
      const empty = CompanyNameEmpty();
      const tooLong = CompanyNameTooLong(300);
      const tooShort = CompanyNameTooShort();
      const invalidChars = CompanyNameInvalidCharacters('@@@');
      const noAlphanumeric = CompanyNameNoAlphanumeric('...');

      // Type checks for interface implementations
      expect(empty.fieldContext, isA<String>());
      expect(empty.providedValue, isA<Object?>());

      expect(tooLong.actualLength, isA<int>());
      expect(tooLong.maxLength, isA<int?>());

      expect(tooShort.actualLength, isA<int>());
      expect(tooShort.minLength, isA<int?>());

      expect(invalidChars.actualValue, isA<String>());
      expect(invalidChars.expectedFormat, isA<String>());

      expect(noAlphanumeric.actualValue, isA<String>());
      expect(noAlphanumeric.expectedFormat, isA<String>());
    });
  });

  group('business rule consistency', () {
    test('length constraints are consistent across errors', () {
      const tooLong = CompanyNameTooLong(300);
      const tooShort = CompanyNameTooShort();

      expect(tooLong.maxLength, equals(tooShort.maxLength));
      expect(tooLong.minLength, equals(tooShort.minLength));
      expect(tooLong.maxLength, 255);
      expect(tooLong.minLength, 1);
    });

    test('field context is consistent across all errors', () {
      // Test each error type separately to ensure they all provide
      // the same field context through their respective interfaces
      expect(const CompanyNameEmpty().fieldContext, 'company name');
      expect(const CompanyNameTooLong(300).fieldContext, 'company name');
      expect(const CompanyNameTooShort().fieldContext, 'company name');
      expect(const CompanyNameInvalidCharacters('@@@').fieldContext,
          'company name');
      expect(
          const CompanyNameNoAlphanumeric('...').fieldContext, 'company name');
    });

    test('valid character format is consistent', () {
      const invalidChars = CompanyNameInvalidCharacters('test');
      expect(invalidChars.expectedFormat,
          "letters, numbers, spaces, and business punctuation (.,'-&())");
    });
  });

  group('real-world company name scenarios', () {
    test('distinguishes between different validation failures', () {
      // Empty name
      expect(const CompanyNameEmpty().message, contains('cannot be empty'));

      // Too long name (using fixture to get actual length)
      final tooLongName = CompanyNameFixtures.generateTooLongName();
      expect(CompanyNameTooLong(tooLongName.length).message,
          contains('at most 255 characters'));

      // Invalid characters
      expect(const CompanyNameInvalidCharacters('Company@Test').message,
          contains('invalid characters'));

      // No alphanumeric
      expect(const CompanyNameNoAlphanumeric('&&&').message,
          contains('at least one alphanumeric'));
    });

    test('error messages provide clear guidance', () {
      const invalidChars = CompanyNameInvalidCharacters('Test@Corp');
      expect(invalidChars.message, contains('Only letters, numbers'));
      expect(
          invalidChars.message, contains('spaces, and business punctuation'));

      const noAlpha = CompanyNameNoAlphanumeric('...');
      expect(noAlpha.message, contains('at least one alphanumeric character'));
    });
  });
}
