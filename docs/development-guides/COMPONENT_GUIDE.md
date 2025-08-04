# Zenvestor Component Guide: Understanding Each Layer

## Overview

This guide explains the purpose and responsibility of each component in Zenvestor's clean architecture. Zenvestor uses a four-part structure: a shared domain package for framework-agnostic business logic, plus Serverpod's three-project structure (server, client, flutter), with each project serving a specific purpose in the overall architecture.

## Shared Domain Package Components

### Core Domain Layer

The shared domain package (`packages/zenvestor_domain`) contains framework-agnostic business logic that is shared between server and Flutter applications.

#### Domain Entities (`stock.dart`)
- **Purpose**: Define core business concepts without infrastructure concerns
- **Responsibility**:
  - Encapsulate business logic and validation
  - Provide framework-agnostic implementation
  - Define business operations and rules
- **Example Use**: `Stock.create()` factory with business validation
- **Key Principle**: No dependencies on Serverpod, Flutter, or any framework

#### Value Objects (`ticker_symbol.dart`, `grade.dart`)
- **Purpose**: Represent immutable domain concepts with validation
- **Responsibility**:
  - Enforce validation rules at construction
  - Provide type-safe domain primitives
  - Throw domain-specific exceptions
- **Example Use**: `TickerSymbol` ensures valid ticker format
- **Key Principle**: Make invalid states unrepresentable

#### Domain Errors (`stock_errors.dart`, `validation_errors.dart`)
- **Purpose**: Define domain-specific exceptions and error types
- **Responsibility**:
  - Provide rich error information
  - Support functional error handling
  - Enable consistent error handling across projects
- **Example Use**: `ValidationException.invalidLength()` with detailed context
- **Key Principle**: Errors are part of the domain model

## Server-Side Components

### Server Domain Layer

The server domain layer extends the shared domain with infrastructure concerns specific to the backend.

#### YAML Files (`stock.yaml`)
- **Purpose**: Define the persistent structure for Serverpod database models
- **Responsibility**: Specify database fields, types, and constraints
- **Example Use**: Declaring database fields like id, createdAt, updatedAt
- **Key Principle**: Infrastructure-specific persistence definitions

#### Server Domain Wrappers (`server_stock.dart`)
- **Purpose**: Extend shared domain entities with infrastructure concerns
- **Responsibility**:
  - Add database IDs and timestamps
  - Wrap shared domain entities
  - Provide conversion to/from shared domain
- **Example Use**: `ServerStock` extends `shared.Stock` with id and timestamps
- **Key Principle**: Keep infrastructure concerns separate from business logic

#### Repository Interfaces (`repository.dart`)
- **Purpose**: Define contracts for data persistence without implementation details
- **Responsibility**:
  - Declare available persistence operations
  - Use server domain wrappers (with IDs)
  - Accept shared domain entities for creation
  - Use functional error handling (Either types)
- **Example Use**: `Future<Either<DomainException, ServerStock>> create(shared.Stock stock)`
- **Key Principle**: Repository interfaces bridge shared and server domains

### Application Layer

The application layer orchestrates domain logic to fulfill use cases.

#### Use Cases (`add_stock.dart`, `update_stock.dart`)
- **Purpose**: Implement specific business operations/workflows
- **Responsibility**:
  - Coordinate domain entities and repositories
  - Enforce business rules that span multiple entities
  - Handle transaction boundaries
- **Example Use**: Check for duplicate stocks before creating a new one
- **Key Principle**: One class per use case, single responsibility

#### Application Services (`stock_service.dart`)
- **Purpose**: Provide higher-level orchestration when multiple use cases need coordination
- **Responsibility**:
  - Group related use cases
  - Provide a simplified interface for complex operations
  - Handle cross-cutting concerns at the application level
- **Example Use**: Coordinating stock creation with portfolio updates
- **Key Principle**: Optional layer - only create when you need to orchestrate multiple use cases

