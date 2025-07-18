# Add Stock Feature Implementation Plan

## Overview

This document provides a comprehensive step-by-step guide for implementing the "add stock" feature in Zenvestor. It demonstrates the complete flow from domain definition to UI implementation, following our Serverpod-optimized clean architecture.

## Table of Contents

1. [Feature Definition](#feature-definition)
2. [Implementation Steps](#implementation-steps)
3. [Code Implementation](#code-implementation)
4. [Testing Strategy](#testing-strategy)
5. [Common Pitfalls](#common-pitfalls)

## Feature Definition

### What is a Stock?

In the Zenvestor domain, a **stock** represents an equity security that users can track in their investment portfolios. Each stock has:

- **Identity**: Unique ticker symbol (e.g., AAPL, GOOGL)
- **Metadata**: Company name, sector, industry group
- **Assessment**: Investment grade (A to F)
- **Documentation**: User notes for investment rationale
- **Audit Trail**: Creation and update timestamps

### Business Requirements

1. **Unique Symbol**: Each stock must have a unique ticker symbol (1-5 uppercase letters)
2. **Sector Validation**: Only predefined sectors are allowed
3. **Industry Consistency**: Industry groups must belong to their parent sector
4. **Grade System**: Standard letter grades with investment-grade threshold
5. **Optional Fields**: Company name, sector, industry, and grade can be added later
6. **Required Fields**: Only symbol is always required

### User Workflow

1. User navigates to stock list page
2. User clicks "Add Stock" button
3. User enters stock symbol (required)
4. User optionally enters company name, sector, industry, grade, and notes
5. System validates input and creates stock
6. User is redirected to stock detail page

## Implementation Steps

### Phase 1: Domain Layer Foundation (Server-Side)

#### Step 1: Define Stock Structure (YAML)

**Purpose**: Define the persistent structure of our stock entity using Serverpod's schema language.

**File**: `zenvestor_server/lib/src/domain/stock/stock.yaml`

```yaml
class: Stock
table: stocks
fields:
  symbol: String
  companyName: String?
  sector: String?
  industryGroup: String?
  grade: String?
  notes: String?
  createdAt: DateTime
  updatedAt: DateTime
indexes:
  symbol_index:
    fields: symbol
    unique: true
```

**Key Decisions**:
- `symbol` is required and unique (enforced by index)
- Most fields are nullable to support gradual data entry
- `notes` is optional (nullable)
- Timestamps for audit trail

#### Step 2: Generate Serverpod Code

**Purpose**: Generate DTOs, database operations, and client protocol.

**Command**:
```bash
cd zenvestor_server
serverpod generate
```

**Generated Files**:
- `zenvestor_server/lib/src/generated/protocol/stock.dart` - Server DTO
- `zenvestor_client/lib/src/protocol/stock.dart` - Client protocol
- Database migration files

#### Step 3: Create Domain Entity

**Purpose**: Implement rich domain model with business behavior.

**File**: `zenvestor_server/lib/src/domain/stock/stock.dart`

```dart
import 'package:equatable/equatable.dart';
import 'value_objects/stock_symbol.dart';
import 'value_objects/company_name.dart';
import 'value_objects/sector.dart';
import 'value_objects/industry_group.dart';
import 'value_objects/grade.dart';
import 'value_objects/notes.dart';

/// Rich domain entity representing a stock/security.
/// 
/// This entity mirrors the structure defined in stock.yaml but adds
/// business behavior, validation through value objects, and domain logic.
class Stock extends Equatable {
  final String id;
  final StockSymbol symbol;
  final CompanyName? companyName;
  final Sector? sector;
  final IndustryGroup? industryGroup;
  final Grade? grade;
  final Notes? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Stock({
    required this.id,
    required this.symbol,
    this.companyName,
    this.sector,
    this.industryGroup,
    this.grade,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor with business rule validation
  factory Stock.create({
    required String symbol,
    String? companyName,
    String? sector,
    String? industryGroup,
    String? grade,
    String? notes,
  }) {
    // Validate sector-industry relationship
    if (industryGroup != null && sector == null) {
      throw ArgumentError('Sector must be provided when industry group is specified');
    }

    final stockSymbol = StockSymbol(symbol);
    final stockSector = sector != null ? Sector(sector) : null;
    final stockIndustryGroup = industryGroup != null 
      ? IndustryGroup(industryGroup, sector: sector)
      : null;

    final now = DateTime.now();
    return Stock(
      id: '', // Will be assigned by database
      symbol: stockSymbol,
      companyName: companyName != null ? CompanyName(companyName) : null,
      sector: stockSector,
      industryGroup: stockIndustryGroup,
      grade: grade != null ? Grade(grade) : null,
      notes: notes != null ? Notes(notes) : null,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Business logic: Check if stock has investment-grade rating
  bool get isInvestmentGrade => grade?.isInvestmentGrade ?? false;

  /// Business logic: Display name with fallback to symbol
  String get displayName {
    if (companyName != null) {
      return '${symbol.value} - ${companyName!.value}';
    }
    return symbol.value;
  }

  /// Business logic: Check if stock has notes
  bool get hasNotes => notes?.hasContent ?? false;

  @override
  List<Object?> get props => [
    id, symbol, companyName, sector, industryGroup, 
    grade, notes, createdAt, updatedAt
  ];
}
```

#### Step 4: Implement Value Objects

**Purpose**: Encapsulate validation rules and domain constraints.

**File**: `zenvestor_server/lib/src/domain/stock/value_objects/stock_symbol.dart`

```dart
import '../../exceptions/exceptions.dart';

/// Value object representing a valid stock ticker symbol
class StockSymbol {
  final String value;

  factory StockSymbol(String input) {
    final trimmed = input.trim().toUpperCase();

    if (trimmed.isEmpty) {
      throw InvalidStockSymbolException('Stock symbol cannot be empty');
    }

    if (trimmed.length > 5) {
      throw InvalidStockSymbolException('Stock symbol cannot exceed 5 characters');
    }

    if (!RegExp(r'^[A-Z]+$').hasMatch(trimmed)) {
      throw InvalidStockSymbolException('Stock symbol must contain only letters');
    }

    return StockSymbol._(trimmed);
  }

  const StockSymbol._(this.value);

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is StockSymbol && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
```

**File**: `zenvestor_server/lib/src/domain/stock/value_objects/sector.dart`

```dart
import '../../exceptions/exceptions.dart';

/// Value object representing valid market sectors
class Sector {
  static const validSectors = {
    'Technology',
    'Healthcare',
    'Financial Services',
    'Consumer Discretionary',
    'Communication Services',
    'Industrials',
    'Consumer Staples',
    'Energy',
    'Utilities',
    'Real Estate',
    'Materials',
  };

  final String value;

  factory Sector(String input) {
    final trimmed = input.trim();

    if (!validSectors.contains(trimmed)) {
      throw InvalidSectorException(
        'Invalid sector: $trimmed. Must be one of: ${validSectors.join(', ')}'
      );
    }

    return Sector._(trimmed);
  }

  const Sector._(this.value);

  static Set<String> get allSectors => Set.unmodifiable(validSectors);
}
```

**File**: `zenvestor_server/lib/src/domain/stock/value_objects/grade.dart`

```dart
import '../../exceptions/exceptions.dart';

/// Value object representing investment grade
class Grade {
  static const validGrades = {
    'A': 4.0,
    'B': 3.0,
    'C': 2.0,
    'D': 1.0,
    'F': 0.0,
  };

  final String value;

  factory Grade(String input) {
    final trimmed = input.trim().toUpperCase();

    if (!validGrades.containsKey(trimmed)) {
      throw InvalidGradeException(
        'Invalid grade: $trimmed. Must be one of: ${validGrades.keys.join(', ')}'
      );
    }

    return Grade._(trimmed);
  }

  const Grade._(this.value);

  double get numericValue => validGrades[value]!;
  
  bool get isInvestmentGrade => numericValue >= 3.0; // B or higher

  static Set<String> get allGrades => Set.unmodifiable(validGrades.keys);
}
```

#### Step 5: Define Repository Interface

**Purpose**: Abstract persistence operations without implementation details.

**File**: `zenvestor_server/lib/src/domain/stock/repository.dart`

```dart
import 'package:dartz/dartz.dart';
import 'stock.dart';
import '../exceptions/exceptions.dart';

/// Repository interface for stock persistence operations
abstract class StockRepository {
  /// Create a new stock
  Future<Either<DomainException, Stock>> create(Stock stock);
  
  /// Get stock by database ID
  Future<Either<DomainException, Stock>> getById(String id);
  
  /// Get stock by ticker symbol
  Future<Either<DomainException, Stock>> getBySymbol(String symbol);
  
  /// Check if symbol already exists
  Future<Either<DomainException, bool>> symbolExists(String symbol);
}
```

### Phase 2: Infrastructure Layer (Server-Side)

#### Step 6: Create Mapper

**Purpose**: Convert between domain entities and Serverpod DTOs.

**File**: `zenvestor_server/lib/src/infrastructure/mappers/stock_mapper.dart`

```dart
import '../../domain/stock/stock.dart';
import '../../domain/stock/value_objects/stock_symbol.dart';
import '../../domain/stock/value_objects/company_name.dart';
import '../../domain/stock/value_objects/sector.dart';
import '../../domain/stock/value_objects/industry_group.dart';
import '../../domain/stock/value_objects/grade.dart';
import '../../domain/stock/value_objects/notes.dart';
import '../../generated/protocol.dart' as generated;

/// Maps between domain Stock entity and generated Stock DTO
class StockMapper {
  /// Convert generated DTO to domain entity
  static Stock toDomain(generated.Stock dto) {
    return Stock(
      id: dto.id.toString(),
      symbol: StockSymbol(dto.symbol),
      companyName: dto.companyName != null 
        ? CompanyName(dto.companyName!) 
        : null,
      sector: dto.sector != null 
        ? Sector(dto.sector!) 
        : null,
      industryGroup: dto.industryGroup != null
        ? IndustryGroup(dto.industryGroup!, sector: dto.sector)
        : null,
      grade: dto.grade != null 
        ? Grade(dto.grade!) 
        : null,
      notes: dto.notes != null ? Notes(dto.notes!) : null,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Convert domain entity to generated DTO for persistence
  static generated.Stock toDto(Stock entity) {
    return generated.Stock(
      id: entity.id.isEmpty ? null : int.parse(entity.id),
      symbol: entity.symbol.value,
      companyName: entity.companyName?.value,
      sector: entity.sector?.value,
      industryGroup: entity.industryGroup?.value,
      grade: entity.grade?.value,
      notes: entity.notes?.value,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
```

#### Step 7: Implement Repository

**Purpose**: Implement domain repository using Serverpod's database operations.

**File**: `zenvestor_server/lib/src/infrastructure/repositories/stock_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:serverpod/serverpod.dart';
import '../../domain/stock/stock.dart';
import '../../domain/stock/repository.dart';
import '../../domain/exceptions/exceptions.dart';
import '../../generated/protocol.dart' as generated;
import '../mappers/stock_mapper.dart';

/// Serverpod implementation of StockRepository
class StockRepositoryImpl implements StockRepository {
  final Session _session;

  StockRepositoryImpl(this._session);

  @override
  Future<Either<DomainException, Stock>> create(Stock stock) async {
    try {
      // Convert to DTO
      final dto = StockMapper.toDto(stock);
      
      // Use Serverpod's generated insert method
      final savedDto = await generated.Stock.insert(_session, dto);
      
      // Convert back to domain entity
      final savedStock = StockMapper.toDomain(savedDto);
      
      return Right(savedStock);
    } catch (e) {
      return Left(InfrastructureException(
        'Failed to create stock: ${e.toString()}'
      ));
    }
  }

  @override
  Future<Either<DomainException, Stock>> getBySymbol(String symbol) async {
    try {
      final stocks = await generated.Stock.find(
        _session,
        where: (t) => t.symbol.equals(symbol),
        limit: 1,
      );

      if (stocks.isEmpty) {
        return Left(StockNotFoundException('Stock with symbol $symbol not found'));
      }

      return Right(StockMapper.toDomain(stocks.first));
    } catch (e) {
      return Left(InfrastructureException(
        'Failed to fetch stock by symbol: ${e.toString()}'
      ));
    }
  }

  @override
  Future<Either<DomainException, bool>> symbolExists(String symbol) async {
    try {
      final count = await generated.Stock.count(
        _session,
        where: (t) => t.symbol.equals(symbol),
      );
      
      return Right(count > 0);
    } catch (e) {
      return Left(InfrastructureException(
        'Failed to check symbol existence: ${e.toString()}'
      ));
    }
  }

  @override
  Future<Either<DomainException, Stock>> getById(String id) async {
    try {
      final stockId = int.parse(id);
      final dto = await generated.Stock.findById(_session, stockId);
      
      if (dto == null) {
        return Left(StockNotFoundException('Stock with id $id not found'));
      }

      return Right(StockMapper.toDomain(dto));
    } catch (e) {
      return Left(InfrastructureException(
        'Failed to fetch stock by id: ${e.toString()}'
      ));
    }
  }
}
```

### Phase 3: Application Layer (Server-Side)

#### Step 8: Create Add Stock Use Case

**Purpose**: Implement business logic for adding a new stock.

**File**: `zenvestor_server/lib/src/application/use_cases/stock/add_stock.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../domain/stock/stock.dart';
import '../../../domain/stock/repository.dart';
import '../../../domain/exceptions/exceptions.dart';

/// Use case for adding a new stock to the system
class AddStock {
  final StockRepository _repository;

  AddStock(this._repository);

  Future<Either<DomainException, Stock>> execute({
    required String symbol,
    String? companyName,
    String? sector,
    String? industryGroup,
    String? grade,
    String? notes,
  }) async {
    try {
      // Check for duplicate symbol
      final existsResult = await _repository.symbolExists(symbol);
      
      return existsResult.fold(
        (failure) => Left(failure),
        (exists) async {
          if (exists) {
            return Left(DuplicateStockException(
              'Stock with symbol $symbol already exists'
            ));
          }

          // Create stock entity (validation happens in factory)
          final stock = Stock.create(
            symbol: symbol,
            companyName: companyName,
            sector: sector,
            industryGroup: industryGroup,
            grade: grade,
            notes: notes,
          );

          // Persist to repository
          return await _repository.create(stock);
        },
      );
    } on DomainException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedDomainException(
        'Failed to add stock: ${e.toString()}'
      ));
    }
  }
}
```

### Phase 4: API Layer (Server-Side)

#### Step 9: Create Stock Endpoint

**Purpose**: Expose add stock functionality via API.

**File**: `zenvestor_server/lib/src/endpoints/stock_endpoint.dart`

```dart
import 'package:serverpod/serverpod.dart';
import '../application/use_cases/stock/add_stock.dart';
import '../infrastructure/repositories/stock_repository_impl.dart';
import '../generated/protocol.dart' as generated;

/// API endpoint for stock operations
class StockEndpoint extends Endpoint {
  /// Add a new stock to the system
  Future<Map<String, dynamic>> addStock(
    Session session,
    String symbol, {
    String? companyName,
    String? sector,
    String? industryGroup,
    String? grade,
    String? notes,
  }) async {
    try {
      // Wire up dependencies
      final repository = StockRepositoryImpl(session);
      final useCase = AddStock(repository);

      // Execute use case
      final result = await useCase.execute(
        symbol: symbol,
        companyName: companyName,
        sector: sector,
        industryGroup: industryGroup,
        grade: grade,
        notes: notes,
      );

      // Transform result to API response
      return result.fold(
        (failure) => {
          'success': false,
          'error': failure.message,
          'errorCode': failure.code,
        },
        (stock) => {
          'success': true,
          'data': {
            'id': stock.id,
            'symbol': stock.symbol.value,
            'companyName': stock.companyName?.value,
            'sector': stock.sector?.value,
            'industryGroup': stock.industryGroup?.value,
            'grade': stock.grade?.value,
            'notes': stock.notes?.value,
            'isInvestmentGrade': stock.isInvestmentGrade,
            'hasNotes': stock.hasNotes,
            'displayName': stock.displayName,
            'createdAt': stock.createdAt.toIso8601String(),
          },
        },
      );
    } catch (e) {
      // Log error for debugging
      session.log('Error in addStock endpoint', level: LogLevel.error);
      
      return {
        'success': false,
        'error': 'An unexpected error occurred',
        'errorCode': 'INTERNAL_ERROR',
      };
    }
  }

  /// Get available sectors for UI dropdowns
  Future<List<String>> getAvailableSectors(Session session) async {
    return Sector.allSectors.toList()..sort();
  }

  /// Get available grades for UI dropdowns
  Future<List<String>> getAvailableGrades(Session session) async {
    return Grade.allGrades.toList()..sort();
  }
}
```

### Phase 5: Client Infrastructure Layer (Flutter)

#### Step 10: Implement API Client

**Purpose**: Wrap Serverpod client for type-safe API calls.

**File**: `zenvestor_flutter/lib/src/infrastructure/api/stock_api_client.dart`

```dart
import 'package:zenvestor_client/zenvestor_client.dart';

/// Client-side API wrapper for stock operations
class StockApiClient {
  final Client _client;

  StockApiClient(this._client);

  /// Add a new stock
  Future<StockApiResponse> addStock({
    required String symbol,
    String? companyName,
    String? sector,
    String? industryGroup,
    String? grade,
    String? notes,
  }) async {
    try {
      final response = await _client.stock.addStock(
        symbol,
        companyName: companyName,
        sector: sector,
        industryGroup: industryGroup,
        grade: grade,
        notes: notes,
      );

      if (response['success'] == true) {
        return StockApiResponse.success(
          data: StockData.fromJson(response['data']),
        );
      } else {
        return StockApiResponse.failure(
          error: response['error'] ?? 'Unknown error',
          errorCode: response['errorCode'] ?? 'UNKNOWN',
        );
      }
    } catch (e) {
      return StockApiResponse.failure(
        error: 'Network error: ${e.toString()}',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  /// Get available sectors
  Future<List<String>> getAvailableSectors() async {
    try {
      return await _client.stock.getAvailableSectors();
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  /// Get available grades
  Future<List<String>> getAvailableGrades() async {
    try {
      return await _client.stock.getAvailableGrades();
    } catch (e) {
      return [];
    }
  }
}

/// Response wrapper for API calls
class StockApiResponse {
  final bool success;
  final StockData? data;
  final String? error;
  final String? errorCode;

  StockApiResponse._({
    required this.success,
    this.data,
    this.error,
    this.errorCode,
  });

  factory StockApiResponse.success({required StockData data}) {
    return StockApiResponse._(success: true, data: data);
  }

  factory StockApiResponse.failure({
    required String error,
    required String errorCode,
  }) {
    return StockApiResponse._(
      success: false,
      error: error,
      errorCode: errorCode,
    );
  }
}

/// Data model for stock API responses
class StockData {
  final String id;
  final String symbol;
  final String? companyName;
  final String? sector;
  final String? industryGroup;
  final String? grade;
  final bool isInvestmentGrade;
  final String displayName;
  final DateTime createdAt;

  StockData({
    required this.id,
    required this.symbol,
    this.companyName,
    this.sector,
    this.industryGroup,
    this.grade,
    required this.isInvestmentGrade,
    required this.displayName,
    required this.createdAt,
  });

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      id: json['id'],
      symbol: json['symbol'],
      companyName: json['companyName'],
      sector: json['sector'],
      industryGroup: json['industryGroup'],
      grade: json['grade'],
      isInvestmentGrade: json['isInvestmentGrade'],
      displayName: json['displayName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
```

### Phase 6: Client Application Layer (Flutter)

#### Step 11: Create Client Service

**Purpose**: Orchestrate API calls and provide business logic for the UI.

**File**: `zenvestor_flutter/lib/src/application/services/stock_service.dart`

```dart
import '../../infrastructure/api/stock_api_client.dart';
import '../mappers/stock_ui_mapper.dart';
import '../../presentation/stock/models/stock_display_model.dart';

/// Client-side service for stock operations
class StockService {
  final StockApiClient _apiClient;
  final StockUiMapper _mapper;

  StockService(this._apiClient, this._mapper);

  /// Add a new stock
  Future<StockServiceResult> addStock({
    required String symbol,
    String? companyName,
    String? sector,
    String? industryGroup,
    String? grade,
    String? notes,
  }) async {
    // Client-side validation
    if (symbol.isEmpty) {
      return StockServiceResult.validationError('Symbol is required');
    }

    if (symbol.length > 5) {
      return StockServiceResult.validationError(
        'Symbol cannot exceed 5 characters'
      );
    }

    // Call API
    final response = await _apiClient.addStock(
      symbol: symbol.toUpperCase(),
      companyName: companyName?.trim(),
      sector: sector,
      industryGroup: industryGroup,
      grade: grade,
      notes: notes?.trim(),
    );

    if (response.success && response.data != null) {
      final displayModel = _mapper.toDisplayModel(response.data!);
      return StockServiceResult.success(displayModel);
    } else {
      // Map error codes to user-friendly messages
      final userMessage = _mapErrorMessage(
        response.errorCode ?? 'UNKNOWN',
        response.error ?? 'Unknown error occurred',
      );
      return StockServiceResult.apiError(userMessage);
    }
  }

  /// Get dropdown options for sectors
  Future<List<String>> getAvailableSectors() async {
    return await _apiClient.getAvailableSectors();
  }

  /// Get dropdown options for grades
  Future<List<String>> getAvailableGrades() async {
    return await _apiClient.getAvailableGrades();
  }

  String _mapErrorMessage(String errorCode, String defaultMessage) {
    switch (errorCode) {
      case 'DUPLICATE_STOCK':
        return 'This stock symbol already exists in your portfolio';
      case 'INVALID_SYMBOL':
        return 'Please enter a valid stock symbol (letters only)';
      case 'INVALID_SECTOR':
        return 'Please select a valid sector from the list';
      case 'INVALID_GRADE':
        return 'Please select a valid grade from the list';
      case 'NETWORK_ERROR':
        return 'Unable to connect. Please check your internet connection';
      default:
        return defaultMessage;
    }
  }
}

/// Result wrapper for service operations
class StockServiceResult {
  final bool success;
  final StockDisplayModel? data;
  final String? error;
  final ServiceErrorType? errorType;

  StockServiceResult._({
    required this.success,
    this.data,
    this.error,
    this.errorType,
  });

  factory StockServiceResult.success(StockDisplayModel data) {
    return StockServiceResult._(success: true, data: data);
  }

  factory StockServiceResult.validationError(String error) {
    return StockServiceResult._(
      success: false,
      error: error,
      errorType: ServiceErrorType.validation,
    );
  }

  factory StockServiceResult.apiError(String error) {
    return StockServiceResult._(
      success: false,
      error: error,
      errorType: ServiceErrorType.api,
    );
  }
}

enum ServiceErrorType { validation, api }
```

#### Step 12: Implement UI Mapper

**Purpose**: Transform API models to UI-optimized display models.

**File**: `zenvestor_flutter/lib/src/application/mappers/stock_ui_mapper.dart`

```dart
import '../../infrastructure/api/stock_api_client.dart';
import '../../presentation/stock/models/stock_display_model.dart';

/// Maps API models to UI display models
class StockUiMapper {
  /// Convert API stock data to display model
  StockDisplayModel toDisplayModel(StockData data) {
    return StockDisplayModel(
      id: data.id,
      symbol: data.symbol,
      displayName: data.displayName,
      companyName: data.companyName,
      sector: data.sector,
      industryGroup: data.industryGroup,
      grade: data.grade,
      gradeColor: _getGradeColor(data.grade),
      isInvestmentGrade: data.isInvestmentGrade,
      sectorIcon: _getSectorIcon(data.sector),
      createdAt: data.createdAt,
      formattedDate: _formatDate(data.createdAt),
    );
  }

  Color _getGradeColor(String? grade) {
    if (grade == null) return Colors.grey;
    
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSectorIcon(String? sector) {
    if (sector == null) return Icons.business;
    
    switch (sector) {
      case 'Technology':
        return Icons.computer;
      case 'Healthcare':
        return Icons.local_hospital;
      case 'Financial Services':
        return Icons.account_balance;
      case 'Energy':
        return Icons.bolt;
      case 'Real Estate':
        return Icons.home;
      default:
        return Icons.business;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
```

### Phase 7: Presentation Layer (Flutter)

#### Step 13: Define UI Models and State

**Purpose**: Create UI-specific models and state management.

**File**: `zenvestor_flutter/lib/src/presentation/stock/models/stock_display_model.dart`

```dart
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// UI model optimized for display
class StockDisplayModel extends Equatable {
  final String id;
  final String symbol;
  final String displayName;
  final String? companyName;
  final String? sector;
  final String? industryGroup;
  final String? grade;
  final Color gradeColor;
  final bool isInvestmentGrade;
  final IconData sectorIcon;
  final DateTime createdAt;
  final String formattedDate;

  const StockDisplayModel({
    required this.id,
    required this.symbol,
    required this.displayName,
    this.companyName,
    this.sector,
    this.industryGroup,
    this.grade,
    required this.gradeColor,
    required this.isInvestmentGrade,
    required this.sectorIcon,
    required this.createdAt,
    required this.formattedDate,
  });

  @override
  List<Object?> get props => [
    id, symbol, displayName, companyName, sector, 
    industryGroup, grade, isInvestmentGrade,
  ];
}
```

**File**: `zenvestor_flutter/lib/src/presentation/stock/state/add_stock_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../models/stock_display_model.dart';

/// State for add stock flow
abstract class AddStockState extends Equatable {
  const AddStockState();

  @override
  List<Object?> get props => [];
}

/// Initial state - form ready for input
class AddStockInitial extends AddStockState {
  final List<String> availableSectors;
  final List<String> availableGrades;

  const AddStockInitial({
    required this.availableSectors,
    required this.availableGrades,
  });

  @override
  List<Object> get props => [availableSectors, availableGrades];
}

/// Loading state - submitting to server
class AddStockLoading extends AddStockState {
  const AddStockLoading();
}

/// Success state - stock created
class AddStockSuccess extends AddStockState {
  final StockDisplayModel stock;

  const AddStockSuccess(this.stock);

  @override
  List<Object> get props => [stock];
}

/// Error state - validation or API error
class AddStockError extends AddStockState {
  final String message;
  final bool isValidationError;

  const AddStockError({
    required this.message,
    this.isValidationError = false,
  });

  @override
  List<Object> get props => [message, isValidationError];
}
```

#### Step 14: Create View Model

**Purpose**: Manage UI state and coordinate with services.

**File**: `zenvestor_flutter/lib/src/presentation/stock/view_models/add_stock_view_model.dart`

```dart
import 'package:flutter/foundation.dart';
import '../../../application/services/stock_service.dart';
import '../state/add_stock_state.dart';
import '../models/stock_display_model.dart';

/// View model for add stock page
class AddStockViewModel extends ChangeNotifier {
  final StockService _stockService;
  
  AddStockState _state = const AddStockInitial(
    availableSectors: [],
    availableGrades: [],
  );
  
  AddStockState get state => _state;

  AddStockViewModel(this._stockService) {
    _loadDropdownData();
  }

  /// Load sectors and grades for dropdowns
  Future<void> _loadDropdownData() async {
    final sectors = await _stockService.getAvailableSectors();
    final grades = await _stockService.getAvailableGrades();
    
    _state = AddStockInitial(
      availableSectors: sectors,
      availableGrades: grades,
    );
    notifyListeners();
  }

  /// Add a new stock
  Future<void> addStock({
    required String symbol,
    String? companyName,
    String? sector,
    String? industryGroup,
    String? grade,
    String? notes,
  }) async {
    // Set loading state
    _state = const AddStockLoading();
    notifyListeners();

    // Call service
    final result = await _stockService.addStock(
      symbol: symbol,
      companyName: companyName,
      sector: sector,
      industryGroup: industryGroup,
      grade: grade,
      notes: notes,
    );

    // Update state based on result
    if (result.success && result.data != null) {
      _state = AddStockSuccess(result.data!);
    } else {
      _state = AddStockError(
        message: result.error ?? 'Failed to add stock',
        isValidationError: result.errorType == ServiceErrorType.validation,
      );
    }
    
    notifyListeners();
  }

  /// Reset to initial state
  void reset() {
    _loadDropdownData();
  }

  /// Get filtered industry groups based on selected sector
  List<String> getIndustryGroupsForSector(String? sector) {
    if (sector == null) return [];
    
    // This would come from a service in a real app
    const sectorIndustries = {
      'Technology': ['Software', 'Hardware', 'Semiconductors'],
      'Healthcare': ['Pharmaceuticals', 'Biotechnology', 'Medical Devices'],
      // ... other sectors
    };
    
    return sectorIndustries[sector] ?? [];
  }
}
```

#### Step 15: Create Add Stock Page

**Purpose**: Build the UI for adding a new stock.

**File**: `zenvestor_flutter/lib/src/presentation/stock/pages/add_stock_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/add_stock_view_model.dart';
import '../state/add_stock_state.dart';
import '../widgets/stock_form.dart';

/// Page for adding a new stock
class AddStockPage extends StatefulWidget {
  const AddStockPage({Key? key}) : super(key: key);

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Stock'),
      ),
      body: Consumer<AddStockViewModel>(
        builder: (context, viewModel, child) {
          final state = viewModel.state;

          // Handle success state
          if (state is AddStockSuccess) {
            // Navigate to stock detail page after frame renders
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(
                '/stock/${state.stock.id}',
                arguments: state.stock,
              );
            });
            return const Center(child: CircularProgressIndicator());
          }

          // Show form
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error message
                if (state is AddStockError)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: state.isValidationError
                          ? Colors.orange.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: state.isValidationError
                            ? Colors.orange
                            : Colors.red,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          state.isValidationError
                              ? Icons.warning
                              : Icons.error,
                          color: state.isValidationError
                              ? Colors.orange
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.message,
                            style: TextStyle(
                              color: state.isValidationError
                                  ? Colors.orange.shade900
                                  : Colors.red.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Stock form
                StockForm(
                  availableSectors: state is AddStockInitial
                      ? state.availableSectors
                      : [],
                  availableGrades: state is AddStockInitial
                      ? state.availableGrades
                      : [],
                  isLoading: state is AddStockLoading,
                  onSubmit: (formData) {
                    viewModel.addStock(
                      symbol: formData.symbol,
                      companyName: formData.companyName,
                      sector: formData.sector,
                      industryGroup: formData.industryGroup,
                      grade: formData.grade,
                      notes: formData.notes,
                    );
                  },
                  onSectorChanged: (sector) {
                    // Update industry groups when sector changes
                    return viewModel.getIndustryGroupsForSector(sector);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

#### Step 16: Create Stock Form Widget

**Purpose**: Reusable form widget for stock input.

**File**: `zenvestor_flutter/lib/src/presentation/stock/widgets/stock_form.dart`

```dart
import 'package:flutter/material.dart';

/// Form data model
class StockFormData {
  final String symbol;
  final String? companyName;
  final String? sector;
  final String? industryGroup;
  final String? grade;
  final String? notes;

  StockFormData({
    required this.symbol,
    this.companyName,
    this.sector,
    this.industryGroup,
    this.grade,
    this.notes,
  });
}

/// Reusable stock form widget
class StockForm extends StatefulWidget {
  final List<String> availableSectors;
  final List<String> availableGrades;
  final bool isLoading;
  final Function(StockFormData) onSubmit;
  final List<String> Function(String?) onSectorChanged;

  const StockForm({
    Key? key,
    required this.availableSectors,
    required this.availableGrades,
    required this.isLoading,
    required this.onSubmit,
    required this.onSectorChanged,
  }) : super(key: key);

  @override
  State<StockForm> createState() => _StockFormState();
}

class _StockFormState extends State<StockForm> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedSector;
  String? _selectedIndustryGroup;
  String? _selectedGrade;
  List<String> _availableIndustryGroups = [];

  @override
  void dispose() {
    _symbolController.dispose();
    _companyNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(StockFormData(
        symbol: _symbolController.text,
        companyName: _companyNameController.text.isEmpty
            ? null
            : _companyNameController.text,
        sector: _selectedSector,
        industryGroup: _selectedIndustryGroup,
        grade: _selectedGrade,
        notes: _notesController.text.isEmpty
            ? null
            : _notesController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Symbol field (required)
          TextFormField(
            controller: _symbolController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Stock Symbol *',
              hintText: 'e.g., AAPL',
              prefixIcon: Icon(Icons.tag),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Symbol is required';
              }
              if (value.length > 5) {
                return 'Symbol cannot exceed 5 characters';
              }
              if (!RegExp(r'^[A-Za-z]+$').hasMatch(value)) {
                return 'Symbol must contain only letters';
              }
              return null;
            },
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: 16),

          // Company name field (optional)
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Company Name',
              hintText: 'e.g., Apple Inc.',
              prefixIcon: Icon(Icons.business),
            ),
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: 16),

          // Sector dropdown (optional)
          DropdownButtonFormField<String>(
            value: _selectedSector,
            decoration: const InputDecoration(
              labelText: 'Sector',
              prefixIcon: Icon(Icons.category),
            ),
            items: widget.availableSectors.map((sector) {
              return DropdownMenuItem(
                value: sector,
                child: Text(sector),
              );
            }).toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    setState(() {
                      _selectedSector = value;
                      _selectedIndustryGroup = null;
                      _availableIndustryGroups = 
                          widget.onSectorChanged(value);
                    });
                  },
          ),
          const SizedBox(height: 16),

          // Industry group dropdown (optional, depends on sector)
          DropdownButtonFormField<String>(
            value: _selectedIndustryGroup,
            decoration: const InputDecoration(
              labelText: 'Industry Group',
              prefixIcon: Icon(Icons.work),
            ),
            items: _availableIndustryGroups.map((industry) {
              return DropdownMenuItem(
                value: industry,
                child: Text(industry),
              );
            }).toList(),
            onChanged: widget.isLoading || _selectedSector == null
                ? null
                : (value) {
                    setState(() {
                      _selectedIndustryGroup = value;
                    });
                  },
          ),
          const SizedBox(height: 16),

          // Grade dropdown (optional)
          DropdownButtonFormField<String>(
            value: _selectedGrade,
            decoration: const InputDecoration(
              labelText: 'Investment Grade',
              prefixIcon: Icon(Icons.grade),
            ),
            items: widget.availableGrades.map((grade) {
              return DropdownMenuItem(
                value: grade,
                child: Text(grade),
              );
            }).toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    setState(() {
                      _selectedGrade = value;
                    });
                  },
          ),
          const SizedBox(height: 16),

          // Notes field (optional)
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes',
              hintText: 'Investment rationale, key metrics, etc.',
              prefixIcon: Icon(Icons.note),
              alignLabelWithHint: true,
            ),
            enabled: !widget.isLoading,
          ),
          const SizedBox(height: 24),

          // Submit button
          ElevatedButton(
            onPressed: widget.isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add Stock'),
          ),
        ],
      ),
    );
  }
}
```

## Testing Strategy

### Server-Side Tests

#### Test: Domain Entity
**File**: `zenvestor_server/test/domain/stock/stock_test.dart`

```dart
import 'package:test/test.dart';
import 'package:zenvestor_server/src/domain/stock/stock.dart';
import 'package:zenvestor_server/src/domain/exceptions/exceptions.dart';

