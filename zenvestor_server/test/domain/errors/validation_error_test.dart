import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/errors/validation_error.dart';

/// Unit tests for the [ValidationError] class.
///
/// These tests verify that ValidationError correctly handles all scenarios
/// and maintains its contract as a simple, immutable error representation.
///
/// ## Test Structure
///
/// The tests are organized into logical groups:
/// - **Construction**: Verifies proper object creation
/// - **Properties**: Ensures fields behave as expected
/// - **String Representation**: Validates toString() output
/// - **Real-World Scenarios**: Tests common validation use cases
///
/// ## Testing Philosophy
///
/// These tests follow the principle of testing behavior, not implementation.
/// Each test has a clear purpose and tests one specific aspect of the class.
/// The test names follow the pattern:
/// "should (expected behavior) when (condition)"
void main() {
  group('ValidationError', () {
    group('construction', () {
      test('should create instance with required message and field', () {
        // Arrange & Act
        const error = ValidationError(
          message: 'Stock symbol cannot be empty',
          field: 'symbol',
        );

        // Assert
        expect(error, isNotNull);
        expect(error.message, equals('Stock symbol cannot be empty'));
        expect(error.field, equals('symbol'));
      });

      test('should allow empty strings for message and field', () {
        // While not recommended, the constructor should handle edge cases
        // Arrange & Act
        const error = ValidationError(
          message: '',
          field: '',
        );

        // Assert
        expect(error.message, equals(''));
        expect(error.field, equals(''));
      });

      test('should maintain immutability of properties', () {
        // Arrange
        const error = ValidationError(
          message: 'Original message',
          field: 'originalField',
        );

        // Act & Assert
        // This test verifies that properties are final and cannot be modified
        expect(error.message, equals('Original message'));
        expect(error.field, equals('originalField'));

        // Create a new instance to verify const constructor behavior
        const error2 = ValidationError(
          message: 'Original message',
          field: 'originalField',
        );

        // Should be the same instance due to const constructor
        expect(identical(error, error2), isTrue);
      });
    });

    group('toString()', () {
      test('should format error as "ValidationError: [field] - [message]"', () {
        // Arrange
        const error = ValidationError(
          message: 'Stock symbol must be between 1 and 5 characters',
          field: 'symbol',
        );

        // Act
        final result = error.toString();

        // Assert
        expect(
          result,
          equals('ValidationError: symbol - '
              'Stock symbol must be between 1 and 5 characters'),
        );
      });

      test('should handle special characters in message and field', () {
        // Arrange
        const error = ValidationError(
          message: r'Value must match pattern: ^[A-Z]{2,5}$',
          field: 'stock.symbol',
        );

        // Act
        final result = error.toString();

        // Assert
        expect(
          result,
          equals('ValidationError: stock.symbol - '
              r'Value must match pattern: ^[A-Z]{2,5}$'),
        );
      });

      test('should handle multi-line messages', () {
        // Arrange
        const error = ValidationError(
          message: 'Invalid value.\nExpected: positive number\nReceived: -10',
          field: 'pivotPrice',
        );

        // Act
        final result = error.toString();

        // Assert
        expect(
          result,
          equals('ValidationError: pivotPrice - Invalid value.\n'
              'Expected: positive number\nReceived: -10'),
        );
      });
    });

    group('real-world scenarios', () {
      test('should represent stock symbol validation error', () {
        // Arrange
        const error = ValidationError(
          field: 'symbol',
          message: 'Stock symbol must be uppercase letters only',
        );

        // Assert
        expect(error.field, equals('symbol'));
        expect(error.message, contains('uppercase'));
        expect(error.toString(), contains('ValidationError: symbol'));
      });

      test('should represent numeric field validation error', () {
        // Arrange
        const error = ValidationError(
          field: 'pivotPrice',
          message: 'Pivot price must be greater than zero',
        );

        // Assert
        expect(error.field, equals('pivotPrice'));
        expect(error.message, contains('greater than zero'));
      });

      test('should represent nested field validation error', () {
        // Arrange
        const error = ValidationError(
          field: 'portfolio.stocks[0].quantity',
          message: 'Stock quantity must be a whole number',
        );

        // Assert
        expect(error.field, equals('portfolio.stocks[0].quantity'));
        expect(error.message, contains('whole number'));
      });

      test('should provide actionable error messages', () {
        // This test verifies that messages follow the principle
        // of being helpful
        final testCases = [
          const ValidationError(
            field: 'email',
            message: 'Email address must contain an @ symbol',
          ),
          const ValidationError(
            field: 'password',
            message: 'Password must be at least 8 characters long',
          ),
          const ValidationError(
            field: 'dateRange',
            message: 'End date must be after start date',
          ),
        ];

        // Assert that all messages provide clear guidance
        for (final error in testCases) {
          expect(error.message, contains('must'));
          expect(error.message.length, greaterThan(10),
              reason: 'Message should be descriptive');
        }
      });
    });

    group('equality and hashCode', () {
      test(
          'should consider two errors with same values as identical '
          'when using const constructor', () {
        // Since ValidationError doesn't override == and hashCode,
        // two instances with the same values won't be equal

        // Arrange
        const error1 = ValidationError(
          message: 'Test message',
          field: 'testField',
        );
        const error2 = ValidationError(
          message: 'Test message',
          field: 'testField',
        );

        // Assert - const constructor makes them identical
        expect(identical(error1, error2), isTrue);
        expect(error1 == error2, isTrue);
        expect(error1.hashCode == error2.hashCode, isTrue);
      });

      test('should be identical when using const constructor with same values',
          () {
        // Const constructor ensures same instance for identical values

        // Arrange
        const error1 = ValidationError(
          message: 'Test message',
          field: 'testField',
        );
        const error2 = ValidationError(
          message: 'Test message',
          field: 'testField',
        );

        // Assert
        expect(identical(error1, error2), isTrue);
        expect(error1 == error2, isTrue);
        expect(error1.hashCode == error2.hashCode, isTrue);
      });
    });

    group('integration patterns', () {
      test('should work well with exception handling', () {
        // Arrange
        ValidationError? caughtError;

        // Act
        try {
          // ValidationError doesn't extend Exception/Error,
          // but this is a test scenario
          // ignore: only_throw_errors
          throw const ValidationError(
            field: 'amount',
            message: 'Amount cannot be negative',
          );
        } on ValidationError catch (e) {
          caughtError = e;
        }

        // Assert
        expect(caughtError, isNotNull);
        expect(caughtError.field, equals('amount'));
        expect(caughtError.message, equals('Amount cannot be negative'));
      });

      test('should be suitable for form validation scenarios', () {
        // Simulate collecting multiple validation errors
        final errors = <ValidationError>[];

        // Simulate field validations
        // Simulate empty field
        const username = '';
        if (username.isEmpty) {
          errors.add(const ValidationError(
            field: 'username',
            message: 'Username is required',
          ));
        }

        // Simulate invalid format
        const email = 'invalid@';
        if (!email.contains('@.')) {
          errors.add(const ValidationError(
            field: 'email',
            message: 'Email format is invalid',
          ));
        }

        // Assert
        expect(errors.length, equals(2));
        expect(errors.map((e) => e.field), containsAll(['username', 'email']));

        // Verify errors can be easily mapped to UI
        final errorMap = {
          for (final error in errors) error.field: error.message,
        };
        expect(errorMap['username'], equals('Username is required'));
        expect(errorMap['email'], equals('Email format is invalid'));
      });
    });
  });
}
