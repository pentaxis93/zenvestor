import 'package:zenvestor_server/src/domain/stock/value_objects/company_name.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/grade.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/sic_code.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/ticker_symbol.dart';

/// Domain-specific test fixtures for creating valid value objects.
class DomainFixtures {
  DomainFixtures._();

  /// Creates a valid TickerSymbol for testing.
  static TickerSymbol tickerSymbol({String symbol = 'AAPL'}) {
    final result = TickerSymbol.create(symbol);
    return result.fold(
      (error) => throw Exception('Failed to create test TickerSymbol: $error'),
      (ticker) => ticker,
    );
  }

  /// Creates a valid CompanyName for testing.
  static CompanyName companyName({String name = 'Apple Inc'}) {
    final result = CompanyName.create(name);
    return result.fold(
      (error) => throw Exception('Failed to create test CompanyName: $error'),
      (companyName) => companyName,
    );
  }

  /// Creates a valid SicCode for testing.
  static SicCode sicCode({String code = '7372'}) {
    final result = SicCode.create(code);
    return result.fold(
      (error) => throw Exception('Failed to create test SicCode: $error'),
      (sicCode) => sicCode,
    );
  }

  /// Creates a valid Grade for testing.
  static Grade grade({String letter = 'B'}) {
    final result = Grade.create(letter);
    return result.fold(
      (error) => throw Exception('Failed to create test Grade: $error'),
      (grade) => grade,
    );
  }
}