void main() {
  group('Stock Entity', () {
    test('creates valid stock with all fields', () {
      final stock = Stock.create(
        symbol: 'AAPL',
        companyName: 'Apple Inc.',
        sector: 'Technology',
        industryGroup: 'Hardware',
        grade: 'A',
        notes: 'Strong fundamentals',
      );

      expect(stock.symbol.value, 'AAPL');
      expect(stock.companyName?.value, 'Apple Inc.');
      expect(stock.sector?.value, 'Technology');
      expect(stock.isInvestmentGrade, true);
      expect(stock.displayName, 'AAPL - Apple Inc.');
    });

    test('creates valid stock with minimal fields', () {
      final stock = Stock.create(symbol: 'GOOGL');

      expect(stock.symbol.value, 'GOOGL');
      expect(stock.companyName, null);
      expect(stock.notes, null);
      expect(stock.displayName, 'GOOGL');
    });

    test('throws error for invalid symbol', () {
      expect(
        () => Stock.create(symbol: '123ABC'),
        throwsA(isA<InvalidStockSymbolException>()),
      );
    });

    test('throws error for industry without sector', () {
      expect(
        () => Stock.create(
          symbol: 'AAPL',
          industryGroup: 'Software',
        ),
        throwsArgumentError,
      );
    });

    test('validates sector-industry combination', () {
      expect(
        () => Stock.create(
          symbol: 'AAPL',
          sector: 'Healthcare',
          industryGroup: 'Software', // Invalid for Healthcare
        ),
        throwsA(isA<InvalidIndustryGroupException>()),
      );
    });
  });
}
```

#### Test: Add Stock Use Case
**File**: `zenvestor_server/test/application/use_cases/add_stock_test.dart`

```dart
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:zenvestor_server/src/application/use_cases/stock/add_stock.dart';
import 'package:zenvestor_server/src/domain/stock/repository.dart';
import 'package:zenvestor_server/src/domain/exceptions/exceptions.dart';

