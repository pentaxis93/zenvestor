# Zenvestor Serverpod Clean Architecture Guide

## Overview

This guide defines the architecture for Zenvestor built with Serverpod, Flutter, and Clean Architecture principles. We leverage Serverpod's code generation while maintaining clear separation of concerns and rich domain modeling.

## Architecture Philosophy

### Serverpod-Optimized Clean Architecture

Our approach recognizes that Serverpod's code generation handles many traditional clean architecture concerns automatically:

1. **YAML files define domain structure** - Part of the domain layer, not infrastructure
2. **Generated code provides automatic DTOs and contracts** - No manual DTO creation needed
3. **Domain entities add behavior and business logic** - Complementing the structural definitions
4. **Repository interfaces abstract persistence** - Maintaining domain independence

### Key Principles

- **Domain Independence**: Business logic remains independent of infrastructure
- **Code Generation as Architecture**: Generated code replaces manual boilerplate
- **Simplified Layers**: Fewer translation layers needed due to automatic code generation
- **Managed Redundancy**: Accept minimal redundancy between YAML and domain entities

### What Serverpod Handles Automatically

Traditional clean architecture often includes:
- Manual DTOs for each layer
- Explicit contracts/interfaces between layers
- Translation/mapping code between models
- Boilerplate CRUD operations

Serverpod's code generation provides:
- **Automatic DTOs** from YAML definitions
- **Type-safe client-server contracts**
- **Database operation implementations**
- **Serialization/deserialization logic**

This allows us to focus on business logic rather than plumbing code.

## Project Structure

Serverpod creates three top-level directories for our project:

```
zenvestor/
├── zenvestor_server/      # Backend server application
├── zenvestor_client/      # Generated client protocol (don't modify)
└── zenvestor_flutter/     # Flutter application
```

### Directory Structure

```
zenvestor_server/
├── config/                          # Serverpod configuration
├── generated/                       # Auto-generated code (don't edit)
├── lib/
│   ├── src/
│   │   ├── domain/                 # Domain layer
│   │   │   ├── stock/              # Stock aggregate
│   │   │   │   ├── stock.yaml      # Structure definition
│   │   │   │   ├── stock.dart      # Behavior & logic
│   │   │   │   ├── value_objects/
│   │   │   │   │   ├── stock_symbol.dart
│   │   │   │   │   ├── company_name.dart
│   │   │   │   │   ├── sector.dart
│   │   │   │   │   ├── industry_group.dart
│   │   │   │   │   ├── grade.dart
│   │   │   │   │   └── notes.dart
│   │   │   │   └── repository.dart  # Repository interface
│   │   │   ├── portfolio/          # Portfolio aggregate
│   │   │   └── exceptions/
│   │   │       └── exceptions.dart
│   │   ├── application/            # Use cases & orchestration
│   │   │   ├── use_cases/
│   │   │   │   └── stock/
│   │   │   │       ├── add_stock.dart
│   │   │   │       ├── update_stock.dart
│   │   │   │       └── get_stock.dart
│   │   │   └── services/
│   │   │       └── stock_service.dart
│   │   ├── infrastructure/         # External interfaces
│   │   │   ├── repositories/
│   │   │   │   └── stock_repository.dart
│   │   │   └── mappers/
│   │   │       └── stock_mapper.dart
│   │   └── endpoints/              # API endpoints
│   │       └── stock_endpoint.dart
│   └── server.dart
└── test/

zenvestor_client/
└── lib/
    └── src/
        └── protocol/                # Generated client-server protocol

zenvestor_flutter/
├── lib/
│   ├── src/
│   │   ├── presentation/            # Presentation layer
│   │   │   ├── stock/
│   │   │   │   ├── pages/
│   │   │   │   │   ├── stock_list_page.dart
│   │   │   │   │   ├── stock_detail_page.dart
│   │   │   │   │   └── add_stock_page.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── stock_card.dart
│   │   │   │   │   ├── stock_form.dart
│   │   │   │   │   └── grade_indicator.dart
│   │   │   │   ├── view_models/
│   │   │   │   │   ├── stock_list_view_model.dart
│   │   │   │   │   ├── stock_detail_view_model.dart
│   │   │   │   │   └── add_stock_view_model.dart
│   │   │   │   └── state/
│   │   │   │       └── stock_state.dart
│   │   │   └── shared/
│   │   │       ├── widgets/
│   │   │       └── theme/
│   │   ├── application/             # Client-side application layer
│   │   │   ├── services/
│   │   │   │   └── stock_service.dart
│   │   │   └── mappers/
│   │   │       └── stock_ui_mapper.dart
│   │   └── infrastructure/          # Client-side infrastructure
│   │       └── api/
│   │           └── stock_api_client.dart
│   └── main.dart
└── test/
```

