import 'package:test/test.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart';

void main() {
  group('TickerSymbolError hierarchy', () {
    test('all errors extend TickerSymbolError', () {
      const errors = [
        TickerSymbolEmpty(),
        TickerSymbolTooLong(10),
        TickerSymbolTooShort(),
        TickerSymbolInvalidFormat('abc123'),
      ];

      for (final error in errors) {
        expect(error, isA<TickerSymbolError>());
        expect(error, isA<DomainError>());
      }
    });
  });

  group('TickerSymbolEmpty', () {
    test('implements RequiredFieldError interface', () {
      const error = TickerSymbolEmpty();

      expect(error.fieldContext, 'ticker symbol');
      expect(error.providedValue, isNull);
    });

    test('tracks provided value', () {
      const error = TickerSymbolEmpty('');

      expect(error.providedValue, '');
    });

    test('tracks whitespace-only value', () {
      const error = TickerSymbolEmpty('   ');

      expect(error.providedValue, '   ');
    });

    test('provides meaningful message', () {
      const error = TickerSymbolEmpty();
      expect(error.message, 'Ticker symbol is required');
    });

    test('equality works correctly', () {
      const error1 = TickerSymbolEmpty();
      const error2 = TickerSymbolEmpty();
      const error3 = TickerSymbolEmpty('');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = TickerSymbolEmpty('  ');
      expect(error.toString(), 'TickerSymbolEmpty(providedValue:   )');
    });
  });

  group('TickerSymbolTooLong', () {
    test('implements LengthValidationError interface', () {
      const error = TickerSymbolTooLong(8);

      expect(error.actualLength, 8);
      expect(error.maxLength, 5);
      expect(error.minLength, 1);
      expect(error.fieldContext, 'ticker symbol');
    });

    test('computed properties work correctly', () {
      const error = TickerSymbolTooLong(8);

      expect(error.actualLength, 8);
      expect(error.maxLength, 5);
      expect(error.minLength, 1);
    });

    test('provides meaningful message', () {
      const error = TickerSymbolTooLong(8);
      expect(
          error.message, 'Ticker symbol must be at most 5 characters (was 8)');
    });

    test('equality works correctly', () {
      const error1 = TickerSymbolTooLong(8);
      const error2 = TickerSymbolTooLong(8);
      const error3 = TickerSymbolTooLong(10);

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = TickerSymbolTooLong(10);
      expect(error.toString(), 'TickerSymbolTooLong(actualLength: 10)');
    });
  });

  group('TickerSymbolTooShort', () {
    test('implements LengthValidationError interface', () {
      const error = TickerSymbolTooShort();

      expect(error.actualLength, 0);
      expect(error.maxLength, 5);
      expect(error.minLength, 1);
      expect(error.fieldContext, 'ticker symbol');
    });

    test('computed properties work correctly', () {
      const error = TickerSymbolTooShort();

      expect(error.actualLength, 0);
      expect(error.maxLength, 5);
      expect(error.minLength, 1);
    });

    test('provides meaningful message', () {
      const error = TickerSymbolTooShort();
      expect(error.message, 'Ticker symbol must be at least 1 character');
    });

    test('equality works correctly', () {
      const error1 = TickerSymbolTooShort();
      const error2 = TickerSymbolTooShort();

      expect(error1, equals(error2));
      expect(error1.hashCode, equals(error2.hashCode));
      expect(error1.props, equals(error2.props));
    });

    test('toString provides useful debug info', () {
      const error = TickerSymbolTooShort();
      expect(error.toString(), 'TickerSymbolTooShort()');
    });
  });

  group('TickerSymbolInvalidFormat', () {
    test('implements FormatValidationError interface', () {
      const error = TickerSymbolInvalidFormat('abc123');

      expect(error.actualValue, 'abc123');
      expect(error.expectedFormat, '1-5 uppercase letters (A-Z only)');
      expect(error.fieldContext, 'ticker symbol');
    });

    test('provides actual invalid value', () {
      const error = TickerSymbolInvalidFormat('test');

      expect(error.actualValue, 'test');
    });

    test('provides meaningful message', () {
      const error = TickerSymbolInvalidFormat('abc123');
      expect(error.message,
          'Ticker symbol must contain only uppercase letters A-Z');
    });

    test('equality works correctly', () {
      const error1 = TickerSymbolInvalidFormat('abc123');
      const error2 = TickerSymbolInvalidFormat('abc123');
      const error3 = TickerSymbolInvalidFormat('xyz789');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = TickerSymbolInvalidFormat('test123');
      expect(
          error.toString(), 'TickerSymbolInvalidFormat(actualValue: test123)');
    });
  });

  group('CompanyNameError hierarchy', () {
    test('all errors extend CompanyNameError', () {
      const errors = [
        CompanyNameEmpty(),
        CompanyNameTooLong(300),
        CompanyNameTooShort(),
        CompanyNameInvalidCharacters('Test@#%'),
        CompanyNameNoAlphanumeric('...'),
      ];

      for (final error in errors) {
        expect(error, isA<CompanyNameError>());
        expect(error, isA<DomainError>());
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

    test('provides meaningful message', () {
      const error = CompanyNameTooShort();
      expect(error.message, 'Company name must be at least 1 character');
    });

    test('equality works correctly', () {
      const error1 = CompanyNameTooShort();
      const error2 = CompanyNameTooShort();

      expect(error1, equals(error2));
    });

    test('toString provides useful debug info', () {
      const error = CompanyNameTooShort();
      expect(error.toString(), 'CompanyNameTooShort()');
    });
  });

  group('CompanyNameInvalidCharacters', () {
    test('implements FormatValidationError interface', () {
      const error = CompanyNameInvalidCharacters('Test@#%');

      expect(error.actualValue, 'Test@#%');
      expect(error.expectedFormat,
          "letters, numbers, spaces, and business punctuation (.,'-&())");
      expect(error.fieldContext, 'company name');
    });

    test('provides meaningful message', () {
      const error = CompanyNameInvalidCharacters('Test@#%');
      expect(
          error.message, contains('Company name contains invalid characters'));
      expect(error.message,
          contains("Only letters, numbers, spaces, and business punctuation"));
    });

    test('equality works correctly', () {
      const error1 = CompanyNameInvalidCharacters('Test@#%');
      const error2 = CompanyNameInvalidCharacters('Test@#%');
      const error3 = CompanyNameInvalidCharacters('Different@#%');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = CompanyNameInvalidCharacters('Test@#%');
      expect(error.toString(),
          'CompanyNameInvalidCharacters(actualValue: Test@#%)');
    });
  });

  group('CompanyNameNoAlphanumeric', () {
    test('implements FormatValidationError interface', () {
      const error = CompanyNameNoAlphanumeric('...');

      expect(error.actualValue, '...');
      expect(error.expectedFormat, 'at least one letter or number');
      expect(error.fieldContext, 'company name');
    });

    test('provides meaningful message', () {
      const error = CompanyNameNoAlphanumeric('...');
      expect(error.message,
          'Company name must contain at least one alphanumeric character');
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

  group('SicCodeError hierarchy', () {
    test('all errors extend SicCodeError', () {
      const errors = [
        SicCodeEmpty(),
        SicCodeInvalidLength(3),
        SicCodeInvalidFormat('123A'),
        SicCodeOutOfRange('0099'),
      ];

      for (final error in errors) {
        expect(error, isA<SicCodeError>());
        expect(error, isA<DomainError>());
      }
    });
  });

  group('SicCodeEmpty', () {
    test('implements RequiredFieldError interface', () {
      const error = SicCodeEmpty();

      expect(error.fieldContext, 'SIC code');
      expect(error.providedValue, isNull);
    });

    test('tracks provided value', () {
      const error = SicCodeEmpty('');

      expect(error.providedValue, '');
    });

    test('provides meaningful message', () {
      const error = SicCodeEmpty();
      expect(error.message, 'SIC code is required');
    });

    test('equality works correctly', () {
      const error1 = SicCodeEmpty();
      const error2 = SicCodeEmpty();
      const error3 = SicCodeEmpty('');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = SicCodeEmpty('  ');
      expect(error.toString(), 'SicCodeEmpty(providedValue:   )');
    });
  });

  group('SicCodeInvalidLength', () {
    test('implements LengthValidationError interface', () {
      const error = SicCodeInvalidLength(3);

      expect(error.actualLength, 3);
      expect(error.maxLength, 4);
      expect(error.minLength, 4);
      expect(error.fieldContext, 'SIC code');
    });

    test('provides meaningful message', () {
      const error = SicCodeInvalidLength(3);
      expect(error.message, 'SIC code must be exactly 4 digits (was 3)');
    });

    test('equality works correctly', () {
      const error1 = SicCodeInvalidLength(3);
      const error2 = SicCodeInvalidLength(3);
      const error3 = SicCodeInvalidLength(5);

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = SicCodeInvalidLength(3);
      expect(error.toString(), 'SicCodeInvalidLength(actualLength: 3)');
    });
  });

  group('SicCodeInvalidFormat', () {
    test('implements FormatValidationError interface', () {
      const error = SicCodeInvalidFormat('123A');

      expect(error.actualValue, '123A');
      expect(error.expectedFormat, '4 numeric digits');
      expect(error.fieldContext, 'SIC code');
    });

    test('provides meaningful message', () {
      const error = SicCodeInvalidFormat('123A');
      expect(error.message, 'SIC code must contain only numeric digits');
    });

    test('equality works correctly', () {
      const error1 = SicCodeInvalidFormat('123A');
      const error2 = SicCodeInvalidFormat('123A');
      const error3 = SicCodeInvalidFormat('456B');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = SicCodeInvalidFormat('123A');
      expect(error.toString(), 'SicCodeInvalidFormat(actualValue: 123A)');
    });
  });

  group('SicCodeOutOfRange', () {
    test('extends SicCodeError', () {
      const error = SicCodeOutOfRange('0099');
      expect(error, isA<SicCodeError>());
      expect(error, isA<DomainError>());
    });

    test('stores actual value', () {
      const error = SicCodeOutOfRange('0099');
      expect(error.actualValue, '0099');
    });

    test('provides meaningful message', () {
      const error = SicCodeOutOfRange('0099');
      expect(error.message, 'SIC code must be between 0100 and 9999');
    });

    test('equality works correctly', () {
      const error1 = SicCodeOutOfRange('0099');
      const error2 = SicCodeOutOfRange('0099');
      const error3 = SicCodeOutOfRange('0050');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = SicCodeOutOfRange('0099');
      expect(error.toString(), 'SicCodeOutOfRange(actualValue: 0099)');
    });
  });

  group('GradeError hierarchy', () {
    test('all errors extend GradeError', () {
      const errors = [
        GradeEmpty(),
        GradeInvalidValue('E'),
      ];

      for (final error in errors) {
        expect(error, isA<GradeError>());
        expect(error, isA<DomainError>());
      }
    });
  });

  group('GradeEmpty', () {
    test('implements RequiredFieldError interface', () {
      const error = GradeEmpty();

      expect(error.fieldContext, 'grade');
      expect(error.providedValue, isNull);
    });

    test('tracks provided value', () {
      const error = GradeEmpty('');

      expect(error.providedValue, '');
    });

    test('provides meaningful message', () {
      const error = GradeEmpty();
      expect(error.message, 'Grade cannot be empty');
    });

    test('equality works correctly', () {
      const error1 = GradeEmpty();
      const error2 = GradeEmpty();
      const error3 = GradeEmpty('');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = GradeEmpty('  ');
      expect(error.toString(), 'GradeEmpty(providedValue:   )');
    });
  });

  group('GradeInvalidValue', () {
    test('implements FormatValidationError interface', () {
      const error = GradeInvalidValue('E');

      expect(error.actualValue, 'E');
      expect(error.expectedFormat, 'A, B, C, D, or F');
      expect(error.fieldContext, 'grade');
    });

    test('provides meaningful message', () {
      const error = GradeInvalidValue('E');
      expect(error.message, 'Grade must be A, B, C, D, or F');
    });

    test('equality works correctly', () {
      const error1 = GradeInvalidValue('E');
      const error2 = GradeInvalidValue('E');
      const error3 = GradeInvalidValue('G');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = GradeInvalidValue('E');
      expect(error.toString(), 'GradeInvalidValue(actualValue: E)');
    });
  });

  group('error type relationships', () {
    test('different error hierarchies are distinct', () {
      const tickerError = TickerSymbolEmpty();
      const companyError = CompanyNameEmpty();
      const sicError = SicCodeEmpty();
      const gradeError = GradeEmpty();

      // All are DomainErrors
      expect(tickerError, isA<DomainError>());
      expect(companyError, isA<DomainError>());
      expect(sicError, isA<DomainError>());
      expect(gradeError, isA<DomainError>());

      // But different hierarchies
      expect(tickerError, isNot(isA<CompanyNameError>()));
      expect(companyError, isNot(isA<SicCodeError>()));
      expect(sicError, isNot(isA<GradeError>()));
      expect(tickerError, isNot(isA<StockError>()));
    });
  });
}
