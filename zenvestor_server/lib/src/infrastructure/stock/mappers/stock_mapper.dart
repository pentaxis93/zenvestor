import 'package:fpdart/fpdart.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;
import 'package:zenvestor_server/src/domain/stock/stock.dart';
import 'package:zenvestor_server/src/domain/stock/stock_errors.dart';
import 'package:zenvestor_server/src/generated/infrastructure/stock/stock_model.dart'
    as serverpod_model;

/// Maps between domain Stock and Serverpod Stock models.
///
/// This mapper handles the conversion between the domain layer's
/// Stock entity (which includes business logic and infrastructure concerns)
/// and Serverpod's generated Stock model with primitive types.
class StockMapper {
  /// Converts a Serverpod Stock model to a domain Stock entity.
  ///
  /// The [domainId] parameter is required because the domain uses
  /// UUIDs while Serverpod uses auto-incrementing integers.
  ///
  /// Returns `Either<StockRepositoryError, Stock>` to handle
  /// validation failures when creating value objects from primitive values.
  static Either<StockRepositoryError, Stock> toDomain(
    serverpod_model.Stock serverpodStock,
    String domainId,
  ) {
    // Create TickerSymbol
    final tickerEither =
        shared.TickerSymbol.create(serverpodStock.tickerSymbol);
    if (tickerEither.isLeft()) {
      return left(const StockStorageError('Invalid ticker symbol in database'));
    }

    // Create optional CompanyName
    Option<shared.CompanyName> companyNameOption = const None();
    if (serverpodStock.companyName != null &&
        serverpodStock.companyName!.isNotEmpty) {
      final companyNameEither =
          shared.CompanyName.create(serverpodStock.companyName!);
      if (companyNameEither.isLeft()) {
        return left(
            const StockStorageError('Invalid company name in database'));
      }
      companyNameOption = Some(
          companyNameEither.getOrElse((l) => throw Exception('Unreachable')));
    }

    // Create optional Grade
    Option<shared.Grade> gradeOption = const None();
    if (serverpodStock.grade != null) {
      final gradeEither = shared.Grade.create(serverpodStock.grade!);
      if (gradeEither.isLeft()) {
        return left(const StockStorageError('Invalid grade in database'));
      }
      gradeOption =
          Some(gradeEither.getOrElse((l) => throw Exception('Unreachable')));
    }

    // Create optional SicCode
    Option<shared.SicCode> sicCodeOption = const None();
    if (serverpodStock.sicCode != null) {
      final sicCodeEither = shared.SicCode.create(serverpodStock.sicCode!);
      if (sicCodeEither.isLeft()) {
        return left(const StockStorageError('Invalid SIC code in database'));
      }
      sicCodeOption =
          Some(sicCodeEither.getOrElse((l) => throw Exception('Unreachable')));
    }

    // Create shared domain stock
    final sharedStockEither = shared.Stock.create(
      ticker: tickerEither.getOrElse((l) => throw Exception('Unreachable')),
      name: companyNameOption,
      sicCode: sicCodeOption,
      grade: gradeOption,
    );

    // Since Stock.create currently always returns Right, we can safely extract
    final sharedStock =
        sharedStockEither.getOrElse((l) => throw Exception('Unreachable'));

    // Create server domain stock with infrastructure data
    return right(
      Stock.fromSharedStock(
        id: domainId,
        createdAt: serverpodStock.createdAt,
        updatedAt: serverpodStock.updatedAt,
        sharedStock: sharedStock,
      ),
    );
  }

  /// Converts a domain Stock entity to a Serverpod Stock model.
  ///
  /// The [serverpodId] parameter allows specifying the database ID,
  /// which can be null for new stocks that haven't been persisted yet.
  ///
  /// This conversion is safe as the domain stock is already validated.
  static serverpod_model.Stock toServerpod(
      Stock domainStock, int? serverpodId) {
    return serverpod_model.Stock(
      id: serverpodId,
      tickerSymbol: domainStock.ticker.value,
      companyName: domainStock.name.fold(
        () => null,
        (name) => name.value,
      ),
      sicCode: domainStock.sicCode.fold(
        () => null,
        (sicCode) => sicCode.value,
      ),
      grade: domainStock.grade.fold(
        () => null,
        (grade) => grade.value,
      ),
      createdAt: domainStock.createdAt,
      updatedAt: domainStock.updatedAt,
    );
  }
}
