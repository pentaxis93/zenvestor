part of '../domain_error.dart';

/// Interface for validation errors related to format or pattern violations.
///
/// This interface provides a common contract for errors where a value doesn't
/// match an expected format or pattern (typically regex-based). It enables
/// generic handling of format validation failures while maintaining type safety
/// for specific value objects.
///
/// ## Usage
/// Implement this interface on specific error classes to provide format
/// validation context:
///
/// ```dart
/// class TickerSymbolInvalidFormat extends TickerSymbolError
///     implements FormatValidationError {
///   const TickerSymbolInvalidFormat(this.invalidValue);
///
///   final String invalidValue;
///
///   @override
///   String get expectedFormat => "1-5 uppercase letters (A-Z only)";
///
///   @override
///   String get actualValue => invalidValue;
///
///   @override
///   String get fieldContext => "ticker symbol";
/// }
/// ```
abstract interface class FormatValidationError implements DomainError {
  /// A human-readable description of the expected format.
  ///
  /// Examples:
  /// - "valid email address"
  /// - "1-5 uppercase letters"
  /// - "phone number in format XXX-XXX-XXXX"
  String get expectedFormat;

  /// The actual value that failed format validation.
  ///
  /// This is typically a string representation of the invalid input.
  String get actualValue;

  /// A descriptive name for the field that failed validation.
  ///
  /// This should be a human-readable name suitable for error messages,
  /// e.g., "email address" or "ticker symbol".
  String get fieldContext;
}
