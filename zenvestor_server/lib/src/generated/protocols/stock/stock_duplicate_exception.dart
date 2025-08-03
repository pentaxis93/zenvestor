/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class StockDuplicateException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  StockDuplicateException._({
    required this.ticker,
    required this.message,
  });

  factory StockDuplicateException({
    required String ticker,
    required String message,
  }) = _StockDuplicateExceptionImpl;

  factory StockDuplicateException.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return StockDuplicateException(
      ticker: jsonSerialization['ticker'] as String,
      message: jsonSerialization['message'] as String,
    );
  }

  String ticker;

  String message;

  /// Returns a shallow copy of this [StockDuplicateException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StockDuplicateException copyWith({
    String? ticker,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'ticker': ticker,
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'ticker': ticker,
      'message': message,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _StockDuplicateExceptionImpl extends StockDuplicateException {
  _StockDuplicateExceptionImpl({
    required String ticker,
    required String message,
  }) : super._(
          ticker: ticker,
          message: message,
        );

  /// Returns a shallow copy of this [StockDuplicateException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StockDuplicateException copyWith({
    String? ticker,
    String? message,
  }) {
    return StockDuplicateException(
      ticker: ticker ?? this.ticker,
      message: message ?? this.message,
    );
  }
}
