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
import '../../protocols/stock/stock_validation_type.dart' as _i2;

abstract class StockValidationException
    implements _i1.SerializableException, _i1.SerializableModel {
  StockValidationException._({
    required this.message,
    required this.fieldName,
    required this.validationType,
  });

  factory StockValidationException({
    required String message,
    required String fieldName,
    required _i2.StockValidationType validationType,
  }) = _StockValidationExceptionImpl;

  factory StockValidationException.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return StockValidationException(
      message: jsonSerialization['message'] as String,
      fieldName: jsonSerialization['fieldName'] as String,
      validationType: _i2.StockValidationType.fromJson(
          (jsonSerialization['validationType'] as int)),
    );
  }

  String message;

  String fieldName;

  _i2.StockValidationType validationType;

  /// Returns a shallow copy of this [StockValidationException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StockValidationException copyWith({
    String? message,
    String? fieldName,
    _i2.StockValidationType? validationType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'fieldName': fieldName,
      'validationType': validationType.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _StockValidationExceptionImpl extends StockValidationException {
  _StockValidationExceptionImpl({
    required String message,
    required String fieldName,
    required _i2.StockValidationType validationType,
  }) : super._(
          message: message,
          fieldName: fieldName,
          validationType: validationType,
        );

  /// Returns a shallow copy of this [StockValidationException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StockValidationException copyWith({
    String? message,
    String? fieldName,
    _i2.StockValidationType? validationType,
  }) {
    return StockValidationException(
      message: message ?? this.message,
      fieldName: fieldName ?? this.fieldName,
      validationType: validationType ?? this.validationType,
    );
  }
}
