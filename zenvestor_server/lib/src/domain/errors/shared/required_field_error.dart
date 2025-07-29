part of '../domain_error.dart';

/// Interface for validation errors related to missing required fields.
///
/// This interface provides a common contract for errors where a required
/// value is missing, empty, or null. It enables generic handling of required
/// field validation failures while maintaining type safety for specific value
/// objects.
///
/// ## Usage
/// Implement this interface on specific error classes to provide required
/// field validation context:
///
/// ```dart
/// class TickerSymbolEmpty extends TickerSymbolError
///     implements RequiredFieldError {
///   const TickerSymbolEmpty([this.providedValue]);
///
///   @override
///   final Object? providedValue;
///
///   @override
///   String get fieldContext => "ticker symbol";
/// }
/// ```
abstract interface class RequiredFieldError implements DomainError {
  /// A descriptive name for the field that is required.
  ///
  /// This should be a human-readable name suitable for error messages,
  /// e.g., "email address" or "company name".
  String get fieldContext;

  /// The value that was provided (if any).
  ///
  /// This might be null, an empty string, or another "empty" value
  /// depending on the field type. Useful for debugging and understanding
  /// what was actually submitted.
  Object? get providedValue;
}
