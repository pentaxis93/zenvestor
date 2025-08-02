import 'package:fpdart/fpdart.dart';
import 'package:zenvestor_server/src/domain/shared/errors/domain_error.dart';
import 'package:zenvestor_server/src/domain/stock/stock.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/company_name.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/grade.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/sic_code.dart';
import 'package:zenvestor_server/src/domain/stock/value_objects/ticker_symbol.dart';
import 'package:zenvestor_server/src/generated/infrastructure/stock/stock_model.dart'
    as serverpod_model;

/// Maps between domain Stock entities and Serverpod Stock models.
///
/// This mapper handles the conversion between the domain layer's rich
/// Stock entity with value objects and the infrastructure layer's
/// Serverpod-generated Stock model with primitive types.
class StockMapper {
  /// Converts a Serverpod Stock model to a domain Stock entity.
  ///
  /// The [domainId] parameter is required because the domain uses UUIDs
  /// while Serverpod uses auto-incrementing integers.
  ///
  /// Returns `Either<DomainError, Stock>` to handle validation failures
  /// when creating value objects from primitive values.
  static Either<DomainError, Stock> toDomain(
    serverpod_model.Stock serverpodStock,
    String domainId,
  ) {
    // Create TickerSymbol
    final tickerEither = TickerSymbol.create(serverpodStock.tickerSymbol);
    if (tickerEither.isLeft()) {
      return tickerEither.map((ticker) => throw Exception('Unreachable'));
    }

    // Create optional CompanyName
    Option<CompanyName> companyNameOption = const None();
    if (serverpodStock.companyName != null &&
        serverpodStock.companyName!.isNotEmpty) {
      final companyNameEither = CompanyName.create(serverpodStock.companyName!);
      if (companyNameEither.isLeft()) {
        return companyNameEither.map((name) => throw Exception('Unreachable'));
      }
      companyNameOption = Some(
          companyNameEither.getOrElse((l) => throw Exception('Unreachable')));
    }

    // Create optional Grade
    Option<Grade> gradeOption = const None();
    if (serverpodStock.grade != null) {
      final gradeEither = Grade.create(serverpodStock.grade!);
      if (gradeEither.isLeft()) {
        return gradeEither.map((grade) => throw Exception('Unreachable'));
      }
      gradeOption =
          Some(gradeEither.getOrElse((l) => throw Exception('Unreachable')));
    }

    // Create optional SicCode
    Option<SicCode> sicCodeOption = const None();
    if (serverpodStock.sicCode != null) {
      final sicCodeEither = SicCode.create(serverpodStock.sicCode!);
      if (sicCodeEither.isLeft()) {
        return sicCodeEither.map((sicCode) => throw Exception('Unreachable'));
      }
      sicCodeOption =
          Some(sicCodeEither.getOrElse((l) => throw Exception('Unreachable')));
    }

    // Create Stock entity
    final stockEither = Stock.create(
      id: domainId,
      ticker: tickerEither.getOrElse((l) => throw Exception('Unreachable')),
      name: companyNameOption,
      sicCode: sicCodeOption,
      grade: gradeOption,
      createdAt: serverpodStock.createdAt,
      updatedAt: serverpodStock.updatedAt,
    );

    return stockEither;
  }

  /// Converts a domain Stock entity to a Serverpod Stock model.
  ///
  /// The [serverpodId] parameter allows specifying the database ID,
  /// which can be null for new stocks that haven't been persisted yet.
  ///
  /// This conversion is safe as the domain entity is already validated.
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
