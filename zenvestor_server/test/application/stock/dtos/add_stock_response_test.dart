import 'package:test/test.dart';
import 'package:zenvestor_server/src/application/stock/dtos/add_stock_response.dart';

void main() {
  group('AddStockResponse', () {
    test('should have correct props', () {
      final now = DateTime.now();
      final response = AddStockResponse(
        id: '123',
        ticker: 'AAPL',
        createdAt: now,
        updatedAt: now,
      );

      expect(response.props, equals(['123', 'AAPL', now, now]));
    });

    test('should support equality', () {
      final now = DateTime.now();
      final response1 = AddStockResponse(
        id: '123',
        ticker: 'AAPL',
        createdAt: now,
        updatedAt: now,
      );
      final response2 = AddStockResponse(
        id: '123',
        ticker: 'AAPL',
        createdAt: now,
        updatedAt: now,
      );
      final response3 = AddStockResponse(
        id: '456',
        ticker: 'GOOGL',
        createdAt: now,
        updatedAt: now,
      );

      expect(response1, equals(response2));
      expect(response1, isNot(equals(response3)));
    });

    test('should have meaningful toString', () {
      final now = DateTime(2024, 1, 15, 10, 30);
      final response = AddStockResponse(
        id: '123',
        ticker: 'AAPL',
        createdAt: now,
        updatedAt: now,
      );

      expect(
        response.toString(),
        'AddStockResponse(id: 123, ticker: AAPL, '
        'createdAt: 2024-01-15 10:30:00.000, '
        'updatedAt: 2024-01-15 10:30:00.000)',
      );
    });

    test('should handle different timestamps', () {
      final createdAt = DateTime(2024, 1, 15);
      final updatedAt = DateTime(2024, 1, 16);
      final response = AddStockResponse(
        id: '123',
        ticker: 'AAPL',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(response.createdAt, equals(createdAt));
      expect(response.updatedAt, equals(updatedAt));
      expect(response.createdAt, isNot(equals(response.updatedAt)));
    });
  });
}
