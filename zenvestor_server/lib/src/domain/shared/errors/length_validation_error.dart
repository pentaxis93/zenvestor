part of 'domain_error.dart';

/// Interface for validation errors related to string length constraints.
///
/// This interface provides a common contract for errors where a string value
/// exceeds or fails to meet length requirements. It enables generic handling
/// of length validation failures while maintaining type safety for specific
/// value objects.
///
/// ## Usage
/// Implement this interface on specific error classes to provide length
/// validation context:
///
/// ```dart
/// class TickerSymbolTooLong extends TickerSymbolError
///     implements LengthValidationError {
///   const TickerSymbolTooLong(this.actualLength);
///
///   final int actualLength;
///
///   @override
///   int get maxLength => 5; // Business rule for ticker symbols
///
///   @override
///   int get minLength => 1;
///
///   @override
///   String get fieldContext => "ticker symbol";
/// }
/// ```
abstract interface class LengthValidationError implements DomainError {
  /// The maximum allowed length for the field.
  ///
  /// Returns null if there is no maximum length constraint.
  int? get maxLength;

  /// The minimum required length for the field.
  ///
  /// Returns null if there is no minimum length constraint.
  int? get minLength;

  /// The actual length of the invalid value.
  int get actualLength;

  /// A descriptive name for the field that failed validation.
  ///
  /// This should be a human-readable name suitable for error messages,
  /// e.g., "company name" or "ticker symbol".
  String get fieldContext;
}
