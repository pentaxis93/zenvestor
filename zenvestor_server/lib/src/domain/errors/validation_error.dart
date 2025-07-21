/// Represents a validation failure for a specific field in the domain layer.
///
/// This error class provides a standardized way to communicate validation
/// failures throughout the application. It focuses on clarity and simplicity,
/// carrying just enough information to be useful without being overwhelming.
///
/// ## Usage
///
/// ValidationError is typically used within domain entities and value objects
/// to indicate that a piece of data doesn't meet business rules:
///
/// ```dart
/// class Stock {
///   Stock.fromJson(Map<String, dynamic> json) {
///     final symbol = json['symbol'] as String?;
///     if (symbol == null || symbol.isEmpty) {
///       throw ValidationError(
///         field: 'symbol',
///         message: 'Stock symbol cannot be empty',
///       );
///     }
///   }
/// }
/// ```
///
/// ## Design Principles
///
/// - **User-Friendly**: Messages should be clear and actionable
/// - **Field-Specific**: Always identifies which field failed validation
/// - **Domain-Focused**: Business rule violations, not technical errors
/// - **Immutable**: All fields are final to ensure error details don't change
class ValidationError {
  /// Creates a new validation error.
  ///
  /// Both [message] and [field] are required to ensure the error
  /// provides enough context for proper handling and display.
  const ValidationError({
    required this.message,
    required this.field,
  });

  /// A user-friendly description of what went wrong.
  ///
  /// This message should:
  /// - Be written in plain language
  /// - Explain the problem clearly
  /// - Suggest how to fix it when possible
  ///
  /// Example messages:
  /// - "Stock symbol must be between 1 and 5 characters"
  /// - "Pivot price must be greater than zero"
  /// - "Portfolio name cannot contain special characters"
  final String message;

  /// The name of the field that failed validation.
  ///
  /// This should match the field name used in the domain model
  /// or API, making it easy to map errors back to form fields
  /// or API documentation.
  ///
  /// Examples: 'symbol', 'pivotPrice', 'portfolioName', 'email'
  final String field;

  /// Returns a string representation suitable for logging and debugging.
  ///
  /// Format: "ValidationError: [field] - [message]"
  ///
  /// This format makes it easy to identify validation errors in logs
  /// and provides all relevant information in a single line.
  @override
  String toString() => 'ValidationError: $field - $message';
}
