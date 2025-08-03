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
import 'package:serverpod/protocol.dart' as _i2;
import 'greeting.dart' as _i3;
import 'infrastructure/stock/stock_model.dart' as _i4;
import 'protocols/stock/add_stock_request.dart' as _i5;
import 'protocols/stock/add_stock_response.dart' as _i6;
import 'protocols/stock/stock_duplicate_exception.dart' as _i7;
import 'protocols/stock/stock_service_exception.dart' as _i8;
import 'protocols/stock/stock_validation_exception.dart' as _i9;
import 'protocols/stock/stock_validation_type.dart' as _i10;
export 'greeting.dart';
export 'infrastructure/stock/stock_model.dart';
export 'protocols/stock/add_stock_request.dart';
export 'protocols/stock/add_stock_response.dart';
export 'protocols/stock/stock_duplicate_exception.dart';
export 'protocols/stock/stock_service_exception.dart';
export 'protocols/stock/stock_validation_exception.dart';
export 'protocols/stock/stock_validation_type.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'stocks',
      dartName: 'Stock',
      schema: 'public',
      module: 'zenvestor',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'stocks_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'tickerSymbol',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'companyName',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'sicCode',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'grade',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'stocks_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'ticker_symbol_index',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'tickerSymbol',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i2.Protocol.targetTableDefinitions,
  ];

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i3.Greeting) {
      return _i3.Greeting.fromJson(data) as T;
    }
    if (t == _i4.Stock) {
      return _i4.Stock.fromJson(data) as T;
    }
    if (t == _i5.AddStockRequest) {
      return _i5.AddStockRequest.fromJson(data) as T;
    }
    if (t == _i6.AddStockResponse) {
      return _i6.AddStockResponse.fromJson(data) as T;
    }
    if (t == _i7.StockDuplicateException) {
      return _i7.StockDuplicateException.fromJson(data) as T;
    }
    if (t == _i8.StockServiceException) {
      return _i8.StockServiceException.fromJson(data) as T;
    }
    if (t == _i9.StockValidationException) {
      return _i9.StockValidationException.fromJson(data) as T;
    }
    if (t == _i10.StockValidationType) {
      return _i10.StockValidationType.fromJson(data) as T;
    }
    if (t == _i1.getType<_i3.Greeting?>()) {
      return (data != null ? _i3.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Stock?>()) {
      return (data != null ? _i4.Stock.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.AddStockRequest?>()) {
      return (data != null ? _i5.AddStockRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.AddStockResponse?>()) {
      return (data != null ? _i6.AddStockResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.StockDuplicateException?>()) {
      return (data != null ? _i7.StockDuplicateException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i8.StockServiceException?>()) {
      return (data != null ? _i8.StockServiceException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i9.StockValidationException?>()) {
      return (data != null ? _i9.StockValidationException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.StockValidationType?>()) {
      return (data != null ? _i10.StockValidationType.fromJson(data) : null)
          as T;
    }
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i3.Greeting) {
      return 'Greeting';
    }
    if (data is _i4.Stock) {
      return 'Stock';
    }
    if (data is _i5.AddStockRequest) {
      return 'AddStockRequest';
    }
    if (data is _i6.AddStockResponse) {
      return 'AddStockResponse';
    }
    if (data is _i7.StockDuplicateException) {
      return 'StockDuplicateException';
    }
    if (data is _i8.StockServiceException) {
      return 'StockServiceException';
    }
    if (data is _i9.StockValidationException) {
      return 'StockValidationException';
    }
    if (data is _i10.StockValidationType) {
      return 'StockValidationType';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i3.Greeting>(data['data']);
    }
    if (dataClassName == 'Stock') {
      return deserialize<_i4.Stock>(data['data']);
    }
    if (dataClassName == 'AddStockRequest') {
      return deserialize<_i5.AddStockRequest>(data['data']);
    }
    if (dataClassName == 'AddStockResponse') {
      return deserialize<_i6.AddStockResponse>(data['data']);
    }
    if (dataClassName == 'StockDuplicateException') {
      return deserialize<_i7.StockDuplicateException>(data['data']);
    }
    if (dataClassName == 'StockServiceException') {
      return deserialize<_i8.StockServiceException>(data['data']);
    }
    if (dataClassName == 'StockValidationException') {
      return deserialize<_i9.StockValidationException>(data['data']);
    }
    if (dataClassName == 'StockValidationType') {
      return deserialize<_i10.StockValidationType>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i4.Stock:
        return _i4.Stock.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'zenvestor';
}
