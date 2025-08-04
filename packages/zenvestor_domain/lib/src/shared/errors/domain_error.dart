import 'package:equatable/equatable.dart';

/// Base class for all domain layer errors in the Zenvestor application.
///
/// This abstract class hierarchy provides a foundation for different types of
/// domain failures such as validation errors, business rule violations,
/// authorization errors, etc.
///
/// All domain errors should extend this class to ensure consistent error
/// handling throughout the domain layer and to work well with functional
/// error handling patterns using Either types.
abstract class DomainError extends Equatable {
  /// Creates a domain error.
  const DomainError();
}