## Understanding Serverpod's Three-Project Structure

### zenvestor_server
Contains all backend logic including:
- Domain models and business rules
- Use cases and application services
- API endpoints
- Database access through Serverpod

### zenvestor_client
**Generated code only** - do not add custom code here:
- Protocol definitions generated from YAML files
- Client stubs for calling server endpoints
- Shared data models used by both server and Flutter app

### zenvestor_flutter
The Flutter application with all UI and client-side logic:
- Presentation layer (pages, widgets, view models)
- Client-side application services
- API client implementations
- State management

## Layer-by-Layer Implementation

### 1. Domain Layer (zenvestor_server)

#### YAML Structure Definition
**File:** `zenvestor_server/lib/src/domain/stock/stock.yaml`

```yaml
class: Stock
table: stocks
fields:
  symbol: String
  companyName: String?
  sector: String?
  industryGroup: String?
  grade: String?
  notes: String
  createdAt: DateTime
  updatedAt: DateTime
indexes:
  symbol_index:
    fields: symbol
    unique: true
```

**Note on Redundancy**: This YAML file defines the structure that will also appear in the domain entity below. This redundancy is unavoidable but manageable by keeping these files together.

#### Domain Entity
**File:** `zenvestor_server/lib/src/domain/stock/stock.dart`

```dart
import 'package:equatable/equatable.dart';
import 'value_objects/stock_symbol.dart';
import 'value_objects/company_name.dart';
import 'value_objects/sector.dart';
import 'value_objects/industry_group.dart';
import 'value_objects/grade.dart';
import 'value_objects/notes.dart';

/// Rich domain entity representing a stock/security.
/// Encapsulates business logic for stock operations including
/// validation, calculations, and state management.
///
/// Note: Field definitions mirror stock.yaml - keep synchronized
class Stock extends Equatable {
  final String id;
  final StockSymbol symbol;
  final CompanyName? companyName;
  final Sector? sector;
  final IndustryGroup? industryGroup;
  final Grade? grade;
  final Notes notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Stock({
    required this.id,
    required this.symbol,
    this.companyName,
    this.sector,
    this.industryGroup,
    this.grade,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Builder pattern for elegant construction
  factory Stock.builder({
    String? id,
    required StockSymbol symbol,
    CompanyName? companyName,
    Sector? sector,
    IndustryGroup? industryGroup,
    Grade? grade,
    Notes? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // Validate sector-industry combination
    if (industryGroup != null && sector == null) {
      throw ArgumentError('Sector must be provided when industry group is specified');
    }

    // Validate industry group belongs to sector
    if (industryGroup != null && sector != null) {
      industryGroup.validateSector(sector);
    }

    final now = DateTime.now();
    return Stock(
      id: id ?? '',
      symbol: symbol,
      companyName: companyName,
      sector: sector,
      industryGroup: industryGroup,
      grade: grade,
      notes: notes ?? const Notes(''),
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// String representation for display
  @override
  String toString() {
    if (companyName != null) {
      return '${symbol.value} - ${companyName!.value}';
    }
    return symbol.value;
  }

  /// Check if stock has notes
  bool get hasNotes => notes.hasContent;

  /// Update multiple fields at once with validation
  Stock updateFields({
    StockSymbol? symbol,
    CompanyName? companyName,
    Sector? sector,
    IndustryGroup? industryGroup,
    Grade? grade,
    Notes? notes,
  }) {
    // Handle sector-industry domain logic
    IndustryGroup? newIndustryGroup = industryGroup ?? this.industryGroup;
    Sector? newSector = sector ?? this.sector;

    // If changing sector and not explicitly changing industry group
    if (sector != null && industryGroup == null && this.industryGroup != null) {
      // Check if current industry group is compatible with new sector
      try {
        this.industryGroup!.validateSector(sector);
      } catch (_) {
        // Invalid combination, clear industry group
        newIndustryGroup = null;
      }
    }

    // Validate final combination
    if (newIndustryGroup != null && newSector == null) {
      throw ArgumentError('Sector must be provided when industry group is specified');
    }

    if (newIndustryGroup != null && newSector != null) {
      newIndustryGroup.validateSector(newSector);
    }

    return Stock(
      id: id,
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      sector: newSector,
      industryGroup: newIndustryGroup,
      grade: grade ?? this.grade,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    symbol,
    companyName,
    sector,
    industryGroup,
    grade,
    notes,
    createdAt,
    updatedAt,
  ];
}
```

