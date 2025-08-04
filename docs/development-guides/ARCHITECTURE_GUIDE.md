# Zenvestor Serverpod Clean Architecture Guide

## Overview

This guide defines the architecture for Zenvestor built with Serverpod, Flutter, and Clean Architecture principles. We leverage Serverpod's code generation while maintaining clear separation of concerns and rich domain modeling.

## Architecture Philosophy

### Serverpod-Optimized Clean Architecture with Shared Domain

Our approach combines Serverpod's code generation with a shared domain package that maintains framework independence:

1. **Shared domain package** - Framework-agnostic business logic shared between server and Flutter
2. **YAML files define infrastructure structure** - Serverpod-specific persistence models
3. **Generated code provides automatic DTOs and contracts** - No manual DTO creation needed
4. **Server domain entities extend shared domain** - Adding infrastructure concerns via wrapper pattern
5. **Repository interfaces abstract persistence** - Maintaining domain independence

### Key Principles

- **Domain Independence**: Business logic remains independent of infrastructure via shared domain package
- **Code Generation as Architecture**: Generated code replaces manual boilerplate
- **Framework Agnostic Core**: Shared domain has no Serverpod or Flutter dependencies
- **Simplified Layers**: Fewer translation layers needed due to automatic code generation
- **Clean Separation**: Infrastructure concerns isolated in server-specific wrappers

### What Serverpod Handles Automatically

Traditional clean architecture often includes:
- Manual DTOs for each layer
- Explicit contracts/interfaces between layers
- Translation/mapping code between models
- Boilerplate CRUD operations

Serverpod's code generation provides:
- **Automatic DTOs** from YAML definitions (see `/docs/serverpod-docs/06-concepts/02-models.md`)
- **Type-safe client-server contracts**
- **Database operation implementations** (see `/docs/serverpod-docs/06-concepts/06-database/`)
- **Serialization/deserialization logic**

This allows us to focus on business logic rather than plumbing code.

## Project Structure

Our project uses a four-part structure with a shared domain package:

```
zenvestor/
├── packages/
│   └── zenvestor_domain/  # Shared domain logic (framework-agnostic)
├── zenvestor_server/      # Backend server application
├── zenvestor_client/      # Generated client protocol (don't modify)
└── zenvestor_flutter/     # Flutter application
```

### Directory Structure

```
packages/
└── zenvestor_domain/               # Shared domain package
    ├── lib/
    │   ├── src/
    │   │   ├── shared/             # Cross-cutting concerns
    │   │   │   └── errors/         # Domain errors and validation
    │   │   └── stock/              # Stock aggregate
    │   │       ├── stock.dart      # Core entity
    │   │       ├── stock_errors.dart
    │   │       └── value_objects/
    │   │           ├── ticker_symbol.dart
    │   │           ├── company_name.dart
    │   │           ├── sic_code.dart
    │   │           └── grade.dart
    │   └── zenvestor_domain.dart  # Package exports
    └── test/

zenvestor_server/
├── config/                          # Serverpod configuration
├── generated/                       # Auto-generated code (don't edit)
├── lib/
│   ├── src/
│   │   ├── domain/                 # Server-specific domain extensions
│   │   │   ├── stock/              
│   │   │   │   ├── stock.yaml      # Serverpod structure definition
│   │   │   │   ├── server_stock.dart # Server wrapper with infrastructure
│   │   │   │   └── repository.dart  # Repository interface
│   │   │   └── portfolio/          # Portfolio aggregate
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

## Understanding the Four-Part Structure

### packages/zenvestor_domain
**Shared domain logic** - framework-agnostic business rules:
- Core domain entities and value objects
- Business validation and error types
- No dependencies on Serverpod or Flutter
- Used by both server and Flutter projects

### zenvestor_server
Contains all backend logic including:
- Server-specific domain wrappers (extending shared domain)
- Use cases and application services
- API endpoints
- Database access through Serverpod
- Infrastructure concerns (IDs, timestamps)

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
- Can import shared domain for type safety

## Layer-by-Layer Implementation

### 1. Shared Domain Layer (packages/zenvestor_domain)

#### Core Domain Entity
**File:** `packages/zenvestor_domain/lib/src/stock/stock.dart`

```dart
import 'package:equatable/equatable.dart';
import 'value_objects/ticker_symbol.dart';
import 'value_objects/company_name.dart';
import 'value_objects/sic_code.dart';
import 'value_objects/grade.dart';

