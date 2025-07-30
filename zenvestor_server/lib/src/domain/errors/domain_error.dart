import 'package:equatable/equatable.dart';

part 'shared/length_validation_error.dart';
part 'shared/format_validation_error.dart';
part 'shared/required_field_error.dart';
part 'ticker_symbol_errors.dart';
part 'company_name_errors.dart';
part 'sic_code_errors.dart';
part 'grade_errors.dart';

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