class MockStockRepository extends Mock implements StockRepository {}

void main() {
  late AddStock useCase;
  late MockStockRepository repository;

  setUp(() {
    repository = MockStockRepository();
    useCase = AddStock(repository);
  });

  group('AddStock Use Case', () {
    test('successfully adds new stock', () async {
      // Arrange
      when(repository.symbolExists('AAPL'))
          .thenAnswer((_) async => Right(false));
      when(repository.create(any))
          .thenAnswer((invocation) async => Right(invocation.positionalArguments[0]));

      // Act
      final result = await useCase.execute(
        symbol: 'AAPL',
        companyName: 'Apple Inc.',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should succeed'),
        (stock) {
          expect(stock.symbol.value, 'AAPL');
          expect(stock.companyName?.value, 'Apple Inc.');
        },
      );
    });

    test('returns error for duplicate symbol', () async {
      // Arrange
      when(repository.symbolExists('AAPL'))
          .thenAnswer((_) async => Right(true));

      // Act
      final result = await useCase.execute(symbol: 'AAPL');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DuplicateStockException>()),
        (stock) => fail('Should fail with duplicate error'),
      );
    });

    test('handles repository error', () async {
      // Arrange
      when(repository.symbolExists('AAPL'))
          .thenAnswer((_) async => Left(InfrastructureException('DB error')));

      // Act
      final result = await useCase.execute(symbol: 'AAPL');

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
```

### Flutter Tests

#### Test: View Model
**File**: `zenvestor_flutter/test/presentation/view_models/add_stock_view_model_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:zenvestor_flutter/src/presentation/stock/view_models/add_stock_view_model.dart';
import 'package:zenvestor_flutter/src/application/services/stock_service.dart';

class MockStockService extends Mock implements StockService {}

void main() {
  late AddStockViewModel viewModel;
  late MockStockService service;

  setUp(() {
    service = MockStockService();
    viewModel = AddStockViewModel(service);
  });

  group('AddStockViewModel', () {
    test('loads dropdown data on initialization', () async {
      // Arrange
      when(service.getAvailableSectors())
          .thenAnswer((_) async => ['Technology', 'Healthcare']);
      when(service.getAvailableGrades())
          .thenAnswer((_) async => ['A', 'B', 'C']);

      // Act
      await Future.delayed(Duration.zero); // Let initialization complete

      // Assert
      final state = viewModel.state;
      expect(state, isA<AddStockInitial>());
      final initial = state as AddStockInitial;
      expect(initial.availableSectors.length, 2);
      expect(initial.availableGrades.length, 3);
    });

    test('handles successful stock addition', () async {
      // Arrange
      final mockStock = StockDisplayModel(
        id: '1',
        symbol: 'AAPL',
        displayName: 'AAPL',
        gradeColor: Colors.green,
        isInvestmentGrade: true,
        sectorIcon: Icons.computer,
        createdAt: DateTime.now(),
        formattedDate: 'Today',
      );

      when(service.addStock(
        symbol: 'AAPL',
        companyName: null,
        sector: null,
        industryGroup: null,
        grade: null,
        notes: null,
      )).thenAnswer((_) async => StockServiceResult.success(mockStock));

      // Act
      await viewModel.addStock(symbol: 'AAPL');

      // Assert
      expect(viewModel.state, isA<AddStockSuccess>());
      final success = viewModel.state as AddStockSuccess;
      expect(success.stock.symbol, 'AAPL');
    });

    test('handles validation error', () async {
      // Arrange
      when(service.addStock(
        symbol: '',
        companyName: null,
        sector: null,
        industryGroup: null,
        grade: null,
        notes: null,
      )).thenAnswer((_) async => 
        StockServiceResult.validationError('Symbol is required')
      );

      // Act
      await viewModel.addStock(symbol: '');

      // Assert
      expect(viewModel.state, isA<AddStockError>());
      final error = viewModel.state as AddStockError;
      expect(error.message, 'Symbol is required');
      expect(error.isValidationError, true);
    });
  });
}
```

#### Test: Widget Test
**File**: `zenvestor_flutter/test/presentation/widgets/stock_form_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvestor_flutter/src/presentation/stock/widgets/stock_form.dart';

void main() {
  group('StockForm Widget', () {
    testWidgets('displays all form fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockForm(
              availableSectors: ['Technology', 'Healthcare'],
              availableGrades: ['A', 'B', 'C'],
              isLoading: false,
              onSubmit: (_) {},
              onSectorChanged: (_) => [],
            ),
          ),
        ),
      );

      expect(find.text('Stock Symbol *'), findsOneWidget);
      expect(find.text('Company Name'), findsOneWidget);
      expect(find.text('Sector'), findsOneWidget);
      expect(find.text('Investment Grade'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Add Stock'), findsOneWidget);
    });

    testWidgets('validates required symbol field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockForm(
              availableSectors: [],
              availableGrades: [],
              isLoading: false,
              onSubmit: (_) {},
              onSectorChanged: (_) => [],
            ),
          ),
        ),
      );

      // Tap submit without entering symbol
      await tester.tap(find.text('Add Stock'));
      await tester.pumpAndSettle();

      expect(find.text('Symbol is required'), findsOneWidget);
    });

    testWidgets('disables form when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockForm(
              availableSectors: [],
              availableGrades: [],
              isLoading: true,
              onSubmit: (_) {},
              onSectorChanged: (_) => [],
            ),
          ),
        ),
      );

      final symbolField = find.byType(TextFormField).first;
      final textField = tester.widget<TextFormField>(symbolField);
      expect(textField.enabled, false);

      final submitButton = find.byType(ElevatedButton);
      final button = tester.widget<ElevatedButton>(submitButton);
      expect(button.onPressed, null);
    });
  });
}
```

### Integration Test

**File**: `zenvestor_flutter/integration_test/add_stock_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zenvestor_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Add Stock Integration Test', () {
    testWidgets('complete add stock flow', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add stock page
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Stock Symbol *'),
        'AAPL',
      );
      
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Company Name'),
        'Apple Inc.',
      );

      // Select sector
      await tester.tap(find.text('Sector'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Technology').last);
      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.text('Add Stock'));
      await tester.pumpAndSettle();

      // Verify navigation to stock detail
      expect(find.text('AAPL - Apple Inc.'), findsOneWidget);
      expect(find.text('Technology'), findsOneWidget);
    });
  });
}
```

## Common Pitfalls

### 1. Forgetting to Regenerate Code
**Problem**: Modifying YAML files without running `serverpod generate`.
**Solution**: Always run generation after YAML changes.

### 2. Domain Logic in Wrong Layer
**Problem**: Putting business rules in endpoints or UI.
**Solution**: Keep business logic in domain entities and use cases.

### 3. Skipping Value Objects
**Problem**: Using raw strings instead of value objects.
**Solution**: Create value objects for all constrained values.

### 4. Tight Coupling
**Problem**: Importing Serverpod in domain layer.
**Solution**: Use repository interfaces and mappers.

### 5. Missing Error Handling
**Problem**: Not handling all error cases.
**Solution**: Use Either types and handle all failure scenarios.

## Conclusion

This implementation plan demonstrates how to build a complete feature following clean architecture principles with Serverpod. The key takeaways are:

1. **Start with the domain** - Define your business concepts first
2. **Use code generation** - Let Serverpod handle the boilerplate
3. **Maintain boundaries** - Keep layers separate and focused
4. **Test each layer** - Ensure quality at every level
5. **Handle errors gracefully** - Provide meaningful feedback to users

By following this plan, you can implement any feature in Zenvestor while maintaining architectural integrity and code quality.