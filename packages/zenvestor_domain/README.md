# Zenvestor Domain

Shared domain layer for the Zenvestor application. This package contains the core business logic, value objects, and domain entities that are shared between the backend (Serverpod) and frontend (Flutter) applications.

## Architecture

This package follows Domain-Driven Design principles and is organized by domain concepts rather than technical layers:

```
lib/src/
├── shared/          # Cross-cutting domain concerns
│   └── errors/      # Base errors and validation interfaces
└── stock/           # Stock aggregate
    ├── stock.dart   # Core stock entity
    ├── stock_errors.dart
    └── value_objects/
```

## Features

- **Value Objects**: Immutable domain primitives with built-in validation
- **Domain Entities**: Core business objects with behavior
- **Error Handling**: Functional error handling using Either types
- **Validation**: Rich validation with descriptive error messages

## Usage

This package is used internally by:
- `zenvestor_server`: Backend Serverpod application
- `zenvestor_flutter`: Frontend Flutter application

## Development

Run tests:
```bash
dart test
```

Check code quality:
```bash
dart analyze --fatal-infos
dart format .
```