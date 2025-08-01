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

abstract class Stock implements _i1.SerializableModel {
  Stock._({
    this.id,
    required this.tickerSymbol,
    this.companyName,
    this.sicCode,
    this.grade,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Stock({
    int? id,
    required String tickerSymbol,
    String? companyName,
    String? sicCode,
    String? grade,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StockImpl;

  factory Stock.fromJson(Map<String, dynamic> jsonSerialization) {
    return Stock(
      id: jsonSerialization['id'] as int?,
      tickerSymbol: jsonSerialization['tickerSymbol'] as String,
      companyName: jsonSerialization['companyName'] as String?,
      sicCode: jsonSerialization['sicCode'] as String?,
      grade: jsonSerialization['grade'] as String?,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String tickerSymbol;

  String? companyName;

  String? sicCode;

  String? grade;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Stock]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Stock copyWith({
    int? id,
    String? tickerSymbol,
    String? companyName,
    String? sicCode,
    String? grade,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'tickerSymbol': tickerSymbol,
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

class _StockImpl extends Stock {
  _StockImpl({
    int? id,
    required String tickerSymbol,
    String? companyName,
    String? sicCode,
    String? grade,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
          id: id,
          tickerSymbol: tickerSymbol,
          companyName: companyName,
          sicCode: sicCode,
          grade: grade,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [Stock]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Stock copyWith({
    Object? id = _Undefined,
    String? tickerSymbol,
    Object? companyName = _Undefined,
    Object? sicCode = _Undefined,
    Object? grade = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Stock(
      id: id is int? ? id : this.id,
      tickerSymbol: tickerSymbol ?? this.tickerSymbol,
      companyName: companyName is String? ? companyName : this.companyName,
      sicCode: sicCode is String? ? sicCode : this.sicCode,
      grade: grade is String? ? grade : this.grade,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
