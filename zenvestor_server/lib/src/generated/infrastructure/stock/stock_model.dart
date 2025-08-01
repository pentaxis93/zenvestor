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

abstract class Stock implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = StockTable();

  static const db = StockRepository._();

  @override
  int? id;

  String tickerSymbol;

  String? companyName;

  String? sicCode;

  String? grade;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static StockInclude include() {
    return StockInclude._();
  }

  static StockIncludeList includeList({
    _i1.WhereExpressionBuilder<StockTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StockTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StockTable>? orderByList,
    StockInclude? include,
  }) {
    return StockIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Stock.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Stock.t),
      include: include,
    );
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

class StockTable extends _i1.Table<int?> {
  StockTable({super.tableRelation}) : super(tableName: 'stocks') {
    tickerSymbol = _i1.ColumnString(
      'tickerSymbol',
      this,
    );
    companyName = _i1.ColumnString(
      'companyName',
      this,
    );
    sicCode = _i1.ColumnString(
      'sicCode',
      this,
    );
    grade = _i1.ColumnString(
      'grade',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final _i1.ColumnString tickerSymbol;

  late final _i1.ColumnString companyName;

  late final _i1.ColumnString sicCode;

  late final _i1.ColumnString grade;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
        id,
        tickerSymbol,
        companyName,
        sicCode,
        grade,
        createdAt,
        updatedAt,
      ];
}

class StockInclude extends _i1.IncludeObject {
  StockInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Stock.t;
}

class StockIncludeList extends _i1.IncludeList {
  StockIncludeList._({
    _i1.WhereExpressionBuilder<StockTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Stock.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Stock.t;
}

class StockRepository {
  const StockRepository._();

  /// Returns a list of [Stock]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Stock>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<StockTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<StockTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StockTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Stock>(
      where: where?.call(Stock.t),
      orderBy: orderBy?.call(Stock.t),
      orderByList: orderByList?.call(Stock.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Stock] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Stock?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<StockTable>? where,
    int? offset,
    _i1.OrderByBuilder<StockTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<StockTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Stock>(
      where: where?.call(Stock.t),
      orderBy: orderBy?.call(Stock.t),
      orderByList: orderByList?.call(Stock.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Stock] by its [id] or null if no such row exists.
  Future<Stock?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Stock>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Stock]s in the list and returns the inserted rows.
  ///
  /// The returned [Stock]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Stock>> insert(
    _i1.Session session,
    List<Stock> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Stock>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Stock] and returns the inserted row.
  ///
  /// The returned [Stock] will have its `id` field set.
  Future<Stock> insertRow(
    _i1.Session session,
    Stock row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Stock>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Stock]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Stock>> update(
    _i1.Session session,
    List<Stock> rows, {
    _i1.ColumnSelections<StockTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Stock>(
      rows,
      columns: columns?.call(Stock.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Stock]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Stock> updateRow(
    _i1.Session session,
    Stock row, {
    _i1.ColumnSelections<StockTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Stock>(
      row,
      columns: columns?.call(Stock.t),
      transaction: transaction,
    );
  }

  /// Deletes all [Stock]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Stock>> delete(
    _i1.Session session,
    List<Stock> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Stock>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Stock].
  Future<Stock> deleteRow(
    _i1.Session session,
    Stock row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Stock>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Stock>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<StockTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Stock>(
      where: where(Stock.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<StockTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Stock>(
      where: where?.call(Stock.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
