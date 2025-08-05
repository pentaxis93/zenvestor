import 'package:test/test.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart' show SicCode;
import 'package:zenvestor_server/src/domain/stock/stock_errors.dart';

import '../../fixtures/sic_code_fixtures.dart';

void main() {
  group('SicCode', () {
    group('factory constructor', () {
      group('should create valid SicCode', () {
        test('with typical SIC codes', () {
          for (final code in SicCodeFixtures.validCodes.take(5)) {
            final result = SicCode.create(code);

            expect(result.isRight(), isTrue);
            expect(
              result.getOrElse((_) => throw Exception('Should not fail')).value,
              code,
            );
          }
        });

        test('with minimum valid code', () {
          final result = SicCode.create(SicCodeFixtures.minimumValidCode);

          expect(result.isRight(), isTrue);
          expect(
            result.getOrElse((_) => throw Exception('Should not fail')).value,
            SicCodeFixtures.minimumValidCode,
          );
        });

        test('with maximum valid code', () {
          final result = SicCode.create(SicCodeFixtures.maximumValidCode);

          expect(result.isRight(), isTrue);
          expect(
            result.getOrElse((_) => throw Exception('Should not fail')).value,
            SicCodeFixtures.maximumValidCode,
          );
        });

        test('preserving leading zeros', () {
          for (final code in SicCodeFixtures.codesWithLeadingZeros) {
            final result = SicCode.create(code);

            expect(result.isRight(), isTrue);
            expect(
              result.getOrElse((_) => throw Exception('Should not fail')).value,
              code,
            );
          }
        });

        test('trimming whitespace', () {
          for (final (input, expected) in SicCodeFixtures.whitespaceTrimCases) {
            final result = SicCode.create(input);

            expect(result.isRight(), isTrue);
            expect(
              result.getOrElse((_) => throw Exception('Should not fail')).value,
              expected,
            );
          }
        });

        test('normalizing short codes with leading zeros', () {
          for (final (input, expected) in SicCodeFixtures.normalizationCases) {
            final result = SicCode.create(input);

            // Some normalized codes may still be out of range
            if (expected == '0001' ||
                expected == '0007' ||
                expected == '0050' ||
                expected == '0099') {
              expect(result.isLeft(), isTrue);
              result.fold(
                (error) => expect(error, isA<SicCodeOutOfRange>()),
                (success) => fail('Should have failed for out of range code'),
              );
            } else {
              expect(
                result.isRight(),
                isTrue,
                reason: 'Failed for input: $input',
              );
              expect(
                result
                    .getOrElse((_) => throw Exception('Should not fail'))
                    .value,
                expected,
                reason: 'Expected $expected for input $input',
              );
            }
          }
        });
      });

      group('should return SicCodeError', () {
        test('for empty or whitespace only strings', () {
          for (final invalidCode in SicCodeFixtures.emptyOrWhitespaceCodes) {
            final result = SicCode.create(invalidCode);

            expect(result.isLeft(), isTrue);
            result.fold(
              (error) {
                expect(error, isA<SicCodeEmpty>());
                final emptyError = error as SicCodeEmpty;
                expect(emptyError.providedValue, invalidCode);
                expect(emptyError.message, 'SIC code is required');
              },
              (success) => fail('Should have failed'),
            );
          }
        });

        test('for codes with invalid length', () {
          for (final invalidCode in SicCodeFixtures.invalidLengthCodes) {
            final result = SicCode.create(invalidCode);

            expect(result.isLeft(), isTrue);
            result.fold(
              (error) {
                expect(error, isA<SicCodeInvalidLength>());
                final lengthError = error as SicCodeInvalidLength;
                expect(lengthError.actualLength, isNot(4));
                expect(
                  lengthError.message,
                  contains('must be exactly 4 digits'),
                );
              },
              (success) => fail('Should have failed'),
            );
          }
        });

        test('for codes with non-numeric characters', () {
          for (final invalidCode in SicCodeFixtures.nonNumericCodes) {
            final result = SicCode.create(invalidCode);

            expect(result.isLeft(), isTrue);
            result.fold(
              (error) {
                expect(error, isA<SicCodeInvalidFormat>());
                final formatError = error as SicCodeInvalidFormat;
                expect(formatError.actualValue, invalidCode.trim());
                expect(
                  formatError.message,
                  'SIC code must contain only numeric digits',
                );
              },
              (success) => fail('Should have failed for $invalidCode'),
            );
          }
        });

        test('for codes outside valid range', () {
          for (final invalidCode in SicCodeFixtures.outOfRangeCodes) {
            final result = SicCode.create(invalidCode);

            expect(result.isLeft(), isTrue);
            result.fold(
              (error) {
                expect(error, isA<SicCodeOutOfRange>());
                final rangeError = error as SicCodeOutOfRange;
                // For normalized values, actualValue will show both
                // original and normalized
                expect(rangeError.actualValue, contains(invalidCode));
                expect(
                  rangeError.message,
                  contains('must be between 0100 and 9999'),
                );
              },
              (success) => fail('Should have failed for $invalidCode'),
            );
          }
        });
      });
    });

    group('value property', () {
      test('should return the SIC code value with leading zeros preserved', () {
        final code = SicCode.create('0111')
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(code.value, '0111');
      });
    });

    group('toString', () {
      test('should return formatted string', () {
        final code = SicCode.create('7372')
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(code.toString(), 'SicCode(7372)');
      });
    });

    group('toJson', () {
      test('should return the code value', () {
        final code = SicCode.create('7372')
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(code.toJson(), '7372');
      });

      test('should preserve leading zeros in JSON', () {
        final code = SicCode.create('0111')
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(code.toJson(), '0111');
      });
    });

    group('fromJson', () {
      test('should create SicCode from valid JSON string', () {
        final result = SicCode.fromJson('7372');

        expect(result.isRight(), isTrue);
        expect(
          result.getOrElse((_) => throw Exception('Should not fail')).value,
          '7372',
        );
      });

      test('should create SicCode with leading zeros from JSON', () {
        final result = SicCode.fromJson('0111');

        expect(result.isRight(), isTrue);
        expect(
          result.getOrElse((_) => throw Exception('Should not fail')).value,
          '0111',
        );
      });

      test('should fail for invalid JSON input', () {
        final result = SicCode.fromJson('ABCD');

        expect(result.isLeft(), isTrue);
        result.fold(
          (error) => expect(error, isA<SicCodeInvalidFormat>()),
          (success) => fail('Should have failed'),
        );
      });
    });

    group('equality', () {
      test('should be equal for same values', () {
        final code1 = SicCode.create('7372')
            .getOrElse((_) => throw Exception('Should not fail'));
        final code2 = SicCode.create('7372')
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(code1, equals(code2));
        expect(code1.hashCode, equals(code2.hashCode));
      });

      test('should be equal for trimmed values', () {
        final code1 = SicCode.create('7372')
            .getOrElse((_) => throw Exception('Should not fail'));
        final code2 = SicCode.create('  7372  ')
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(code1, equals(code2));
        expect(code1.hashCode, equals(code2.hashCode));
      });

      test('should not be equal for different values', () {
        final code1 = SicCode.create('7372')
            .getOrElse((_) => throw Exception('Should not fail'));
        final code2 = SicCode.create('5812')
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(code1, isNot(equals(code2)));
      });
    });

    group('as Map key', () {
      test('should work as Map key', () {
        final code1 = SicCode.create('7372')
            .getOrElse((_) => throw Exception('Should not fail'));
        final code2 = SicCode.create('5812')
            .getOrElse((_) => throw Exception('Should not fail'));
        final code3 = SicCode.create('0111')
            .getOrElse((_) => throw Exception('Should not fail'));

        final map = <SicCode, String>{
          code1: 'Prepackaged Software',
          code2: 'Eating Places',
          code3: 'Wheat',
        };

        expect(map[code1], 'Prepackaged Software');
        expect(map[code2], 'Eating Places');
        expect(map[code3], 'Wheat');
        expect(map.length, 3);
      });

      test('should replace value when using equivalent as key', () {
        final code1 = SicCode.create('7372')
            .getOrElse((_) => throw Exception('Should not fail'));
        final code2 = SicCode.create('  7372  ')
            .getOrElse((_) => throw Exception('Should not fail'));

        final map = <SicCode, String>{
          code1: 'First value',
        };
        map[code2] = 'Second value';

        expect(map.length, 1);
        expect(map[code1], 'Second value');
        expect(map[code2], 'Second value');
      });
    });
  });
}
