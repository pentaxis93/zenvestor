import 'package:equatable/equatable.dart';

part '../../stock/errors/stock_application_errors.dart';

/// Base class for all application layer errors.
///
/// Application errors represent failures that occur during use case
/// orchestration, such as validation failures, business rule violations,
/// or infrastructure issues. These errors are distinct from domain errors
/// and form their own hierarchy in the application layer.
///
/// All application-specific errors should extend this sealed class to ensure
/// exhaustive pattern matching and type safety.
sealed class ApplicationError extends Equatable {
  /// Creates an application error.
  const ApplicationError();
}