#### Value Objects

**File:** `zenvestor_server/lib/src/domain/stock/value_objects/stock_symbol.dart`

```dart
import '../../exceptions/exceptions.dart';

class StockSymbol {
  final String value;

  factory StockSymbol(String input) {
    final trimmed = input.trim().toUpperCase();

    if (trimmed.isEmpty || trimmed.length > 5) {
      throw InvalidStockSymbolException(
        'Stock symbol must be 1-5 characters'
      );
    }

    if (!RegExp(r'^[A-Z]+$').hasMatch(trimmed)) {
      throw InvalidStockSymbolException(
        'Stock symbol must contain only letters'
      );
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

**File:** `zenvestor_server/lib/src/domain/stock/value_objects/sector.dart`

```dart
class Sector {
  static const _validSectors = {
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

    if (!_validSectors.contains(trimmed)) {
      throw InvalidSectorException(
        'Invalid sector: $trimmed. Must be one of: ${_validSectors.join(', ')}'
      );
    }

    return Sector._(trimmed);
  }

  const Sector._(this.value);

  static Set<String> get validSectors => Set.unmodifiable(_validSectors);
}
```

**File:** `zenvestor_server/lib/src/domain/stock/value_objects/industry_group.dart`

```dart
class IndustryGroup {
  // Map of sectors to their valid industry groups
  static const _sectorIndustryGroups = {
    'Technology': {
      'Software',
      'Hardware',
      'Semiconductors',
      'IT Services',
    },
    'Healthcare': {
      'Pharmaceuticals',
      'Biotechnology',
      'Medical Devices',
      'Healthcare Services',
    },
    // ... other sectors
  };

  final String value;

  factory IndustryGroup(String input, {String? sector}) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      throw InvalidIndustryGroupException('Industry group cannot be empty');
    }

    // If sector is provided, validate the combination
    if (sector != null) {
      final validGroups = _sectorIndustryGroups[sector];
      if (validGroups == null || !validGroups.contains(trimmed)) {
        throw InvalidIndustryGroupException(
          'Invalid industry group "$trimmed" for sector "$sector"'
        );
      }
    }

    return IndustryGroup._(trimmed);
  }

  const IndustryGroup._(this.value);

  /// Validate that this industry group is valid for the given sector
  void validateSector(Sector sector) {
    final validGroups = _sectorIndustryGroups[sector.value];
    if (validGroups == null || !validGroups.contains(value)) {
      throw InvalidIndustryGroupException(
        'Industry group "$value" is not valid for sector "${sector.value}"'
      );
    }
  }
}
```

**File:** `zenvestor_server/lib/src/domain/stock/value_objects/grade.dart`

```dart
class Grade {
  static const _validGrades = {'A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D', 'F'};

