import 'package:fpdart/fpdart.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;
import 'package:zenvestor_server/src/generated/infrastructure/stock/stock_model.dart'
    as serverpod_model;
import 'package:zenvestor_server/src/infrastructure/persistence/stock/persistence_errors.dart';
import 'package:zenvestor_server/src/infrastructure/persistence/stock/stock_persistence_model.dart';

/// Maps between StockPersistenceModel and Serverpod Stock models.
///
/// This mapper handles the conversion between the infrastructure layer's
/// StockPersistenceModel (which wraps the domain Stock) and Serverpod's
/// generated Stock model with primitive types.
class StockMapper {
  /// Converts a Serverpod Stock model to a StockPersistenceModel.
  ///
  /// The [domainId] parameter is required because the persistence model uses
  /// UUIDs while Serverpod uses auto-incrementing integers.
  ///
  /// Returns `Either<PersistenceError, StockPersistenceModel>` to handle
  /// validation failures when creating value objects from primitive values.
  static Either<PersistenceError, StockPersistenceModel> toPersistenceModel(
    serverpod_model.Stock serverpodStock,
    String domainId,
  ) {
    // Create TickerSymbol
    final tickerEither =
        shared.TickerSymbol.create(serverpodStock.tickerSymbol);
    if (tickerEither.isLeft()) {
      return left(
          const DatabaseStorageError('Invalid ticker symbol in database'));
    }

    // Create optional CompanyName
    Option<shared.CompanyName> companyNameOption = const None();
    if (serverpodStock.companyName != null &&
        serverpodStock.companyName!.isNotEmpty) {
      final companyNameEither =
          shared.CompanyName.create(serverpodStock.companyName!);
      if (companyNameEither.isLeft()) {
        return left(
            const DatabaseStorageError('Invalid company name in database'));
      }
      companyNameOption = Some(
          companyNameEither.getOrElse((l) => throw Exception('Unreachable')));
    }

    // Create optional Grade
    Option<shared.Grade> gradeOption = const None();
    if (serverpodStock.grade != null) {
      final gradeEither = shared.Grade.create(serverpodStock.grade!);
      if (gradeEither.isLeft()) {
        return left(const DatabaseStorageError('Invalid grade in database'));
      }
      gradeOption =
          Some(gradeEither.getOrElse((l) => throw Exception('Unreachable')));
    }

    // Create optional SicCode
    Option<shared.SicCode> sicCodeOption = const None();
    if (serverpodStock.sicCode != null) {
      final sicCodeEither = shared.SicCode.create(serverpodStock.sicCode!);
      if (sicCodeEither.isLeft()) {
        return left(const DatabaseStorageError('Invalid SIC code in database'));
      }
      sicCodeOption =
          Some(sicCodeEither.getOrElse((l) => throw Exception('Unreachable')));
    }

    // Create StockPersistenceModel
    final persistenceModelEither = StockPersistenceModel.create(
      id: domainId,
      ticker: tickerEither.getOrElse((l) => throw Exception('Unreachable')),
      name: companyNameOption,
      sicCode: sicCodeOption,
      grade: gradeOption,
      createdAt: serverpodStock.createdAt,
      updatedAt: serverpodStock.updatedAt,
    );

    return persistenceModelEither;
  }

  /// Converts a StockPersistenceModel to a Serverpod Stock model.
  ///
  /// The [serverpodId] parameter allows specifying the database ID,
  /// which can be null for new stocks that haven't been persisted yet.
  ///
  /// This conversion is safe as the persistence model is already validated.
  static serverpod_model.Stock toServerpod(
      StockPersistenceModel persistenceModel, int? serverpodId) {
    return serverpod_model.Stock(
      id: serverpodId,
      tickerSymbol: persistenceModel.ticker.value,
      companyName: persistenceModel.name.fold(
        () => null,
        (name) => name.value,
      ),
      sicCode: persistenceModel.sicCode.fold(
        () => null,
        (sicCode) => sicCode.value,
      ),
      grade: persistenceModel.grade.fold(
        () => null,
        (grade) => grade.value,
      ),
      createdAt: persistenceModel.createdAt,
      updatedAt: persistenceModel.updatedAt,
    );
  }
}
