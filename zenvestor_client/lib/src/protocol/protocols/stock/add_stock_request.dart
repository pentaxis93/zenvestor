/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class AddStockRequest implements _i1.SerializableModel {
  AddStockRequest._({required this.ticker});

  factory AddStockRequest({required String ticker}) = _AddStockRequestImpl;

  factory AddStockRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return AddStockRequest(ticker: jsonSerialization['ticker'] as String);
  }

  String ticker;

  /// Returns a shallow copy of this [AddStockRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AddStockRequest copyWith({String? ticker});
  @override
  Map<String, dynamic> toJson() {
    return {'ticker': ticker};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AddStockRequestImpl extends AddStockRequest {
  _AddStockRequestImpl({required String ticker}) : super._(ticker: ticker);

  /// Returns a shallow copy of this [AddStockRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AddStockRequest copyWith({String? ticker}) {
    return AddStockRequest(ticker: ticker ?? this.ticker);
  }
}
