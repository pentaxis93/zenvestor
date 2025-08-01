import 'package:test/test.dart';
import 'package:zenvestor_server/src/application/stock/dtos/add_stock_request.dart';

void main() {
  group('AddStockRequest', () {
    test('should have correct props', () {
      const request = AddStockRequest(ticker: 'AAPL');
      expect(request.props, equals(['AAPL']));
    });

    test('should support equality', () {
      const request1 = AddStockRequest(ticker: 'AAPL');
      const request2 = AddStockRequest(ticker: 'AAPL');
      const request3 = AddStockRequest(ticker: 'GOOGL');

      expect(request1, equals(request2));
      expect(request1, isNot(equals(request3)));
    });

    test('should have meaningful toString', () {
      const request = AddStockRequest(ticker: 'AAPL');
      expect(request.toString(), 'AddStockRequest(ticker: AAPL)');
    });
  });
}