### Infrastructure Layer

The infrastructure layer implements the interfaces defined by the domain.

#### Repository Implementations (`stock_repository.dart`)
- **Purpose**: Implement domain repository interfaces using Serverpod
- **Responsibility**:
  - Translate between domain entities and Serverpod DTOs
  - Execute database operations using Serverpod's generated methods
  - Handle infrastructure-specific errors
- **Example Use**: Using `generated.Stock.find()` to implement `getBySymbol()`
- **Key Principle**: Depends on domain interfaces, not the other way around

#### Mappers (`stock_mapper.dart`)
- **Purpose**: Convert between layers (protocol ↔ server domain ↔ shared domain)
- **Responsibility**:
  - Map Serverpod protocol DTOs to server domain wrappers
  - Convert between server wrappers and shared domain
  - Handle value object creation during mapping
  - Manage nullable field conversions
- **Example Use**: 
  - `toDomain(protocol.Stock)` → `ServerStock`
  - `toDto(ServerStock)` → `protocol.Stock`
  - `fromSharedDomain(shared.Stock)` → `protocol.Stock`
- **Key Principle**: Mappers handle all layer translations in one place

### API Layer (Endpoints)

#### Endpoints (`stock_endpoint.dart`)
- **Purpose**: Expose business operations as API endpoints
- **Responsibility**:
  - Handle HTTP request/response cycle
  - Wire up dependencies (repositories, use cases)
  - Transform results to API-friendly formats
  - Handle authentication/authorization
- **Example Use**: `addStock` endpoint that accepts parameters and returns JSON
- **Key Principle**: Thin layer - delegate business logic to use cases

## Client-Side Components

### Presentation Layer

The presentation layer handles all UI concerns and user interactions.

#### Pages (`stock_list_page.dart`, `add_stock_page.dart`)
- **Purpose**: Full-screen UI components representing distinct user workflows
- **Responsibility**:
  - Compose widgets into complete screens
  - Connect to view models for state management
  - Handle navigation between screens
  - Manage page-level lifecycle
- **Example Use**: Stock list page showing all stocks with search/filter
- **Key Principle**: Pages are dumb - they observe view models and render UI

#### Widgets (`stock_card.dart`, `grade_indicator.dart`)
- **Purpose**: Reusable UI components
- **Responsibility**:
  - Render specific UI elements
  - Handle local UI state (animations, form validation)
  - Emit events for user interactions
- **Example Use**: `StockCard` widget displaying stock summary in a list
- **Key Principle**: Keep widgets focused and reusable

#### View Models (`stock_list_view_model.dart`)
- **Purpose**: Manage presentation state and coordinate with services
- **Responsibility**:
  - Hold UI state (loading, error, data)
  - Call client services to fetch/update data
  - Transform data for optimal UI consumption
  - Implement presentation logic (sorting, filtering)
- **Example Use**: `StockListViewModel` managing paginated stock list with filters
- **Key Principle**: View models are the brain of the UI - pages are just the face

#### State Management (`stock_state.dart`)
- **Purpose**: Define the state structure for complex UI flows
- **Responsibility**:
  - Model all possible UI states (loading, success, error)
  - Provide immutable state objects
  - Support state transitions
- **Example Use**: `StockListState` with variants for empty, loading, loaded, error
- **Key Principle**: Make UI state explicit and type-safe

### Client Application Layer

#### Client Services (`stock_service.dart`)
- **Purpose**: Orchestrate API calls and client-side business logic
- **Responsibility**:
  - Coordinate multiple API calls
  - Implement client-side caching strategies
  - Handle retry logic and error recovery
  - Transform API responses for UI consumption
- **Example Use**: Fetching stocks with local cache fallback
- **Key Principle**: Shield presentation layer from infrastructure details

#### UI Mappers (`stock_ui_mapper.dart`)
- **Purpose**: Transform API models to UI-optimized models
- **Responsibility**:
  - Convert protocol models to UI models
  - Format data for display (dates, numbers, currencies)
  - Compute derived UI properties
