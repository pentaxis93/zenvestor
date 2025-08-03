import 'package:meta/meta.dart';
import 'package:serverpod/serverpod.dart';
import 'package:zenvestor_server/src/application/shared/errors/application_error.dart';
import 'package:zenvestor_server/src/application/stock/dtos/add_stock_request.dart'
    as app_dto;
import 'package:zenvestor_server/src/application/stock/dtos/add_stock_response.dart'
    as app_dto;
import 'package:zenvestor_server/src/application/stock/use_cases/add_stock_use_case.dart';
import 'package:zenvestor_server/src/generated/protocols/stock/add_stock_request.dart';
import 'package:zenvestor_server/src/generated/protocols/stock/add_stock_response.dart';
import 'package:zenvestor_server/src/generated/protocols/stock/stock_duplicate_exception.dart';
import 'package:zenvestor_server/src/generated/protocols/stock/stock_service_exception.dart';
import 'package:zenvestor_server/src/generated/protocols/stock/stock_validation_exception.dart';
import 'package:zenvestor_server/src/generated/protocols/stock/stock_validation_type.dart';
import 'package:zenvestor_server/src/infrastructure/stock/repositories/stock_repository_serverpod.dart';

/// Serverpod endpoint for stock-related operations.
///
/// This endpoint serves as an adapter layer between Serverpod's protocol
/// and the application's use cases, maintaining clean architecture boundaries.
class StockEndpoint extends Endpoint {
  // TODO(pentaxis93): Implement proper dependency injection when Serverpod
  // supports it. For now, creating dependencies inline to work with
  // Serverpod's no-argument constructor requirement.
  /// The use case for adding stocks. Protected visibility for testing.
  @protected
  AddStockUseCase? addStockUseCase;

  /// Adds a new stock to the system.
  ///
  /// This method accepts a [session] and [request] containing the ticker
  /// symbol, delegates to the use case for business logic, and returns the
  /// created stock information or throws an appropriate exception on error.
  ///
  /// Error mapping:
  /// - StockValidationApplicationError → StockValidationException
  /// - StockAlreadyExistsApplicationError → StockDuplicateException
  /// - StockStorageApplicationError → StockServiceException
  Future<AddStockResponse> addStock(
    Session session,
    AddStockRequest request,
  ) async {
    // Lazy initialization of use case with the session
    addStockUseCase ??= AddStockUseCase(
      repository: StockRepositoryServerpod(session),
    );

    // Convert protocol DTO to application DTO
    final appRequest = app_dto.AddStockRequest(ticker: request.ticker);

    // Execute use case
    final result = await addStockUseCase!.execute(appRequest);

    // Handle Either result
    return result.fold(
      _handleError,
      _convertToProtocolResponse,
    );
  }

  /// Handles application errors by throwing appropriate Serverpod exceptions.
  ///
  /// Maps each error type to its corresponding exception type.
  Never _handleError(StockApplicationError error) {
    switch (error) {
      case StockValidationApplicationError():
        throw StockValidationException(
          message: error.message,
          fieldName: 'ticker',
          validationType: _mapValidationType(error.message),
        );
      case StockAlreadyExistsApplicationError():
        throw StockDuplicateException(
          ticker: error.ticker,
          message: 'Stock with ticker ${error.ticker} already exists',
        );
      case StockStorageApplicationError():
        throw StockServiceException(
          message: error.message ?? 'Service temporarily unavailable',
        );
    }
  }

  /// Maps validation error messages to validation types.
  StockValidationType _mapValidationType(String message) {
    if (message.contains('required')) {
      return StockValidationType.emptyField;
    } else if (message.contains('uppercase letters')) {
      return StockValidationType.invalidFormat;
    } else if (message.contains('at most')) {
      return StockValidationType.tooLong;
    }
    // Default to invalid format for unknown validation errors
    return StockValidationType.invalidFormat;
  }

  /// Converts the application response DTO to a protocol response DTO.
  ///
  /// Maps the fields from the application layer response to the
  /// Serverpod protocol response, setting optional fields to null.
  AddStockResponse _convertToProtocolResponse(
    app_dto.AddStockResponse response,
  ) {
    return AddStockResponse(
      id: response.id,
      ticker: response.ticker,
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
    );
  }
}
