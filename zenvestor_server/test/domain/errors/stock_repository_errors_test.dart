import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/shared/errors/domain_error.dart';

import '../../fixtures/domain_fixtures.dart';

void main() {
  group('StockRepositoryError', () {
    group('StockAlreadyExistsError', () {
      test('should be a DomainError', () {
        final ticker = DomainFixtures.tickerSymbol();
        final error = StockAlreadyExistsError(ticker);

        expect(error, isA<DomainError>());
        expect(error, isA<StockRepositoryError>());
      });

      test('should have correct props', () {
        final ticker = DomainFixtures.tickerSymbol();
        final error = StockAlreadyExistsError(ticker);

        expect(error.props, equals([ticker]));
      });

      test('should have meaningful toString', () {
        final ticker = DomainFixtures.tickerSymbol(symbol: 'GOOGL');
        final error = StockAlreadyExistsError(ticker);

        expect(
            error.toString(), equals('StockAlreadyExistsError(ticker: GOOGL)'));
      });

      test('should support equality', () {
        final ticker1 = DomainFixtures.tickerSymbol();
        final ticker2 = DomainFixtures.tickerSymbol();
        final ticker3 = DomainFixtures.tickerSymbol(symbol: 'GOOGL');

        final error1 = StockAlreadyExistsError(ticker1);
        final error2 = StockAlreadyExistsError(ticker2);
        final error3 = StockAlreadyExistsError(ticker3);

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });
    });

    group('StockStorageError', () {
      test('should be a DomainError', () {
        const error = StockStorageError();

        expect(error, isA<DomainError>());
        expect(error, isA<StockRepositoryError>());
      });

      test('should support optional message', () {
        const errorWithoutMessage = StockStorageError();
        const errorWithMessage =
            StockStorageError('Database connection failed');

        expect(errorWithoutMessage.message, isNull);
        expect(errorWithMessage.message, equals('Database connection failed'));
      });

      test('should have correct props', () {
        const errorWithoutMessage = StockStorageError();
        const errorWithMessage = StockStorageError('Connection timeout');

        expect(errorWithoutMessage.props, equals([null]));
        expect(errorWithMessage.props, equals(['Connection timeout']));
      });

      test('should have meaningful toString', () {
        const errorWithoutMessage = StockStorageError();
        const errorWithMessage = StockStorageError('Query failed');

        expect(errorWithoutMessage.toString(), equals('StockStorageError()'));
        expect(
          errorWithMessage.toString(),
          equals('StockStorageError(message: Query failed)'),
        );
      });

      test('should support equality', () {
        const error1 = StockStorageError();
        const error2 = StockStorageError();
        const error3 = StockStorageError('Different message');
        const error4 = StockStorageError('Different message');

        expect(error1, equals(error2));
        expect(error3, equals(error4));
        expect(error1, isNot(equals(error3)));
      });
    });
  });
}
