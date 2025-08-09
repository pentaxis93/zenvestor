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
import 'infrastructure/stock/stock_model.dart' as _i2;
import 'protocols/stock/add_stock_request.dart' as _i3;
import 'protocols/stock/add_stock_response.dart' as _i4;
import 'protocols/stock/stock_duplicate_exception.dart' as _i5;
import 'protocols/stock/stock_service_exception.dart' as _i6;
import 'protocols/stock/stock_validation_exception.dart' as _i7;
import 'protocols/stock/stock_validation_type.dart' as _i8;
export 'infrastructure/stock/stock_model.dart';
export 'protocols/stock/add_stock_request.dart';
export 'protocols/stock/add_stock_response.dart';
export 'protocols/stock/stock_duplicate_exception.dart';
export 'protocols/stock/stock_service_exception.dart';
export 'protocols/stock/stock_validation_exception.dart';
export 'protocols/stock/stock_validation_type.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i2.Stock) {
      return _i2.Stock.fromJson(data) as T;
    }
    if (t == _i3.AddStockRequest) {
      return _i3.AddStockRequest.fromJson(data) as T;
    }
    if (t == _i4.AddStockResponse) {
      return _i4.AddStockResponse.fromJson(data) as T;
    }
    if (t == _i5.StockDuplicateException) {
      return _i5.StockDuplicateException.fromJson(data) as T;
    }
    if (t == _i6.StockServiceException) {
      return _i6.StockServiceException.fromJson(data) as T;
    }
    if (t == _i7.StockValidationException) {
      return _i7.StockValidationException.fromJson(data) as T;
    }
    if (t == _i8.StockValidationType) {
      return _i8.StockValidationType.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Stock?>()) {
      return (data != null ? _i2.Stock.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.AddStockRequest?>()) {
      return (data != null ? _i3.AddStockRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.AddStockResponse?>()) {
      return (data != null ? _i4.AddStockResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.StockDuplicateException?>()) {
      return (data != null ? _i5.StockDuplicateException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.StockServiceException?>()) {
      return (data != null ? _i6.StockServiceException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.StockValidationException?>()) {
      return (data != null ? _i7.StockValidationException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i8.StockValidationType?>()) {
      return (data != null ? _i8.StockValidationType.fromJson(data) : null)
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.Stock) {
      return 'Stock';
    }
    if (data is _i3.AddStockRequest) {
      return 'AddStockRequest';
    }
    if (data is _i4.AddStockResponse) {
      return 'AddStockResponse';
    }
    if (data is _i5.StockDuplicateException) {
      return 'StockDuplicateException';
    }
    if (data is _i6.StockServiceException) {
      return 'StockServiceException';
    }
    if (data is _i7.StockValidationException) {
      return 'StockValidationException';
    }
    if (data is _i8.StockValidationType) {
      return 'StockValidationType';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Stock') {
      return deserialize<_i2.Stock>(data['data']);
    }
    if (dataClassName == 'AddStockRequest') {
      return deserialize<_i3.AddStockRequest>(data['data']);
    }
    if (dataClassName == 'AddStockResponse') {
      return deserialize<_i4.AddStockResponse>(data['data']);
    }
    if (dataClassName == 'StockDuplicateException') {
      return deserialize<_i5.StockDuplicateException>(data['data']);
    }
    if (dataClassName == 'StockServiceException') {
      return deserialize<_i6.StockServiceException>(data['data']);
    }
    if (dataClassName == 'StockValidationException') {
      return deserialize<_i7.StockValidationException>(data['data']);
    }
    if (dataClassName == 'StockValidationType') {
      return deserialize<_i8.StockValidationType>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
