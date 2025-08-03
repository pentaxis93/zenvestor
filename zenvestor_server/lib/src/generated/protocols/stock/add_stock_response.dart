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

abstract class AddStockResponse
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AddStockResponse._({
    required this.id,
    required this.ticker,
    this.companyName,
    this.sicCode,
    this.grade,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddStockResponse({
    required String id,
    required String ticker,
    String? companyName,
    String? sicCode,
    String? grade,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AddStockResponseImpl;

  factory AddStockResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return AddStockResponse(
      id: jsonSerialization['id'] as String,
      ticker: jsonSerialization['ticker'] as String,
      companyName: jsonSerialization['companyName'] as String?,
      sicCode: jsonSerialization['sicCode'] as String?,
      grade: jsonSerialization['grade'] as String?,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  String id;

  String ticker;

  String? companyName;

  String? sicCode;

  String? grade;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [AddStockResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AddStockResponse copyWith({
    String? id,
    String? ticker,
    String? companyName,
    String? sicCode,
    String? grade,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticker': ticker,
      if (companyName != null) 'companyName': companyName,
      if (sicCode != null) 'sicCode': sicCode,
      if (grade != null) 'grade': grade,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'id': id,
      'ticker': ticker,
      if (companyName != null) 'companyName': companyName,
      if (sicCode != null) 'sicCode': sicCode,
      if (grade != null) 'grade': grade,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AddStockResponseImpl extends AddStockResponse {
  _AddStockResponseImpl({
    required String id,
    required String ticker,
    String? companyName,
    String? sicCode,
    String? grade,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
          id: id,
          ticker: ticker,
          companyName: companyName,
          sicCode: sicCode,
          grade: grade,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [AddStockResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AddStockResponse copyWith({
    String? id,
    String? ticker,
    Object? companyName = _Undefined,
    Object? sicCode = _Undefined,
    Object? grade = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddStockResponse(
      id: id ?? this.id,
      ticker: ticker ?? this.ticker,
      companyName: companyName is String? ? companyName : this.companyName,
      sicCode: sicCode is String? ? sicCode : this.sicCode,
      grade: grade is String? ? grade : this.grade,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