- **Example Use**: Converting `Stock` protocol to `StockDisplayModel` with formatted price
- **Key Principle**: Separate API structure from UI needs

### Client Infrastructure Layer

#### API Clients (`stock_api_client.dart`)
- **Purpose**: Handle low-level API communication
- **Responsibility**:
  - Make HTTP calls using Serverpod client
  - Handle connection errors and retries
  - Manage authentication tokens
  - Serialize/deserialize requests and responses
- **Example Use**: Wrapping Serverpod's generated client with error handling
- **Key Principle**: Isolate Serverpod client usage to this layer

## Component Interaction Patterns

### Server-Side Flow
```
Endpoint → Use Case → Repository Interface → Server Domain Wrapper
                ↓                                    ↓
         Infrastructure Repository          Shared Domain Entity
                ↓
            Mapper → Protocol DTO → Database
```

### Client-Side Flow
```
Page → View Model → Client Service → API Client → Server Endpoint
  ↑         ↓              ↓
Widget    State    (optional) Shared Domain
```

### Cross-Layer Mapping
```
Shared Domain ← → Server Domain Wrapper ← → Protocol DTO ← → Database
     ↑                                                           ↓
  Flutter App                                              Serverpod ORM
```

### Key Principles Across All Components

1. **Dependency Direction**: Always point inward (infrastructure → application → domain)
2. **Single Responsibility**: Each component does one thing well
3. **Interface Segregation**: Depend on interfaces, not implementations
4. **Business Focus**: Names reflect business concepts, not technical details
5. **Testability**: Each component can be tested in isolation

## When to Create Each Component

### Always Create
- Shared domain entity (when you have a business concept)
- Server domain wrapper (when entity needs persistence)
- YAML file (for Serverpod database model)
- Repository interface (when entity needs persistence)
- Repository implementation (to fulfill the interface)
- Mapper (to convert between all layers)
- At least one use case (to implement business operations)
- Endpoint (to expose operations via API)
- Page and view model (for each user workflow)

### Create When Needed
- Value objects in shared domain (when you have constrained values)
- Domain errors (for rich error handling)
- Application services (when orchestrating multiple use cases)
- Client services (when coordinating multiple API calls)
- Reusable widgets (when UI patterns repeat)
- State classes (for complex UI state management)
- UI mappers (when API models don't match UI needs)

## Common Mistakes to Avoid

1. **Putting business logic in endpoints**: Use cases should contain business logic
2. **Adding framework dependencies to shared domain**: Keep it framework-agnostic
3. **Forgetting to use namespace aliases**: Always import shared domain with `as shared`
4. **Mixing infrastructure concerns in shared domain**: Use server wrappers instead
5. **Coupling domain to infrastructure**: Shared domain should never import Serverpod
6. **Fat view models**: Keep presentation logic separate from business logic
7. **Skipping mappers**: Always map between layers to maintain boundaries
8. **Overusing application services**: Only create when truly needed for orchestration

## Conclusion

Each component in our architecture has a specific purpose and set of responsibilities. By understanding and respecting these boundaries, we create a system that is:
- **Maintainable**: Changes are localized to appropriate components
- **Reusable**: Shared domain logic works in both server and Flutter
- **Testable**: Each component can be tested independently
- **Scalable**: New features follow established patterns
- **Understandable**: Clear separation of concerns

Key architecture decisions:
- **Shared domain package** for framework-agnostic business logic
- **Server wrappers** to add infrastructure concerns
- **Clean mapping** between all layers
- **Consistent patterns** across the entire codebase

Remember: When in doubt about where code belongs, ask:
1. "Is this business logic?" → Shared domain
2. "Is this infrastructure?" → Server wrapper or infrastructure layer
3. "What is this code's primary concern?" → Place in appropriate layer
