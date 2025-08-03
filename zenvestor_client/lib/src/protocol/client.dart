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
import 'dart:async' as _i2;
import 'package:zenvestor_client/src/protocol/protocols/stock/add_stock_response.dart'
    as _i3;
import 'package:zenvestor_client/src/protocol/protocols/stock/add_stock_request.dart'
    as _i4;
import 'package:zenvestor_client/src/protocol/greeting.dart' as _i5;
import 'protocol.dart' as _i6;

/// Serverpod endpoint for stock-related operations.
///
/// This endpoint serves as an adapter layer between Serverpod's protocol
/// and the application's use cases, maintaining clean architecture boundaries.
/// {@category Endpoint}
class EndpointStock extends _i1.EndpointRef {
  EndpointStock(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'stock';

  /// Adds a new stock to the system.
  ///
  /// This method accepts a [session] and [request] containing the ticker
  /// symbol, delegates to the use case for business logic, and returns the
  /// created stock information or throws an appropriate StockException on
  /// error.
  ///
  /// Error mapping:
  /// - StockValidationApplicationError → 400 Bad Request
  /// - StockAlreadyExistsApplicationError → 409 Conflict
  /// - StockStorageApplicationError → 503 Service Unavailable
  _i2.Future<_i3.AddStockResponse> addStock(_i4.AddStockRequest request) =>
      caller.callServerEndpoint<_i3.AddStockResponse>(
        'stock',
        'addStock',
        {'request': request},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i5.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i5.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          _i6.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    stock = EndpointStock(this);
    greeting = EndpointGreeting(this);
  }

  late final EndpointStock stock;

  late final EndpointGreeting greeting;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'stock': stock,
        'greeting': greeting,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
