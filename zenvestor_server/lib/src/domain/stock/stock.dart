import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:zenvestor_server/src/domain/shared/errors/domain_error.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/company_name.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/grade.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/sic_code.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/ticker_symbol.dart';

/// Represents a stock entity in the domain layer.
class Stock extends Equatable {
  /// Private constructor to ensure immutability.
  const Stock._({
    required this.id,
    required this.ticker,
    required this.name,
    required this.sicCode,
    required this.grade,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier for the stock.
  final String id;

  /// Stock ticker symbol.
  final TickerSymbol ticker;

  /// Company name.
  final Option<CompanyName> name;

  /// SIC code for industry classification.
  final Option<SicCode> sicCode;

  /// Stock quality grade.
  final Option<Grade> grade;

  /// Timestamp when the stock was created.
  final DateTime createdAt;

  /// Timestamp when the stock was last updated.
  final DateTime updatedAt;

  /// Creates a new Stock instance with validation.
  static Either<StockError, Stock> create({
    required String id,
    required TickerSymbol ticker,
    required DateTime createdAt,
    required DateTime updatedAt,
    Option<CompanyName>? name,
    Option<SicCode>? sicCode,
    Option<Grade>? grade,
  }) {
    // Validate ID is not empty
    if (id.isEmpty) {
      return left(StockInvalidId(id));
    }

    // Validate ID is a valid UUID
    if (!Uuid.isValidUUID(fromString: id)) {
      return left(StockInvalidId(id));
    }

    // Validate timestamps
    if (createdAt.isAfter(updatedAt)) {
      return left(StockInvalidTimestamps(
        createdAt: createdAt,
        updatedAt: updatedAt,
      ));
    }

    return right(
      Stock._(
        id: id,
        ticker: ticker,
        name: name ?? const None(),
        sicCode: sicCode ?? const None(),
        grade: grade ?? const None(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
  }

  /// Creates a copy of this stock with the given fields replaced.
  Stock copyWith({
    TickerSymbol? ticker,
    Option<CompanyName>? name,
    Option<SicCode>? sicCode,
    Option<Grade>? grade,
    DateTime? updatedAt,
  }) {
    // Return same instance if no fields are being updated
    if (ticker == null &&
        name == null &&
        sicCode == null &&
        grade == null &&
        updatedAt == null) {
      return this;
    }

    return Stock._(
      id: id,
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      sicCode: sicCode ?? this.sicCode,
      grade: grade ?? this.grade,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() => 'Stock(id: $id, ticker: ${ticker.value})';
}