/// Framework-agnostic domain entity representing a stock.
/// Contains only business logic and validation, no infrastructure concerns.
class Stock extends Equatable {
  final TickerSymbol tickerSymbol;
  final CompanyName companyName;
  final SicCode? primarySicCode;
  final SicCode? secondarySicCode;
  final Grade? grade;

  const Stock({
    required this.tickerSymbol,
    required this.companyName,
    this.primarySicCode,
    this.secondarySicCode,
    this.grade,
  });

  /// Business logic for validation
  factory Stock.create({
    required String ticker,
    required String name,
    String? primarySic,
    String? secondarySic,
    String? grade,
  }) {
    return Stock(
      tickerSymbol: TickerSymbol(ticker),
      companyName: CompanyName(name),
      primarySicCode: primarySic != null ? SicCode(primarySic) : null,
      secondarySicCode: secondarySic != null ? SicCode(secondarySic) : null,
      grade: grade != null ? Grade(grade) : null,
    );
  }

  @override
  List<Object?> get props => [
    tickerSymbol,
    companyName,
    primarySicCode,
    secondarySicCode,
    grade,
  ];
}
```

#### Shared Value Objects
**File:** `packages/zenvestor_domain/lib/src/stock/value_objects/ticker_symbol.dart`

```dart
import 'package:zenvestor_domain/shared/errors.dart';

class TickerSymbol {
  final String value;

  factory TickerSymbol(String input) {
    final trimmed = input.trim().toUpperCase();
    
    if (trimmed.isEmpty || trimmed.length > 5) {
      throw ValidationException.invalidLength(
        field: 'ticker symbol',
        min: 1,
        max: 5,
        actual: trimmed.length,
      );
    }
    
    if (!RegExp(r'^[A-Z]+$').hasMatch(trimmed)) {
      throw ValidationException.invalidFormat(
        field: 'ticker symbol',
        expected: 'letters only',
        actual: trimmed,
      );
    }
    
    return TickerSymbol._(trimmed);
  }
  
  const TickerSymbol._(this.value);
  
  @override
  String toString() => value;
}
```

### 2. Server Domain Layer (zenvestor_server)

#### YAML Structure Definition
**File:** `zenvestor_server/lib/src/domain/stock/stock.yaml`

```yaml
class: Stock
table: stocks
fields:
  symbol: String
  companyName: String
  primarySicCode: String?
  secondarySicCode: String?
  grade: String?
  createdAt: DateTime
  updatedAt: DateTime
indexes:
  symbol_index:
    fields: symbol
    unique: true
```

> **Note**: For comprehensive model definition options including relations, indices, and advanced features, see `/docs/serverpod-docs/06-concepts/02-models.md` and `/docs/serverpod-docs/06-concepts/06-database/02-models.md`

#### Server Domain Wrapper
**File:** `zenvestor_server/lib/src/domain/stock/server_stock.dart`

```dart
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;

/// Server-specific stock entity that wraps the shared domain Stock.
/// Adds infrastructure concerns like database ID and timestamps.
class ServerStock extends shared.Stock {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServerStock({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required shared.TickerSymbol tickerSymbol,
    required shared.CompanyName companyName,
    shared.SicCode? primarySicCode,
    shared.SicCode? secondarySicCode,
    shared.Grade? grade,
  }) : super(
    tickerSymbol: tickerSymbol,
    companyName: companyName,
    primarySicCode: primarySicCode,
    secondarySicCode: secondarySicCode,
    grade: grade,
  );

  /// Create from shared domain entity with infrastructure data
  factory ServerStock.fromDomain({
    required shared.Stock stock,
    required int id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return ServerStock(
      id: id,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      tickerSymbol: stock.tickerSymbol,
      companyName: stock.companyName,
      primarySicCode: stock.primarySicCode,
      secondarySicCode: stock.secondarySicCode,
      grade: stock.grade,
    );
  }

  /// Extract the shared domain entity (without infrastructure concerns)
  shared.Stock toDomain() => shared.Stock(
    tickerSymbol: tickerSymbol,
    companyName: companyName,
    primarySicCode: primarySicCode,
    secondarySicCode: secondarySicCode,
    grade: grade,
  );

  @override
  List<Object?> get props => [
    ...super.props,
    id,
    createdAt,
    updatedAt,
  ];
}
```


#### Repository Interface
**File:** `zenvestor_server/lib/src/domain/stock/repository.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;
import 'server_stock.dart';
import '../exceptions/exceptions.dart';

/// Repository interface uses server-specific domain entities
/// that include infrastructure concerns like IDs
abstract class StockRepository {
  Future<Either<DomainException, ServerStock>> create(shared.Stock stock);
  Future<Either<DomainException, ServerStock>> getById(int id);
  Future<Either<DomainException, ServerStock>> getBySymbol(String symbol);
  Future<Either<DomainException, List<ServerStock>>> getAll();
  Future<Either<DomainException, List<ServerStock>>> getBySicCode(String sicCode);
  Future<Either<DomainException, List<ServerStock>>> getByGrade(String grade);
  Future<Either<DomainException, ServerStock>> update(ServerStock stock);
  Future<Either<DomainException, void>> delete(int id);
}
```

### 3. Application Layer (zenvestor_server)

#### Use Cases

**File:** `zenvestor_server/lib/src/application/use_cases/stock/add_stock.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;
import '../../../domain/stock/server_stock.dart';
import '../../../domain/stock/repository.dart';
import '../../../domain/exceptions/exceptions.dart';

class AddStock {
  final StockRepository _repository;

