import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/errors/domain_error.dart';
import 'package:zenvestor_server/src/domain/value_objects/ticker_symbol.dart';

import '../../fixtures/ticker_symbol_fixtures.dart';

void main() {
  group('TickerSymbol', () {
    group('factory constructor', () {
      group('should create valid TickerSymbol', () {
        test('with single letter', () {
          for (final ticker
              in TickerSymbolFixtures.singleLetterTickers.take(3)) {
            final result = TickerSymbol.create(ticker);

            expect(result.isRight(), isTrue);
            expect(
              result.getOrElse((_) => throw Exception('Should not fail')).value,
              ticker,
            );
          }
        });

        test('with typical ticker', () {
          for (final ticker in TickerSymbolFixtures.validTickers.take(5)) {
            final result = TickerSymbol.create(ticker);

            expect(result.isRight(), isTrue);
            expect(
              result.getOrElse((_) => throw Exception('Should not fail')).value,
              ticker,
            );
          }
        });

        test('with maximum length ticker', () {
          for (final ticker in TickerSymbolFixtures.maxLengthTickers.take(3)) {
            final result = TickerSymbol.create(ticker);

            expect(result.isRight(), isTrue);
            expect(
              result.getOrElse((_) => throw Exception('Should not fail')).value,
              ticker,
            );
          }
        });

        test('normalizing case to uppercase', () {
          for (final (input, expected)
              in TickerSymbolFixtures.normalizationCases) {
            final result = TickerSymbol.create(input);

            expect(result.isRight(), isTrue);
            expect(
              result.getOrElse((_) => throw Exception('Should not fail')).value,
              expected,
            );
          }
        });

        test('trimming whitespace', () {
          for (final (input, expected)
              in TickerSymbolFixtures.whitespaceTrimCases) {
            final result = TickerSymbol.create(input);

            expect(result.isRight(), isTrue);
            expect(
              result.getOrElse((_) => throw Exception('Should not fail')).value,
              expected,
            );
          }
        });
      });

      group('should return TickerSymbolError', () {
        test('for empty or whitespace only strings', () {
          for (final invalidTicker
              in TickerSymbolFixtures.emptyOrWhitespaceTickers) {
            final result = TickerSymbol.create(invalidTicker);

            expect(result.isLeft(), isTrue);
            result.fold(
              (error) {
                expect(error, isA<TickerSymbolEmpty>());
                final emptyError = error as TickerSymbolEmpty;
                expect(emptyError.providedValue, invalidTicker);
                expect(emptyError.message, 'Ticker symbol is required');
              },
              (success) => fail('Should have failed'),
            );
          }
        });

        test('for ticker longer than 5 characters', () {
          for (final invalidTicker
              in TickerSymbolFixtures.tooLongTickers.take(3)) {
            final result = TickerSymbol.create(invalidTicker);

            expect(result.isLeft(), isTrue);
            result.fold(
              (error) {
                expect(error, isA<TickerSymbolTooLong>());
                final lengthError = error as TickerSymbolTooLong;
                expect(lengthError.actualLength, greaterThan(5));
                expect(
                  lengthError.message,
                  contains('must be at most 5 characters'),
                );
              },
              (success) => fail('Should have failed'),
            );
          }
        });

        test('for ticker with invalid characters', () {
          // Test a representative sample of invalid characters
          final testCases = [
            'ABC123', // Numbers
            'ABC.D', // Period
            'AB CD', // Space
            'ABC-D', // Hyphen
            'ABC_D', // Underscore
            'ABC@', // Special character
            '123', // Only numbers
          ];

          for (final invalidTicker in testCases) {
            final result = TickerSymbol.create(invalidTicker);

            expect(result.isLeft(), isTrue);
            result.fold(
              (error) {
                expect(error, isA<TickerSymbolInvalidFormat>());
                final formatError = error as TickerSymbolInvalidFormat;
                expect(formatError.actualValue, invalidTicker);
                expect(
                  formatError.message,
                  'Ticker symbol must contain only uppercase letters A-Z',
                );
              },
              (success) => fail('Should have failed for $invalidTicker'),
            );
          }
        });
      });
    });

    group('value property', () {
      test('should return the normalized ticker value', () {
        final testCase = TickerSymbolFixtures.normalizationCases.first;
        final ticker = TickerSymbol.create(testCase.$1)
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(ticker.value, testCase.$2);
      });
    });

    group('toString', () {
      test('should return formatted string', () {
        final testTicker = TickerSymbolFixtures.validTickers.first;
        final ticker = TickerSymbol.create(testTicker)
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(ticker.toString(), 'TickerSymbol($testTicker)');
      });
    });

    group('equality', () {
      test('should be equal for same values', () {
        final testTicker = TickerSymbolFixtures.validTickers.first;
        final ticker1 = TickerSymbol.create(testTicker)
            .getOrElse((_) => throw Exception('Should not fail'));
        final ticker2 = TickerSymbol.create(testTicker)
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(ticker1, equals(ticker2));
        expect(ticker1.hashCode, equals(ticker2.hashCode));
      });

      test('should be equal for normalized values', () {
        final testCase = TickerSymbolFixtures.normalizationCases.first;
        final ticker1 = TickerSymbol.create(testCase.$1)
            .getOrElse((_) => throw Exception('Should not fail'));
        final ticker2 = TickerSymbol.create(testCase.$2)
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(ticker1, equals(ticker2));
        expect(ticker1.hashCode, equals(ticker2.hashCode));
      });

      test('should not be equal for different values', () {
        final ticker1 =
            TickerSymbol.create(TickerSymbolFixtures.validTickers[0])
                .getOrElse((_) => throw Exception('Should not fail'));
        final ticker2 =
            TickerSymbol.create(TickerSymbolFixtures.validTickers[1])
                .getOrElse((_) => throw Exception('Should not fail'));

        expect(ticker1, isNot(equals(ticker2)));
      });
    });

    group('as Map key', () {
      test('should work as Map key', () {
        final testCase = TickerSymbolFixtures.normalizationCases.first;
        final ticker1 = TickerSymbol.create(testCase.$2) // AAPL
            .getOrElse((_) => throw Exception('Should not fail'));
        final ticker2 = TickerSymbol.create(testCase.$1) // aapl
            .getOrElse((_) => throw Exception('Should not fail'));
        final ticker3 =
            TickerSymbol.create(TickerSymbolFixtures.validTickers[1])
                .getOrElse((_) => throw Exception('Should not fail'));

        final map = <TickerSymbol, String>{
          ticker1: 'Apple Inc.',
          ticker3: 'Alphabet Inc.',
        };

        expect(map[ticker1], 'Apple Inc.');
        expect(map[ticker2], 'Apple Inc.'); // Same as ticker1 when normalized
        expect(map[ticker3], 'Alphabet Inc.');
        expect(map.length, 2);
      });

      test('should replace value when using normalized equivalent as key', () {
        final testCase = TickerSymbolFixtures.normalizationCases.first;
        final ticker1 = TickerSymbol.create(testCase.$2) // AAPL
            .getOrElse((_) => throw Exception('Should not fail'));
        final ticker2 = TickerSymbol.create(testCase.$1) // aapl
            .getOrElse((_) => throw Exception('Should not fail'));

        final map = <TickerSymbol, String>{
          ticker1: 'First value',
        };
        map[ticker2] = 'Second value';

        expect(map.length, 1);
        expect(map[ticker1], 'Second value');
        expect(map[ticker2], 'Second value');
      });
    });
  });
}
