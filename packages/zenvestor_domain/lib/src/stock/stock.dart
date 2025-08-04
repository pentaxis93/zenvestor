import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'stock_errors.dart';
import 'value_objects/company_name.dart';
import 'value_objects/grade.dart';
import 'value_objects/sic_code.dart';
import 'value_objects/ticker_symbol.dart';

/// Represents a stock entity in the shared domain layer.
///
/// This is a minimal, pure domain representation of a stock that contains
/// only universal business attributes. It is designed to be used across
/// both backend and frontend contexts.
///
/// The Stock entity is immutable and uses value objects for all its properties
/// to ensure business rules are enforced at the domain level.
///
/// Backend implementations can extend or wrap this entity to add
/// infrastructure-specific concerns like database IDs and timestamps.
class Stock extends Equatable {
  /// Private constructor to ensure immutability and controlled creation.
  const Stock._({
    required this.ticker,
    required this.name,
    required this.sicCode,
    required this.grade,
  });

  /// Stock ticker symbol - the primary business identifier.
  final TickerSymbol ticker;

  /// Company name - optional as some stocks may not have a full name.
  final Option<CompanyName> name;

  /// SIC code for industry classification - optional.
  final Option<SicCode> sicCode;

  /// Stock quality grade - optional.
  final Option<Grade> grade;

  /// Creates a new Stock instance with validation.
  ///
  /// The factory constructor ensures that all business rules are satisfied
  /// before creating a Stock instance. Currently, the only required field
  /// is the ticker symbol, as it serves as the primary business identifier.
  ///
  /// Returns an [Either] with:
  /// - [Left] containing a [StockError] if validation fails
  /// - [Right] containing the created [Stock] if validation succeeds
  static Either<StockError, Stock> create({
    required TickerSymbol ticker,
    Option<CompanyName>? name,
    Option<SicCode>? sicCode,
    Option<Grade>? grade,
  }) {
    // Currently, no additional validation is needed beyond what's already
    // enforced by the value objects themselves. In the future, we might
    // add cross-field validation here if needed.

    return right(
      Stock._(
        ticker: ticker,
        name: name ?? const None(),
        sicCode: sicCode ?? const None(),
        grade: grade ?? const None(),
      ),
    );
  }

  /// Creates a copy of this stock with the given fields replaced.
  ///
  /// This method allows for immutable updates to the stock entity.
  /// Any field that is not provided will retain its current value.
  ///
  /// Returns the same instance if no fields are being updated for
  /// performance optimization.
  Stock copyWith({
    TickerSymbol? ticker,
    Option<CompanyName>? name,
    Option<SicCode>? sicCode,
    Option<Grade>? grade,
  }) {
    // Return same instance if no fields are being updated
    if (ticker == null && name == null && sicCode == null && grade == null) {
      return this;
    }

    return Stock._(
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      sicCode: sicCode ?? this.sicCode,
      grade: grade ?? this.grade,
    );
  }

  /// Equatable props - stocks are equal if all their fields are equal.
  ///
  /// This includes the ticker symbol and all optional fields. Two stocks
  /// are considered equal only if they have exactly the same values for
  /// all properties.
  @override
  List<Object?> get props => [ticker, name, sicCode, grade];

  /// Provides a human-readable string representation of the stock.
  ///
  /// Includes all fields to aid in debugging and logging.
  @override
  String toString() {
    final nameStr = name.fold(() => 'None', (n) => n.value);
    final sicStr = sicCode.fold(() => 'None', (s) => s.value);
    final gradeStr = grade.fold(() => 'None', (g) => g.value);

    return 'Stock(ticker: ${ticker.value}, name: $nameStr, '
        'sicCode: $sicStr, grade: $gradeStr)';
  }
}
