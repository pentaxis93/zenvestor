import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/errors/domain_error.dart';
import 'package:zenvestor_server/src/domain/value_objects/company_name.dart';
import '../../fixtures/company_name_fixtures.dart';

void main() {
  group('CompanyName', () {
    group('factory constructor', () {
      group('should create valid CompanyName', () {
        test('with typical company names', () {
          for (final name in CompanyNameFixtures.validNames) {
            final result = CompanyName.create(name);
            expect(result.isRight(), isTrue,
                reason: 'Failed to create CompanyName for "$name"');
            expect(
                result.getOrElse((_) => throw Exception()).value, equals(name));
          }
        });

        test('with names containing various punctuation', () {
          for (final name in CompanyNameFixtures.namesWithPunctuation) {
            final result = CompanyName.create(name);
            expect(result.isRight(), isTrue,
                reason: 'Failed to create CompanyName for "$name"');
            expect(
                result.getOrElse((_) => throw Exception()).value, equals(name));
          }
        });

        test('with single character names', () {
          for (final name in CompanyNameFixtures.singleCharacterNames) {
            final result = CompanyName.create(name);
            expect(result.isRight(), isTrue,
                reason: 'Failed to create CompanyName for "$name"');
            expect(
                result.getOrElse((_) => throw Exception()).value, equals(name));
          }
        });

        test('with names starting with numbers', () {
          for (final name in CompanyNameFixtures.namesStartingWithNumbers) {
            final result = CompanyName.create(name);
            expect(result.isRight(), isTrue,
                reason: 'Failed to create CompanyName for "$name"');
          }
        });

        test('with exactly 255 characters', () {
          final longName = CompanyNameFixtures.generateMaxLengthName();
          final result = CompanyName.create(longName);
          expect(result.isRight(), isTrue);
          expect(result.getOrElse((_) => throw Exception()).value,
              equals(longName));
        });

        test('with minimal alphanumeric content', () {
          for (final name in CompanyNameFixtures.minimalAlphanumericNames) {
            final result = CompanyName.create(name);
            expect(result.isRight(), isTrue,
                reason: 'Failed to create CompanyName for "$name"');
          }
        });
      });

      group('should normalize input', () {
        test('by trimming leading and trailing whitespace', () {
          for (final (input, expected)
              in CompanyNameFixtures.whitespaceNormalizationCases) {
            final result = CompanyName.create(input);
            expect(result.isRight(), isTrue);
            expect(result.getOrElse((_) => throw Exception()).value,
                equals(expected));
          }
        });

        test('by normalizing multiple consecutive spaces', () {
          for (final (input, expected)
              in CompanyNameFixtures.multipleSpaceNormalizationCases) {
            final result = CompanyName.create(input);
            expect(result.isRight(), isTrue);
            expect(result.getOrElse((_) => throw Exception()).value,
                equals(expected));
          }
        });

        test('by combining whitespace normalization', () {
          const input = '  Apple    Inc.  ';
          const expected = 'Apple Inc.';
          final result = CompanyName.create(input);
          expect(result.isRight(), isTrue);
          expect(result.getOrElse((_) => throw Exception()).value,
              equals(expected));
        });
      });

      group('should return ValidationError', () {
        test('for empty string', () {
          final result = CompanyName.create('');
          expect(result.isLeft(), isTrue);
          final error = result.swap().getOrElse((_) => throw Exception());
          expect(error, isA<ValidationError>());
          expect(error.field, equals('companyName'));
          expect(error.message, contains('empty'));
        });

        test('for whitespace-only strings', () {
          // Skip empty string as it's tested separately
          final whitespaceOnlyInputs =
              CompanyNameFixtures.emptyOrWhitespaceNames.skip(1);
          for (final input in whitespaceOnlyInputs) {
            final result = CompanyName.create(input);
            expect(result.isLeft(), isTrue,
                reason: 'Should reject whitespace-only input: "$input"');
            final error = result.swap().getOrElse((_) => throw Exception());
            expect(error, isA<ValidationError>());
            expect(error.field, equals('companyName'));
            expect(error.message, contains('empty'));
          }
        });

        test('for strings without alphanumeric characters', () {
          for (final input in CompanyNameFixtures.noAlphanumericNames) {
            final result = CompanyName.create(input);
            expect(result.isLeft(), isTrue,
                reason: 'Should reject non-alphanumeric input: "$input"');
            final error = result.swap().getOrElse((_) => throw Exception());
            expect(error, isA<ValidationError>());
            expect(error.field, equals('companyName'));
            expect(error.message, contains('alphanumeric'));
          }
        });

        test('for strings exceeding 255 characters', () {
          final longName = CompanyNameFixtures.generateTooLongName();
          final result = CompanyName.create(longName);
          expect(result.isLeft(), isTrue);
          final error = result.swap().getOrElse((_) => throw Exception());
          expect(error, isA<ValidationError>());
          expect(error.field, equals('companyName'));
          expect(error.message, contains('255'));
        });

        test('for strings with invalid characters', () {
          for (final input in CompanyNameFixtures.invalidCharacterNames) {
            final result = CompanyName.create(input);
            expect(result.isLeft(), isTrue,
                reason: 'Should reject invalid character in: "$input"');
            final error = result.swap().getOrElse((_) => throw Exception());
            expect(error, isA<ValidationError>());
            expect(error.field, equals('companyName'));
            expect(error.message, contains('characters'));
          }
        });
      });
    });

    group('value equality', () {
      test('should be equal for same normalized values', () {
        final name1 = CompanyName.create('Apple Inc.')
            .getOrElse((_) => throw Exception());
        final name2 = CompanyName.create('  Apple   Inc.  ')
            .getOrElse((_) => throw Exception());
        expect(name1, equals(name2));
        expect(name1.hashCode, equals(name2.hashCode));
      });

      test('should not be equal for different values', () {
        final name1 = CompanyName.create('Apple Inc.')
            .getOrElse((_) => throw Exception());
        final name2 = CompanyName.create('Microsoft Corporation')
            .getOrElse((_) => throw Exception());
        expect(name1, isNot(equals(name2)));
      });

      test('should work as map keys', () {
        final name1 = CompanyName.create('Apple Inc.')
            .getOrElse((_) => throw Exception());
        final name2 = CompanyName.create('  Apple   Inc.  ')
            .getOrElse((_) => throw Exception());
        final name3 =
            CompanyName.create('Microsoft').getOrElse((_) => throw Exception());

        final map = <CompanyName, int>{};
        map[name1] = 1;
        map[name2] = 2;
        map[name3] = 3;

        expect(map.length, equals(2));
        expect(map[name1], equals(2));
        expect(map[name2], equals(2));
        expect(map[name3], equals(3));
      });
    });

    group('toString', () {
      test('should return the class name with value', () {
        final name = CompanyName.create('Apple Inc.')
            .getOrElse((_) => throw Exception());
        expect(name.toString(), equals('CompanyName(Apple Inc.)'));
      });

      test('should return normalized value', () {
        final name = CompanyName.create('  Microsoft   Corporation  ')
            .getOrElse((_) => throw Exception());
        expect(name.toString(), equals('CompanyName(Microsoft Corporation)'));
      });
    });
  });
}
