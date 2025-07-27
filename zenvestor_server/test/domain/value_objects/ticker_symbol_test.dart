import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/value_objects/ticker_symbol.dart';

void main() {
  group('TickerSymbol', () {
    group('factory constructor', () {
      group('should create valid TickerSymbol', () {
        test('with single letter', () {
          final result = TickerSymbol.create('F');

          expect(result.isRight(), isTrue);
          expect(
            result.getOrElse((_) => throw Exception('Should not fail')).value,
            'F',
          );
        });

        test('with typical ticker', () {
          final result = TickerSymbol.create('AAPL');

          expect(result.isRight(), isTrue);
          expect(
            result.getOrElse((_) => throw Exception('Should not fail')).value,
            'AAPL',
          );
        });

        test('with maximum length ticker', () {
          final result = TickerSymbol.create('GOOGL');

          expect(result.isRight(), isTrue);
          expect(
            result.getOrElse((_) => throw Exception('Should not fail')).value,
            'GOOGL',
          );
        });

        test('normalizing lowercase to uppercase', () {
          final result = TickerSymbol.create('aapl');

          expect(result.isRight(), isTrue);
          expect(
            result.getOrElse((_) => throw Exception('Should not fail')).value,
            'AAPL',
          );
        });

        test('normalizing mixed case to uppercase', () {
          final result = TickerSymbol.create('AaPl');

          expect(result.isRight(), isTrue);
          expect(
            result.getOrElse((_) => throw Exception('Should not fail')).value,
            'AAPL',
          );
        });

        test('trimming leading whitespace', () {
          final result = TickerSymbol.create('  AAPL');

          expect(result.isRight(), isTrue);
          expect(
            result.getOrElse((_) => throw Exception('Should not fail')).value,
            'AAPL',
          );
        });

        test('trimming trailing whitespace', () {
          final result = TickerSymbol.create('AAPL  ');

          expect(result.isRight(), isTrue);
          expect(
            result.getOrElse((_) => throw Exception('Should not fail')).value,
            'AAPL',
          );
        });

        test('trimming both sides whitespace', () {
          final result = TickerSymbol.create('  AAPL  ');

          expect(result.isRight(), isTrue);
          expect(
            result.getOrElse((_) => throw Exception('Should not fail')).value,
            'AAPL',
          );
        });
      });

      group('should return ValidationError', () {
        test('for empty string', () {
          final result = TickerSymbol.create('');

          expect(result.isLeft(), isTrue);
          result.fold(
            (error) {
              expect(error.field, 'ticker_symbol');
              expect(error.invalidValue, '');
              expect(error.message, 'ticker_symbol is required');
            },
            (success) => fail('Should have failed'),
          );
        });

        test('for whitespace only string', () {
          final result = TickerSymbol.create('   ');

          expect(result.isLeft(), isTrue);
          result.fold(
            (error) {
              expect(error.field, 'ticker_symbol');
              expect(error.invalidValue, '   ');
              expect(error.message, 'ticker_symbol is required');
            },
            (success) => fail('Should have failed'),
          );
        });

        test('for ticker longer than 5 characters', () {
          final result = TickerSymbol.create('ABCDEF');

          expect(result.isLeft(), isTrue);
          result.fold(
            (error) {
              expect(error.field, 'ticker_symbol');
              expect(error.invalidValue, 'ABCDEF');
              expect(
                error.message,
                'ticker_symbol must be at most 5 characters',
              );
            },
            (success) => fail('Should have failed'),
          );
        });

        test('for ticker with numbers', () {
          final result = TickerSymbol.create('ABC123');

          expect(result.isLeft(), isTrue);
          result.fold(
            (error) {
              expect(error.field, 'ticker_symbol');
              expect(error.invalidValue, 'ABC123');
              expect(
                error.message,
                'ticker_symbol must contain only letters A-Z',
              );
            },
            (success) => fail('Should have failed'),
          );
        });

        test('for ticker with special characters', () {
          final result = TickerSymbol.create('ABC.D');

          expect(result.isLeft(), isTrue);
          result.fold(
            (error) {
              expect(error.field, 'ticker_symbol');
              expect(error.invalidValue, 'ABC.D');
              expect(
                error.message,
                'ticker_symbol must contain only letters A-Z',
              );
            },
            (success) => fail('Should have failed'),
          );
        });

        test('for ticker with spaces', () {
          final result = TickerSymbol.create('AB CD');

          expect(result.isLeft(), isTrue);
          result.fold(
            (error) {
              expect(error.field, 'ticker_symbol');
              expect(error.invalidValue, 'AB CD');
              expect(
                error.message,
                'ticker_symbol must contain only letters A-Z',
              );
            },
            (success) => fail('Should have failed'),
          );
        });

        test('for ticker with hyphen', () {
          final result = TickerSymbol.create('ABC-D');

          expect(result.isLeft(), isTrue);
          result.fold(
            (error) {
              expect(error.field, 'ticker_symbol');
              expect(error.invalidValue, 'ABC-D');
              expect(
                error.message,
                'ticker_symbol must contain only letters A-Z',
              );
            },
            (success) => fail('Should have failed'),
          );
        });

        test('for ticker with underscore', () {
          final result = TickerSymbol.create('ABC_D');

          expect(result.isLeft(), isTrue);
          result.fold(
            (error) {
              expect(error.field, 'ticker_symbol');
              expect(error.invalidValue, 'ABC_D');
              expect(
                error.message,
                'ticker_symbol must contain only letters A-Z',
              );
            },
            (success) => fail('Should have failed'),
          );
        });
      });
    });

    group('value property', () {
      test('should return the normalized ticker value', () {
        final ticker = TickerSymbol.create('aapl')
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(ticker.value, 'AAPL');
      });
    });

    group('toString', () {
      test('should return formatted string', () {
        final ticker = TickerSymbol.create('AAPL')
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(ticker.toString(), 'TickerSymbol(AAPL)');
      });
    });

    group('equality', () {
      test('should be equal for same values', () {
        final ticker1 = TickerSymbol.create('AAPL')
            .getOrElse((_) => throw Exception('Should not fail'));
        final ticker2 = TickerSymbol.create('AAPL')
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(ticker1, equals(ticker2));
        expect(ticker1.hashCode, equals(ticker2.hashCode));
      });

      test('should be equal for normalized values', () {
        final ticker1 = TickerSymbol.create('aapl')
            .getOrElse((_) => throw Exception('Should not fail'));
        final ticker2 = TickerSymbol.create('AAPL')
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(ticker1, equals(ticker2));
        expect(ticker1.hashCode, equals(ticker2.hashCode));
      });

      test('should not be equal for different values', () {
        final ticker1 = TickerSymbol.create('AAPL')
            .getOrElse((_) => throw Exception('Should not fail'));
        final ticker2 = TickerSymbol.create('GOOGL')
            .getOrElse((_) => throw Exception('Should not fail'));

        expect(ticker1, isNot(equals(ticker2)));
      });
    });

    group('as Map key', () {
      test('should work as Map key', () {
        final ticker1 = TickerSymbol.create('AAPL')
            .getOrElse((_) => throw Exception('Should not fail'));
        final ticker2 = TickerSymbol.create('aapl')
            .getOrElse((_) => throw Exception('Should not fail'));
        final ticker3 = TickerSymbol.create('GOOGL')
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
        final ticker1 = TickerSymbol.create('AAPL')
            .getOrElse((_) => throw Exception('Should not fail'));
        final ticker2 = TickerSymbol.create('aapl')
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