  final String value;

  factory Grade(String input) {
    final trimmed = input.trim().toUpperCase();

    if (!_validGrades.contains(trimmed)) {
      throw InvalidGradeException(
        'Invalid grade: $trimmed. Must be one of: ${_validGrades.join(', ')}'
      );
    }

    return Grade._(trimmed);
  }

  const Grade._(this.value);

  /// Get numeric value for comparisons
  double get numericValue {
    const gradeValues = {
      'A+': 4.3, 'A': 4.0, 'A-': 3.7,
      'B+': 3.3, 'B': 3.0, 'B-': 2.7,
      'C+': 2.3, 'C': 2.0, 'C-': 1.7,
      'D': 1.0, 'F': 0.0,
    };
    return gradeValues[value] ?? 0.0;
  }

  bool get isInvestmentGrade => numericValue >= 3.0; // B or higher
}
```

**File:** `zenvestor_server/lib/src/domain/stock/value_objects/notes.dart`

```dart
class Notes {
  final String value;

  factory Notes(String input) {
    final trimmed = input.trim();

    if (trimmed.length > 5000) {
      throw InvalidNotesException('Notes cannot exceed 5000 characters');
    }

    return Notes._(trimmed);
  }

  const Notes._(this.value);

  bool get hasContent => value.isNotEmpty;

  int get wordCount => value.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
}
```

#### Repository Interface
**File:** `zenvestor_server/lib/src/domain/stock/repository.dart`

```dart
import 'package:dartz/dartz.dart';
import 'stock.dart';
import '../exceptions/exceptions.dart';

abstract class StockRepository {
  Future<Either<DomainException, Stock>> create(Stock stock);
  Future<Either<DomainException, Stock>> getById(String id);
  Future<Either<DomainException, Stock>> getBySymbol(String symbol);
  Future<Either<DomainException, List<Stock>>> getAll();
  Future<Either<DomainException, List<Stock>>> getBySector(String sector);
  Future<Either<DomainException, List<Stock>>> getByGrade(String grade);
  Future<Either<DomainException, Stock>> update(Stock stock);
  Future<Either<DomainException, void>> delete(String id);
}
```

### 2. Application Layer (zenvestor_server)

#### Use Cases

**File:** `zenvestor_server/lib/src/application/use_cases/stock/add_stock.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../domain/stock/stock.dart';
import '../../../domain/stock/repository.dart';
import '../../../domain/stock/value_objects/stock_symbol.dart';
import '../../../domain/stock/value_objects/company_name.dart';
import '../../../domain/stock/value_objects/sector.dart';
import '../../../domain/stock/value_objects/industry_group.dart';
import '../../../domain/stock/value_objects/grade.dart';
import '../../../domain/stock/value_objects/notes.dart';
import '../../../domain/exceptions/exceptions.dart';

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
      // Create value objects (validation happens here)
      final stockSymbol = StockSymbol(symbol);

      // Check for duplicates
      final existingStock = await _repository.getBySymbol(stockSymbol.value);
      if (existingStock.isRight()) {
        return Left(DuplicateStockException(stockSymbol.value));
      }

      // Build the stock entity using builder pattern
      final stock = Stock.builder(
        symbol: stockSymbol,
        companyName: companyName != null ? CompanyName(companyName) : null,
        sector: sector != null ? Sector(sector) : null,
        industryGroup: industryGroup != null
          ? IndustryGroup(industryGroup, sector: sector)
          : null,
        grade: grade != null ? Grade(grade) : null,
        notes: notes != null ? Notes(notes) : null,
      );

      // Persist
      return await _repository.create(stock);
    } on DomainException catch (e) {
      return Left(e);
    }
  }
}
```

**File:** `zenvestor_server/lib/src/application/use_cases/stock/update_stock.dart`

```dart
class UpdateStock {
  final StockRepository _repository;

  UpdateStock(this._repository);

