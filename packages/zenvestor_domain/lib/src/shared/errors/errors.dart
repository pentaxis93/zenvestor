/// Barrel export for all shared domain errors and interfaces.
///
/// ## Hybrid Validation Error Pattern
///
/// This library implements a Hybrid Validation Error Pattern that combines:
/// - **Specific error types** for clear, domain-specific error identification
/// - **Shared interfaces** for consistent error handling across the domain
///
/// ### Pattern Overview
///
/// Each value object defines its own error hierarchy with specific error types
/// that implement shared validation interfaces. This approach provides:
///
/// 1. **Type Safety**: Compile-time guarantees about which errors can occur
/// 2. **Clear Semantics**: Error names express business concepts (e.g., `TickerSymbolTooLongError`)
/// 3. **Consistent Handling**: Shared interfaces enable uniform error processing
/// 4. **Better UX**: Specific errors can be mapped to precise user messages
///
/// ### Error Hierarchy Example
///
/// ```dart
/// // Specific error for a value object
/// class TickerSymbolTooLongError extends TickerSymbolError 
///     implements LengthValidationError {
///   @override
///   final int maxLength = 10;
///   
///   @override
///   final int actualLength;
///   
///   const TickerSymbolTooLongError({required this.actualLength});
/// }
/// ```
///
/// ### Shared Validation Interfaces
///
/// The following interfaces define common validation error contracts:
/// - `LengthValidationError`: For string length violations
/// - `FormatValidationError`: For pattern/format violations
/// - `RequiredFieldError`: For missing required values
/// - `InvalidValueError`: For business rule violations
///
/// ### Creating New Error Types
///
/// When adding new value objects or entities:
///
/// 1. Create a base error class extending `DomainError`:
///    ```dart
///    abstract class MyValueObjectError extends DomainError {
///      const MyValueObjectError();
///    }
///    ```
///
/// 2. Define specific errors implementing relevant interfaces:
///    ```dart
///    class MyValueTooShortError extends MyValueObjectError 
///        implements LengthValidationError {
///      @override
///      final int minLength = 3;
///      
///      @override
///      final int actualLength;
///      
///      const MyValueTooShortError({required this.actualLength});
///      
///      @override
///      List<Object?> get props => [minLength, actualLength];
///      
///      @override
///      String toString() => 'Value must be at least $minLength characters '
///          '(was $actualLength)';
///    }
///    ```
///
/// 3. Return errors from factory methods using `Either`:
///    ```dart
///    factory MyValueObject(String value) {
///      final trimmed = value.trim();
///      if (trimmed.length < 3) {
///        return left(MyValueTooShortError(actualLength: trimmed.length));
///      }
///      return right(MyValueObject._(trimmed));
///    }
///    ```
///
/// ### Benefits
///
/// - **Exhaustive handling**: Pattern matching ensures all errors are handled
/// - **No string comparisons**: Error types are checked at compile time
/// - **Consistent API**: All validation errors follow the same patterns
/// - **Testability**: Specific error types are easy to test
/// - **Maintainability**: Adding new validations doesn't break existing code
///
/// ### Usage in Error Handling
///
/// ```dart
/// result.fold(
///   (error) => switch (error) {
///     TickerSymbolTooLongError() => 'Ticker must be 10 characters or less',
///     TickerSymbolEmptyError() => 'Ticker symbol is required',
///     TickerSymbolInvalidFormatError() => 'Use only letters and numbers',
///   },
///   (success) => 'Valid ticker: $success',
/// );
/// ```
library;

export 'domain_error.dart';
export 'validation_errors.dart';
