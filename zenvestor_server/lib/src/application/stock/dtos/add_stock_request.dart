import 'package:equatable/equatable.dart';

/// Request DTO for adding a new stock.
///
/// This immutable data transfer object represents the input required
/// to add a new stock to the system. Currently, only the ticker symbol
/// is required, with other stock properties to be added later through
/// separate update operations.
class AddStockRequest extends Equatable {
  /// Creates an add stock request.
  ///
  /// [ticker] is the raw ticker symbol input from the client.
  const AddStockRequest({
    required this.ticker,
  });

  /// The raw ticker symbol input.
  ///
  /// This value has not been validated or normalized. The use case
  /// is responsible for validation and creating the proper value object.
  final String ticker;

  @override
  List<Object?> get props => [ticker];

  @override
  String toString() => 'AddStockRequest(ticker: $ticker)';
}