  Future<Either<DomainException, Stock>> execute({
    required String id,
    String? symbol,
    String? companyName,
    String? sector,
    String? industryGroup,
    String? grade,
    String? notes,
  }) async {
    try {
      // Fetch existing stock
      final stockResult = await _repository.getById(id);

      return stockResult.fold(
        (failure) => Left(failure),
        (stock) async {
          // Update fields using entity's update method
          final updatedStock = stock.updateFields(
            symbol: symbol != null ? StockSymbol(symbol) : null,
            companyName: companyName != null ? CompanyName(companyName) : null,
            sector: sector != null ? Sector(sector) : null,
            industryGroup: industryGroup != null
              ? IndustryGroup(industryGroup, sector: sector ?? stock.sector?.value)
              : null,
            grade: grade != null ? Grade(grade) : null,
            notes: notes != null ? Notes(notes) : null,
          );

          // Persist
          return await _repository.update(updatedStock);
        },
      );
    } on DomainException catch (e) {
      return Left(e);
    }
  }
}
```

### 3. Infrastructure Layer (zenvestor_server)

#### Mapper
**File:** `zenvestor_server/lib/src/infrastructure/mappers/stock_mapper.dart`

```dart
import '../../domain/stock/stock.dart';
import '../../domain/stock/value_objects/stock_symbol.dart';
import '../../domain/stock/value_objects/company_name.dart';
import '../../domain/stock/value_objects/sector.dart';
import '../../domain/stock/value_objects/industry_group.dart';
import '../../domain/stock/value_objects/grade.dart';
import '../../domain/stock/value_objects/notes.dart';
// Generated code import
import '../../generated/protocol.dart' as generated;

