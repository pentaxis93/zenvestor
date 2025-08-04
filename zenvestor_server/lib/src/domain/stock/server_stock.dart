import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;
import 'package:zenvestor_server/src/domain/stock/stock_errors.dart';

/// Server-specific wrapper around the shared domain Stock entity.
///
/// This class extends the shared Stock with infrastructure concerns
/// like database IDs and timestamps while preserving all domain logic.
class ServerStock extends Equatable {
  /// Private constructor to ensure immutability.
  const ServerStock._({
    required this.id,
    required this.domainStock,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier for the stock (UUID).
  final String id;

  /// The wrapped shared domain Stock containing business logic.
  final shared.Stock domainStock;

  /// Timestamp when the stock was created.
  final DateTime createdAt;

  /// Timestamp when the stock was last updated.
  final DateTime updatedAt;

  /// Delegates to the wrapped domain stock for ticker.
  shared.TickerSymbol get ticker => domainStock.ticker;

  /// Delegates to the wrapped domain stock for name.
  Option<shared.CompanyName> get name => domainStock.name;

  /// Delegates to the wrapped domain stock for SIC code.
  Option<shared.SicCode> get sicCode => domainStock.sicCode;

  /// Delegates to the wrapped domain stock for grade.
  Option<shared.Grade> get grade => domainStock.grade;

  /// Creates a new ServerStock instance with validation.
  ///
  /// This factory method maintains backward compatibility with the original
  /// Stock.create API while using the shared domain Stock internally.
  static Either<StockError, ServerStock> create({
    required String id,
    required shared.TickerSymbol ticker,
    required DateTime createdAt,
    required DateTime updatedAt,
    Option<shared.CompanyName>? name,
    Option<shared.SicCode>? sicCode,
    Option<shared.Grade>? grade,
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

    // Create the shared domain stock
    final domainStockResult = shared.Stock.create(
      ticker: ticker,
      name: name,
      sicCode: sicCode,
      grade: grade,
    );

    // Convert shared stock errors to server stock errors if needed
    return domainStockResult.fold(
      // coverage:ignore-start
      (sharedError) {
        // The shared Stock.create currently doesn't return errors,
        // but if it did in the future, we'd map them here
        return left(StockInvalidId(id)); // Placeholder
      },
      // coverage:ignore-end
      (domainStock) => right(
        ServerStock._(
          id: id,
          domainStock: domainStock,
          createdAt: createdAt,
          updatedAt: updatedAt,
        ),
      ),
    );
  }

  /// Creates a copy of this stock with the given fields replaced.
  ServerStock copyWith({
    shared.TickerSymbol? ticker,
    Option<shared.CompanyName>? name,
    Option<shared.SicCode>? sicCode,
    Option<shared.Grade>? grade,
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

    // Create new domain stock if any domain fields changed
    final newDomainStock =
        (ticker != null || name != null || sicCode != null || grade != null)
            ? domainStock.copyWith(
                ticker: ticker,
                name: name,
                sicCode: sicCode,
                grade: grade,
              )
            : domainStock;

    return ServerStock._(
      id: id,
      domainStock: newDomainStock,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() => 'Stock(id: $id, ticker: ${ticker.value})';
}

/// Type alias for backward compatibility.
/// This allows existing code to use 'Stock' while we transition.
typedef Stock = ServerStock;
