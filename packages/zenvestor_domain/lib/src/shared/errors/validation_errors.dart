import 'domain_error.dart';

// This file consolidates all shared validation error interfaces used across
// the domain layer. These interfaces provide common contracts for different
// types of validation failures, enabling consistent error handling patterns.

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
