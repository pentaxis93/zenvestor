import 'package:equatable/equatable.dart';

part 'length_validation_error.dart';
part 'format_validation_error.dart';
part 'required_field_error.dart';
part '../../stock/errors/ticker_symbol_errors.dart';
part '../../stock/errors/company_name_errors.dart';
part '../../stock/errors/sic_code_errors.dart';
part '../../stock/errors/grade_errors.dart';
part '../../stock/errors/stock_errors.dart';
part '../../stock/errors/stock_repository_errors.dart';

/// Base class for all domain layer errors in the Zenvestor application.
///
/// This sealed class hierarchy enables exhaustive pattern matching when
/// handling domain errors and provides a foundation for different types of
/// domain failures such as validation errors, business rule violations,
/// authorization errors, etc.
///
/// All domain errors should extend this class to ensure consistent error
/// handling throughout the domain layer and to work well with functional
/// error handling patterns using Either types.
sealed class DomainError extends Equatable {
  /// Creates a domain error.
  const DomainError();
}
