import 'package:test/test.dart';
import 'package:zenvestor_server/src/application/shared/errors/application_error.dart';

void main() {
  group('StockApplicationError subclasses', () {
    group('StockAlreadyExistsApplicationError', () {
      test('should have correct props', () {
        const error = StockAlreadyExistsApplicationError('AAPL');
        expect(error.props, equals(['AAPL']));
      });

      test('should support equality', () {
        const error1 = StockAlreadyExistsApplicationError('AAPL');
        const error2 = StockAlreadyExistsApplicationError('AAPL');
        const error3 = StockAlreadyExistsApplicationError('GOOGL');

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });

      test('should have meaningful toString', () {
        const error = StockAlreadyExistsApplicationError('AAPL');
        expect(
          error.toString(),
          'StockAlreadyExistsApplicationError(ticker: AAPL)',
        );
      });

      test('should be a StockApplicationError', () {
        const error = StockAlreadyExistsApplicationError('AAPL');
        expect(error, isA<StockApplicationError>());
        expect(error, isA<ApplicationError>());
      });
    });

    group('StockValidationApplicationError', () {
      test('should have correct props', () {
        const error = StockValidationApplicationError(
          message: 'Invalid ticker format',
        );
        expect(error.props, equals(['Invalid ticker format']));
      });

      test('should support equality', () {
        const error1 = StockValidationApplicationError(
          message: 'Invalid ticker format',
        );
        const error2 = StockValidationApplicationError(
          message: 'Invalid ticker format',
        );
        const error3 = StockValidationApplicationError(
          message: 'Ticker too long',
        );

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
      });

      test('should have meaningful toString', () {
        const error = StockValidationApplicationError(
          message: 'Invalid ticker format',
        );
        expect(
          error.toString(),
          'StockValidationApplicationError(message: Invalid ticker format)',
        );
      });

      test('should be a StockApplicationError', () {
        const error = StockValidationApplicationError(
          message: 'Invalid ticker format',
        );
        expect(error, isA<StockApplicationError>());
        expect(error, isA<ApplicationError>());
      });
    });

    group('StockStorageApplicationError', () {
      test('should have correct props with message', () {
        const error = StockStorageApplicationError('Database error');
        expect(error.props, equals(['Database error']));
      });

      test('should have correct props without message', () {
        const error = StockStorageApplicationError();
        expect(error.props, equals([null]));
      });

      test('should support equality', () {
        const error1 = StockStorageApplicationError('Database error');
        const error2 = StockStorageApplicationError('Database error');
        const error3 = StockStorageApplicationError('Network error');
        const error4 = StockStorageApplicationError();
        const error5 = StockStorageApplicationError();

        expect(error1, equals(error2));
        expect(error1, isNot(equals(error3)));
        expect(error1, isNot(equals(error4)));
        expect(error4, equals(error5));
      });

      test('should have meaningful toString with message', () {
        const error = StockStorageApplicationError('Database error');
        expect(
          error.toString(),
          'StockStorageApplicationError(message: Database error)',
        );
      });

      test('should have meaningful toString without message', () {
        const error = StockStorageApplicationError();
        expect(error.toString(), 'StockStorageApplicationError()');
      });

      test('should be a StockApplicationError', () {
        const error = StockStorageApplicationError('Database error');
        expect(error, isA<StockApplicationError>());
        expect(error, isA<ApplicationError>());
      });

      test('should handle null message correctly', () {
        const error = StockStorageApplicationError();
        expect(error.message, isNull);
        expect(error.toString(), 'StockStorageApplicationError()');
      });
    });
  });
}
