import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;
import 'package:zenvestor_server/src/infrastructure/persistence/stock/persistence_errors.dart';

/// Persistence model for Stock entities.
///
/// This infrastructure class handles the persistence concerns (IDs, timestamps)
/// while delegating all domain logic to the wrapped Stock entity.
class StockPersistenceModel extends Equatable {
  /// Private constructor to ensure immutability.
  const StockPersistenceModel._({
    required this.id,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique identifier for the stock (UUID).
  final String id;

  /// The wrapped shared domain Stock containing business logic.
  final shared.Stock stock;

  /// Timestamp when the stock was created.
  final DateTime createdAt;

  /// Timestamp when the stock was last updated.
  final DateTime updatedAt;

  /// Delegates to the wrapped domain stock for ticker.
  shared.TickerSymbol get ticker => stock.ticker;

  /// Delegates to the wrapped domain stock for name.
  Option<shared.CompanyName> get name => stock.name;

  /// Delegates to the wrapped domain stock for SIC code.
  Option<shared.SicCode> get sicCode => stock.sicCode;

  /// Delegates to the wrapped domain stock for grade.
  Option<shared.Grade> get grade => stock.grade;

  /// Creates a new StockPersistenceModel instance with validation.
  ///
  /// This factory method handles infrastructure validation (ID, timestamps)
  /// and wraps the domain Stock entity.
  static Either<PersistenceError, StockPersistenceModel> create({
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
      return left(InvalidStockId(id));
    }

    // Validate ID is a valid UUID
    if (!Uuid.isValidUUID(fromString: id)) {
      return left(InvalidStockId(id));
    }

    // Validate timestamps
    if (createdAt.isAfter(updatedAt)) {
      return left(InvalidStockTimestamps(
        createdAt: createdAt,
        updatedAt: updatedAt,
      ));
    }

    // Create the shared domain stock
    final stockResult = shared.Stock.create(
      ticker: ticker,
      name: name,
      sicCode: sicCode,
      grade: grade,
    );

    // Convert shared stock errors to infrastructure errors if needed
    return stockResult.fold(
      // coverage:ignore-start
      (sharedError) {
        // The shared Stock.create currently doesn't return errors,
        // but if it did in the future, we'd map them here
        return left(InvalidStockId(id)); // Placeholder
      },
      // coverage:ignore-end
      (stock) => right(
        StockPersistenceModel._(
          id: id,
          stock: stock,
          createdAt: createdAt,
          updatedAt: updatedAt,
        ),
      ),
    );
  }

  /// Creates a copy of this stock with the given fields replaced.
  StockPersistenceModel copyWith({
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
    final newStock =
        (ticker != null || name != null || sicCode != null || grade != null)
            ? stock.copyWith(
                ticker: ticker,
                name: name,
                sicCode: sicCode,
                grade: grade,
              )
            : stock;

    return StockPersistenceModel._(
      id: id,
      stock: newStock,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id];

  @override
  String toString() =>
      'StockPersistenceModel(id: $id, ticker: ${ticker.value})';
}
