/// Zenvestor Domain - Core business logic and domain entities
///
/// This package contains the shared domain layer components for the Zenvestor
/// trading platform. It provides framework-agnostic domain entities, value objects,
/// and business logic that can be used across both backend (Serverpod) and
/// frontend (Flutter) applications.
///
/// ## Stock Aggregate
///
/// The Stock entity represents the core business concept of a tradable stock.
/// It is composed of value objects that enforce business rules:
///
/// - `Stock` - The minimal, pure domain representation of a stock
/// - `TickerSymbol` - A validated stock ticker (1-5 uppercase letters)
/// - `CompanyName` - A validated company name with business-appropriate characters
/// - `SicCode` - A validated 4-digit SIC industry classification code
/// - `Grade` - A validated stock quality grade (A, B, C, D, or F)
///
/// All entities use functional error handling with Either types from fpdart
/// to ensure type-safe error handling without exceptions.
library zenvestor_domain;

// Shared domain concepts
export 'src/shared/errors/errors.dart';

// Stock aggregate
export 'src/stock/stock.dart';
export 'src/stock/stock_errors.dart';
export 'src/stock/value_objects/ticker_symbol.dart';
export 'src/stock/value_objects/company_name.dart';
export 'src/stock/value_objects/sic_code.dart';
export 'src/stock/value_objects/grade.dart';
