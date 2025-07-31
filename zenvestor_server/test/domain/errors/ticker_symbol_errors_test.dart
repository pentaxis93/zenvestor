import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/shared/errors/domain_error.dart';

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

    test('handles various invalid formats', () {
      // Use a representative sample from the fixtures
      final testCases = [
        'ABC123', // From fixtures - contains numbers
        'ABC!', // Special character
        'AB CD', // Space
        'AAPL-B', // Hyphen
        'ABC.D', // Period
        'abc', // Lowercase
      ];

      for (final invalidValue in testCases) {
        final error = TickerSymbolInvalidFormat(invalidValue);
        expect(error.actualValue, invalidValue);
      }
    });

    test('equality works correctly', () {
      const error1 = TickerSymbolInvalidFormat('abc123');
      const error2 = TickerSymbolInvalidFormat('abc123');
      const error3 = TickerSymbolInvalidFormat('xyz789');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('toString provides useful debug info', () {
      const error = TickerSymbolInvalidFormat('test@123');
      expect(
          error.toString(), 'TickerSymbolInvalidFormat(actualValue: test@123)');
    });
  });

  group('error type relationships', () {
    test('errors are distinct types', () {
      const empty = TickerSymbolEmpty();
      const tooLong = TickerSymbolTooLong(10);
      const tooShort = TickerSymbolTooShort();
      const invalidFormat = TickerSymbolInvalidFormat('abc');

      expect(empty.runtimeType, isNot(equals(tooLong.runtimeType)));
      expect(empty.runtimeType, isNot(equals(tooShort.runtimeType)));
      expect(empty.runtimeType, isNot(equals(invalidFormat.runtimeType)));
      expect(tooLong.runtimeType, isNot(equals(tooShort.runtimeType)));
    });

    test('errors implement correct interfaces', () {
      const empty = TickerSymbolEmpty();
      const tooLong = TickerSymbolTooLong(10);
      const tooShort = TickerSymbolTooShort();
      const invalidFormat = TickerSymbolInvalidFormat('abc');

      // Type checks for interface implementations
      expect(empty.fieldContext, isA<String>());
      expect(empty.providedValue, isA<Object?>());

      expect(tooLong.actualLength, isA<int>());
      expect(tooLong.maxLength, isA<int?>());

      expect(tooShort.actualLength, isA<int>());
      expect(tooShort.minLength, isA<int?>());

      expect(invalidFormat.actualValue, isA<String>());
      expect(invalidFormat.expectedFormat, isA<String>());
    });
  });

  group('business rule consistency', () {
    test('length constraints are consistent across errors', () {
      const tooLong = TickerSymbolTooLong(10);
      const tooShort = TickerSymbolTooShort();

      expect(tooLong.maxLength, equals(tooShort.maxLength));
      expect(tooLong.minLength, equals(tooShort.minLength));
      expect(tooLong.maxLength, 5);
      expect(tooLong.minLength, 1);
    });

    test('field context is consistent across all errors', () {
      // Test each error type separately to ensure they all provide
      // the same field context through their respective interfaces
      expect(const TickerSymbolEmpty().fieldContext, 'ticker symbol');
      expect(const TickerSymbolTooLong(10).fieldContext, 'ticker symbol');
      expect(const TickerSymbolTooShort().fieldContext, 'ticker symbol');
      expect(
          const TickerSymbolInvalidFormat('abc').fieldContext, 'ticker symbol');
    });
  });
}