class StockMapper {
  /// Maps from generated DTO to domain entity
  static Stock toDomain(generated.Stock dto) {
    return Stock(
      id: dto.id.toString(),
      symbol: StockSymbol(dto.symbol),
      companyName: dto.companyName != null ? CompanyName(dto.companyName!) : null,
      sector: dto.sector != null ? Sector(dto.sector!) : null,
      industryGroup: dto.industryGroup != null
        ? IndustryGroup(dto.industryGroup!, sector: dto.sector)
        : null,
      grade: dto.grade != null ? Grade(dto.grade!) : null,
      notes: Notes(dto.notes),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Maps from domain entity to generated DTO
  static generated.Stock toDto(Stock entity) {
    return generated.Stock(
      id: entity.id.isEmpty ? null : int.parse(entity.id),
      symbol: entity.symbol.value,
      companyName: entity.companyName?.value,
      sector: entity.sector?.value,
      industryGroup: entity.industryGroup?.value,
      grade: entity.grade?.value,
      notes: entity.notes.value,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
```

#### Repository Implementation
**File:** `zenvestor_server/lib/src/infrastructure/repositories/stock_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:serverpod/serverpod.dart';
import '../../domain/stock/stock.dart';
import '../../domain/stock/repository.dart';
import '../../domain/exceptions/exceptions.dart';
import '../../generated/protocol.dart' as generated;
import '../mappers/stock_mapper.dart';

class StockRepository implements domain.StockRepository {
  final Session _session;

  StockRepository(this._session);

  @override
  Future<Either<DomainException, Stock>> create(Stock stock) async {
    try {
      // Convert domain entity to generated DTO
      final dto = StockMapper.toDto(stock);

      // Use Serverpod's generated database operations
      final savedDto = await generated.Stock.insert(_session, dto);

      // Convert back to domain entity
      final domainStock = StockMapper.toDomain(savedDto);
      return Right(domainStock);
    } catch (e) {
      return Left(InfrastructureException('Failed to create stock: $e'));
    }
  }

  @override
  Future<Either<DomainException, Stock>> getBySymbol(String symbol) async {
    try {
      // Use Serverpod's generated query methods
      final stocks = await generated.Stock.find(
        _session,
        where: (t) => t.symbol.equals(symbol),
        limit: 1,
      );

      if (stocks.isEmpty) {
        return Left(StockNotFoundException(symbol));
      }

      return Right(StockMapper.toDomain(stocks.first));
    } catch (e) {
      return Left(InfrastructureException('Failed to fetch stock: $e'));
    }
  }

  @override
  Future<Either<DomainException, List<Stock>>> getBySector(String sector) async {
    try {
      final stocks = await generated.Stock.find(
        _session,
        where: (t) => t.sector.equals(sector),
      );

      final entities = stocks.map(StockMapper.toDomain).toList();
      return Right(entities);
    } catch (e) {
      return Left(InfrastructureException('Failed to fetch stocks by sector: $e'));
    }
  }

  @override
  Future<Either<DomainException, List<Stock>>> getByGrade(String grade) async {
    try {
      final stocks = await generated.Stock.find(
        _session,
        where: (t) => t.grade.equals(grade),
      );

      final entities = stocks.map(StockMapper.toDomain).toList();
      return Right(entities);
    } catch (e) {
      return Left(InfrastructureException('Failed to fetch stocks by grade: $e'));
    }
  }

  // Other methods follow similar pattern...
}
```

### 4. API Layer - Endpoints (zenvestor_server)

**File:** `zenvestor_server/lib/src/endpoints/stock_endpoint.dart`

```dart
import 'package:serverpod/serverpod.dart';
import '../application/use_cases/stock/add_stock.dart';
import '../application/use_cases/stock/update_stock.dart';
import '../infrastructure/repositories/stock_repository.dart';

class StockEndpoint extends Endpoint {
  Future<Map<String, dynamic>> addStock(
    Session session,
    String symbol,
    String? companyName,
    String? sector,
    String? industryGroup,
    String? grade,
    String? notes,
  ) async {
    try {
      // Create repository with session
      final repository = StockRepository(session);

      // Create use case
      final useCase = AddStock(repository);

      // Execute business logic
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
            'notes': stock.notes.value,
            'hasNotes': stock.hasNotes,
          },
        },
      );
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error occurred: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateStock(
    Session session,
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final repository = StockRepository(session);
      final useCase = UpdateStock(repository);

      final result = await useCase.execute(
        id: id,
        symbol: updates['symbol'] as String?,
        companyName: updates['companyName'] as String?,
        sector: updates['sector'] as String?,
        industryGroup: updates['industryGroup'] as String?,
        grade: updates['grade'] as String?,
        notes: updates['notes'] as String?,
      );

      return result.fold(
        (failure) => {
          'success': false,
          'error': failure.message,
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
            'updatedAt': stock.updatedAt.toIso8601String(),
          },
        },
      );
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error occurred: $e',
      };
    }
  }
}
```

### 5. Client-Side Architecture (zenvestor_flutter)

#### Presentation Layer

**File:** `zenvestor_flutter/lib/src/presentation/stock/pages/stock_list_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/stock_list_view_model.dart';
import '../widgets/stock_card.dart';

class StockListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stocks')),
      body: Consumer<StockListViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return Center(
              child: Text('Error: ${viewModel.error}'),
            );
          }

          return ListView.builder(
            itemCount: viewModel.stocks.length,
            itemBuilder: (context, index) {
              final stock = viewModel.stocks[index];
              return StockCard(stock: stock);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-stock'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

#### View Model

**File:** `zenvestor_flutter/lib/src/presentation/stock/view_models/stock_list_view_model.dart`

```dart
import 'package:flutter/foundation.dart';
import '../../../application/services/stock_service.dart';
import '../state/stock_state.dart';

class StockListViewModel extends ChangeNotifier {
  final StockService _stockService;

  StockListState _state = const StockListState.initial();
  StockListState get state => _state;

  List<StockDisplayModel> get stocks => _state.stocks;
  bool get isLoading => _state is StockListLoading;
  bool get hasError => _state is StockListError;
  String? get error => (_state is StockListError)
    ? (_state as StockListError).message
    : null;

  StockListViewModel(this._stockService);

  Future<void> loadStocks() async {
    _state = const StockListState.loading();
    notifyListeners();

    try {
      final stocks = await _stockService.getAllStocks();
      _state = StockListState.loaded(stocks);
    } catch (e) {
      _state = StockListState.error(e.toString());
    }

    notifyListeners();
  }

  Future<void> refreshStocks() async {
    await loadStocks();
  }
}
```

#### Client-Side Service

**File:** `zenvestor_flutter/lib/src/application/services/stock_service.dart`

```dart
import '../../infrastructure/api/stock_api_client.dart';
import '../mappers/stock_ui_mapper.dart';
import '../../presentation/stock/state/stock_state.dart';

class StockService {
  final StockApiClient _apiClient;
  final StockUiMapper _mapper;

  StockService(this._apiClient, this._mapper);

  Future<List<StockDisplayModel>> getAllStocks() async {
    final response = await _apiClient.getAllStocks();
    return response.map(_mapper.toDisplayModel).toList();
  }

  Future<StockDisplayModel> addStock({
    required String symbol,
    String? companyName,
    String? sector,
    String? industryGroup,
    String? grade,
    String? notes,
  }) async {
    final response = await _apiClient.addStock(
      symbol: symbol,
      companyName: companyName,
      sector: sector,
      industryGroup: industryGroup,
      grade: grade,
      notes: notes,
    );

    return _mapper.toDisplayModel(response);
  }
}
```

#### API Client

**File:** `zenvestor_flutter/lib/src/infrastructure/api/stock_api_client.dart`

```dart
import 'package:zenvestor_client/zenvestor_client.dart';

class StockApiClient {
  final Client _client;

  StockApiClient(this._client);

  Future<List<Stock>> getAllStocks() async {
    // Using Serverpod's generated client
    final response = await _client.stock.getAllStocks();
    return response;
  }

  Future<Stock> addStock({
    required String symbol,
    String? companyName,
    String? sector,
    String? industryGroup,
    String? grade,
    String? notes,
  }) async {
    final response = await _client.stock.addStock(
      symbol,
      companyName,
      sector,
      industryGroup,
      grade,
      notes,
    );

    if (!response['success']) {
      throw Exception(response['error']);
    }

    // Convert response to Stock protocol object
    return Stock.fromJson(response['data']);
  }
}
```

## Step-by-Step Developer Guide

### Implementing a New Feature

Here's how to implement a new feature following our architecture:

#### Step 1: Define Domain Structure (YAML)

Create the YAML file in the appropriate domain folder. For example, for a Portfolio feature:

```bash
# Create domain folder structure in server
cd zenvestor_server
mkdir -p lib/src/domain/portfolio/value_objects
```

Create `zenvestor_server/lib/src/domain/portfolio/portfolio.yaml`:

```yaml
class: Portfolio
table: portfolios
fields:
  userId: int
  name: String
  description: String?
  targetAllocation: double?
  createdAt: DateTime
  updatedAt: DateTime
indexes:
  user_index:
    fields: userId
```

#### Step 2: Generate Code

Run Serverpod generation:
```bash
cd zenvestor_server
serverpod generate
```

This creates:
- Server-side DTO in `zenvestor_server/generated/protocol/portfolio.dart`
- Client-side protocol in `zenvestor_client/lib/src/protocol/portfolio.dart`
- Database operations

#### Step 3: Create Domain Entity

Create `zenvestor_server/lib/src/domain/portfolio/portfolio.dart`:

```dart
class Portfolio {
  final String id;
  final String userId;
  final PortfolioName name;  // Value object
  final String? description;
  final double? targetAllocation;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor matching YAML fields
  // Business logic methods like:
  bool get isFullyAllocated => targetAllocation == 100.0;
  // Equatable implementation
}
```

**Important**: Keep fields synchronized with YAML definition!

#### Step 4: Create Value Objects

Create value objects for business rules and validation:
- `portfolio_name.dart` - Validation for portfolio names
- Any other domain-specific validations

#### Step 5: Define Repository Interface

Create `zenvestor_server/lib/src/domain/portfolio/repository.dart`:

```dart
abstract class PortfolioRepository {
  Future<Either<DomainException, Portfolio>> create(Portfolio portfolio);
  Future<Either<DomainException, List<Portfolio>>> getByUserId(String userId);
  // Other operations
}
```

#### Step 6: Implement Server-Side Infrastructure

Create mapper in `zenvestor_server/lib/src/infrastructure/mappers/portfolio_mapper.dart`
Create repository in `zenvestor_server/lib/src/infrastructure/repositories/portfolio_repository.dart`

#### Step 7: Create Use Cases

Create use cases in `zenvestor_server/lib/src/application/use_cases/portfolio/`

#### Step 8: Create API Endpoint

Create `zenvestor_server/lib/src/endpoints/portfolio_endpoint.dart`

#### Step 9: Implement Client-Side Features

In `zenvestor_flutter/`:
- Create pages in `lib/src/presentation/portfolio/pages/`
- Create view models in `lib/src/presentation/portfolio/view_models/`
- Create widgets in `lib/src/presentation/portfolio/widgets/`
- Create client services in `lib/src/application/services/`
- Update API client in `lib/src/infrastructure/api/`

#### Step 10: Test

1. **Server tests** in `zenvestor_server/test/`
2. **Flutter widget tests** in `zenvestor_flutter/test/`
3. **Integration tests** across the full stack

### Development Flow Summary

```
Server Side:
1. Domain YAML → 2. Generate → 3. Domain Entity → 4. Value Objects
     ↓
5. Repository Interface → 6. Mapper → 7. Repository Implementation
     ↓
8. Use Cases → 9. Endpoints

Client Side:
10. API Client → 11. Client Service → 12. View Model
      ↓
13. Pages & Widgets → 14. User Interface
```

## Managing YAML-Entity Synchronization

### Best Practices

1. **Co-location**: Keep YAML and entity files together in domain folders
2. **Naming Convention**: Use consistent naming (e.g., `stock.yaml` → `stock.dart`)
3. **Documentation**: Comment in entity files when fields mirror YAML
4. **Code Reviews**: Always review YAML and entity changes together
5. **Testing**: Write tests that verify mapping correctness

### Synchronization Checklist

When modifying a domain model:
- [ ] Update YAML file with structural changes
- [ ] Run `serverpod generate` in server directory
- [ ] Update corresponding domain entity
- [ ] Update mapper if new fields added
- [ ] Update/create value objects for new validations
- [ ] Update client-side display models if needed
- [ ] Run tests to verify mapping

## Benefits of This Approach

### What We Keep from Clean Architecture
- **Domain Independence**: Business logic doesn't depend on Serverpod
- **Testability**: Each layer can be tested in isolation
- **Flexibility**: Can change infrastructure without touching domain
- **Clear Boundaries**: Explicit contracts between layers

### What We Simplify
- **No Manual DTOs**: Generated automatically from YAML
- **No Boilerplate Contracts**: Type safety through code generation
- **Less Translation Code**: Only one mapper per entity
- **Faster Development**: Focus on business logic, not plumbing

### Trade-offs Accepted
- **Minimal Redundancy**: YAML and entity definitions overlap
- **Generation Dependency**: Must regenerate when YAML changes
- **Framework Coupling**: YAML files use Serverpod's schema language

## Conclusion

This architecture successfully combines Clean Architecture principles with Serverpod's code generation to create a simplified, pragmatic approach for Zenvestor. By treating YAML files as domain definitions and leveraging code generation for cross-cutting concerns, we maintain architectural benefits while accelerating development.

Key takeaways:
- **YAML defines structure, entities define behavior**
- **Three-project structure separates concerns clearly**
- **Rich domain modeling is preserved**
- **Code generation replaces manual boilerplate**
- **Clear development flow from domain to UI**

The result is a maintainable, testable architecture that takes full advantage of Serverpod's capabilities while preserving Zenvestor's rich domain model and business logic.