  AddStock(this._repository);

  Future<Either<DomainException, ServerStock>> execute({
    required String ticker,
    required String companyName,
    String? primarySicCode,
    String? secondarySicCode,
    String? grade,
  }) async {
    try {
      // Create shared domain entity (validation happens here)
      final stock = shared.Stock.create(
        ticker: ticker,
        name: companyName,
        primarySic: primarySicCode,
        secondarySic: secondarySicCode,
        grade: grade,
      );

      // Check for duplicates
      final existingStock = await _repository.getBySymbol(ticker);
      if (existingStock.isRight()) {
        return Left(DuplicateStockException(ticker));
      }

      // Persist using repository (it will handle ServerStock wrapping)
      return await _repository.create(stock);
    } on shared.DomainException catch (e) {
      return Left(DomainException(e.message));
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

### 4. Infrastructure Layer (zenvestor_server)

#### Mapper
**File:** `zenvestor_server/lib/src/infrastructure/mappers/stock_mapper.dart`

```dart
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;
import '../../domain/stock/server_stock.dart';
// Generated code import
import '../../generated/protocol.dart' as protocol;

class StockMapper {
  /// Maps from generated DTO to server domain entity
  static ServerStock toDomain(protocol.Stock dto) {
    return ServerStock(
      id: dto.id!,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      tickerSymbol: shared.TickerSymbol(dto.symbol),
      companyName: shared.CompanyName(dto.companyName),
      primarySicCode: dto.primarySicCode != null 
        ? shared.SicCode(dto.primarySicCode!) 
        : null,
      secondarySicCode: dto.secondarySicCode != null
        ? shared.SicCode(dto.secondarySicCode!)
        : null,
      grade: dto.grade != null ? shared.Grade(dto.grade!) : null,
    );
  }

  /// Maps from server domain entity to generated DTO
  static protocol.Stock toDto(ServerStock entity) {
    return protocol.Stock(
      id: entity.id,
      symbol: entity.tickerSymbol.value,
      companyName: entity.companyName.value,
      primarySicCode: entity.primarySicCode?.value,
      secondarySicCode: entity.secondarySicCode?.value,
      grade: entity.grade?.value,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Maps from shared domain to DTO for creation (no ID yet)
  static protocol.Stock fromSharedDomain(shared.Stock stock) {
    return protocol.Stock(
      symbol: stock.tickerSymbol.value,
      companyName: stock.companyName.value,
      primarySicCode: stock.primarySicCode?.value,
      secondarySicCode: stock.secondarySicCode?.value,
      grade: stock.grade?.value,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
```

#### Repository Implementation
**File:** `zenvestor_server/lib/src/infrastructure/repositories/stock_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:serverpod/serverpod.dart';
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;
import '../../domain/stock/server_stock.dart';
import '../../domain/stock/repository.dart' as domain;
import '../../domain/exceptions/exceptions.dart';
import '../../generated/protocol.dart' as protocol;
import '../mappers/stock_mapper.dart';

class StockRepositoryImpl implements domain.StockRepository {
  final Session _session;

  StockRepositoryImpl(this._session);

  @override
  Future<Either<DomainException, ServerStock>> create(shared.Stock stock) async {
    try {
      // Convert shared domain to protocol DTO
      final dto = StockMapper.fromSharedDomain(stock);

      // Use Serverpod's generated database operations
      // See /docs/serverpod-docs/06-concepts/06-database/05-crud.md for CRUD operations
      final savedDto = await protocol.Stock.insert(_session, dto);

      // Convert back to server domain entity
      final serverStock = StockMapper.toDomain(savedDto);
      return Right(serverStock);
    } catch (e) {
      return Left(InfrastructureException('Failed to create stock: $e'));
    }
  }

  @override
  Future<Either<DomainException, ServerStock>> getBySymbol(String symbol) async {
    try {
      // Use Serverpod's generated query methods
      // See /docs/serverpod-docs/06-concepts/06-database/06-filter.md for filtering options
      final stocks = await protocol.Stock.find(
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
  Future<Either<DomainException, List<ServerStock>>> getBySicCode(String sicCode) async {
    try {
      final stocks = await protocol.Stock.find(
        _session,
        where: (t) => t.primarySicCode.equals(sicCode) | 
                     t.secondarySicCode.equals(sicCode),
      );

      final entities = stocks.map(StockMapper.toDomain).toList();
      return Right(entities);
    } catch (e) {
      return Left(InfrastructureException('Failed to fetch stocks by SIC code: $e'));
    }
  }

  @override
  Future<Either<DomainException, ServerStock>> update(ServerStock stock) async {
    try {
      final dto = StockMapper.toDto(stock);
      final updated = await protocol.Stock.update(_session, dto);
      return Right(StockMapper.toDomain(updated));
    } catch (e) {
      return Left(InfrastructureException('Failed to update stock: $e'));
    }
  }

  // Other methods follow similar pattern...
}
```

### 5. API Layer - Endpoints (zenvestor_server)

**File:** `zenvestor_server/lib/src/endpoints/stock_endpoint.dart`

```dart
import 'package:serverpod/serverpod.dart';
import '../application/use_cases/stock/add_stock.dart';
import '../application/use_cases/stock/update_stock.dart';
import '../infrastructure/repositories/stock_repository.dart';

class StockEndpoint extends Endpoint {
  Future<Map<String, dynamic>> addStock(
    Session session,
    String ticker,
    String companyName,
    String? primarySicCode,
    String? secondarySicCode,
    String? grade,
  ) async {
    try {
      // Create repository with session
      final repository = StockRepositoryImpl(session);

      // Create use case
      final useCase = AddStock(repository);

      // Execute business logic
      final result = await useCase.execute(
        ticker: ticker,
        companyName: companyName,
        primarySicCode: primarySicCode,
        secondarySicCode: secondarySicCode,
        grade: grade,
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
            'ticker': stock.tickerSymbol.value,
            'companyName': stock.companyName.value,
            'primarySicCode': stock.primarySicCode?.value,
            'secondarySicCode': stock.secondarySicCode?.value,
            'grade': stock.grade?.value,
            'createdAt': stock.createdAt.toIso8601String(),
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

  Future<Map<String, dynamic>> getStock(
    Session session,
    String ticker,
  ) async {
    try {
      final repository = StockRepositoryImpl(session);
      final result = await repository.getBySymbol(ticker);

      return result.fold(
        (failure) => {
          'success': false,
          'error': failure.message,
        },
        (stock) => {
          'success': true,
          'data': {
            'id': stock.id,
            'ticker': stock.tickerSymbol.value,
            'companyName': stock.companyName.value,
            'primarySicCode': stock.primarySicCode?.value,
            'secondarySicCode': stock.secondarySicCode?.value,
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

### Implementing a New Feature with Shared Domain

Here's how to implement a new feature using the shared domain package:

#### Step 1: Create Shared Domain Entity

First, create the domain entity in the shared package:

```bash
# Create domain folder structure in shared package
cd packages/zenvestor_domain
mkdir -p lib/src/portfolio/value_objects
```

Create `packages/zenvestor_domain/lib/src/portfolio/portfolio.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'value_objects/portfolio_name.dart';

class Portfolio extends Equatable {
  final PortfolioName name;
  final String? description;
  final double? targetAllocation;

  const Portfolio({
    required this.name,
    this.description,
    this.targetAllocation,
  });

  bool get isFullyAllocated => targetAllocation == 100.0;

  @override
  List<Object?> get props => [name, description, targetAllocation];
}
```

#### Step 2: Define Server Structure (YAML)

Create the YAML file for Serverpod persistence:

```bash
# Create domain folder structure in server
cd zenvestor_server
mkdir -p lib/src/domain/portfolio
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

#### Step 3: Generate Code

Run Serverpod generation:
```bash
cd zenvestor_server
serverpod generate
```

This creates:
- Server-side DTO in `zenvestor_server/generated/protocol/portfolio.dart`
- Client-side protocol in `zenvestor_client/lib/src/protocol/portfolio.dart`
- Database operations

#### Step 4: Create Server Domain Wrapper

Create `zenvestor_server/lib/src/domain/portfolio/server_portfolio.dart`:

```dart
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;

class ServerPortfolio extends shared.Portfolio {
  final int id;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServerPortfolio({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required shared.PortfolioName name,
    String? description,
    double? targetAllocation,
  }) : super(
    name: name,
    description: description,
    targetAllocation: targetAllocation,
  );

  shared.Portfolio toDomain() => shared.Portfolio(
    name: name,
    description: description,
    targetAllocation: targetAllocation,
  );
}
```

#### Step 5: Define Repository Interface

Create `zenvestor_server/lib/src/domain/portfolio/repository.dart`:

```dart
abstract class PortfolioRepository {
  Future<Either<DomainException, ServerPortfolio>> create(
    shared.Portfolio portfolio,
    int userId,
  );
  Future<Either<DomainException, List<ServerPortfolio>>> getByUserId(int userId);
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
Shared Domain:
1. Domain Entity → 2. Value Objects → 3. Business Logic
     ↓
Server Side:
4. YAML Definition → 5. Generate → 6. Server Wrapper
     ↓
7. Repository Interface → 8. Mapper → 9. Repository Implementation
     ↓
10. Use Cases → 11. Endpoints

Client Side:
12. API Client → 13. Client Service → 14. View Model
      ↓
15. Pages & Widgets → 16. User Interface
```

## Managing Domain Synchronization

### Best Practices

1. **Shared Domain First**: Always start with shared domain entities
2. **Co-location**: Keep YAML and server wrapper files together
3. **Naming Convention**: Use consistent naming:
   - Shared: `stock.dart` (in `zenvestor_domain`)
   - Server: `server_stock.dart` and `stock.yaml`
4. **Import Aliases**: Always use namespace aliases for clarity
5. **Testing**: Write tests for both shared domain and server wrappers

### Synchronization Checklist

When modifying a domain model:
- [ ] Update shared domain entity if business logic changes
- [ ] Update YAML file if persistence structure changes
- [ ] Run `serverpod generate` in server directory
- [ ] Update server wrapper to match both shared and YAML
- [ ] Update mapper between protocol and domain
- [ ] Update/create value objects in shared domain
- [ ] Run tests in both shared domain and server
- [ ] Update client if using shared domain directly

## Benefits of This Approach

### What We Keep from Clean Architecture
- **Domain Independence**: Business logic in shared package has no framework dependencies
- **Code Reuse**: Domain logic shared between server and Flutter
- **Testability**: Each layer can be tested in isolation
- **Flexibility**: Can change infrastructure without touching shared domain
- **Clear Boundaries**: Explicit contracts between layers

### What We Gain with Shared Domain
- **Single Source of Truth**: One place for business rules
- **Type Safety Across Projects**: Same domain types in server and client
- **Reduced Duplication**: Write validation once, use everywhere
- **Framework Agnostic**: Domain can outlive framework choices

### What We Simplify
- **No Manual DTOs**: Generated automatically from YAML
- **No Boilerplate Contracts**: Type safety through code generation
- **Focused Mappers**: Only map between protocol and domain
- **Faster Development**: Reuse domain logic across projects

### Trade-offs Accepted
- **Additional Package**: Managing a separate shared package
- **Wrapper Pattern**: Server entities wrap shared domain
- **Import Management**: Need to use namespace aliases

## Conclusion

This architecture successfully combines Clean Architecture principles with Serverpod's code generation and a shared domain package to create a powerful, pragmatic approach for Zenvestor. By separating business logic into a framework-agnostic shared package and using the wrapper pattern for infrastructure concerns, we achieve true domain independence while leveraging Serverpod's strengths.

Key takeaways:
- **Shared domain package provides framework-agnostic business logic**
- **Server wrappers add infrastructure concerns without polluting domain**
- **YAML defines persistence structure, not business rules**
- **Four-part structure maximizes code reuse and maintainability**
- **Code generation eliminates boilerplate while maintaining type safety**
- **Clear development flow from shared domain to implementation**

The result is a maintainable, testable architecture that:
- Shares business logic between server and Flutter
- Maintains clean separation of concerns
- Takes full advantage of Serverpod's code generation
- Preserves rich domain modeling and validation
- Enables independent testing of each layer

For deployment strategies and production considerations, refer to `/docs/serverpod-docs/07-deployments/` which covers various cloud platforms and deployment approaches.
