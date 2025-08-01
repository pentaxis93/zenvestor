import 'package:equatable/equatable.dart';

/// Response DTO for a successfully added stock.
///
/// This immutable data transfer object represents the output returned
/// after successfully adding a stock to the system. It contains only
/// the core stock properties that are available immediately after creation.
class AddStockResponse extends Equatable {
  /// Creates an add stock response.
  ///
  /// All parameters are required as they represent the minimum data
  /// available for a newly created stock.
  const AddStockResponse({
    required this.id,
    required this.ticker,
    required this.createdAt,
    required this.updatedAt,
  });

  /// The unique identifier assigned to the stock.
  final String id;

  /// The normalized ticker symbol.
  final String ticker;

  /// Timestamp when the stock was created.
  final DateTime createdAt;

  /// Timestamp when the stock was last updated.
  ///
  /// For newly created stocks, this will be the same as [createdAt].
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, ticker, createdAt, updatedAt];

  @override
  String toString() => 'AddStockResponse(id: $id, ticker: $ticker, '
      'createdAt: $createdAt, updatedAt: $updatedAt)';
}
