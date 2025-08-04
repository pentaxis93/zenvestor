# Shared Domain Package Integration Plan

## Overview
This document outlines the approach for integrating the zenvestor_domain shared package into the zenvestor_server backend while maintaining all existing functionality.

## Key Challenge
The server's Stock entity includes infrastructure concerns (id, createdAt, updatedAt) that aren't present in the shared domain Stock. We need to preserve these while using the shared domain logic.

## Migration Strategy

### 1. Create ServerStock Wrapper
Instead of directly replacing the server's Stock with the shared Stock, we'll create a ServerStock that:
- Wraps the shared domain Stock for business logic
- Adds infrastructure-specific fields (id, createdAt, updatedAt)
- Maintains the same public API as the current server Stock

### 2. Gradual Import Updates
Update imports in this order to minimize risk:
1. Shared error types (ValidationError hierarchy)
2. Value objects (TickerSymbol, CompanyName, etc.)
3. Stock-specific errors
4. Stock entity (through ServerStock wrapper)

### 3. Maintain Backward Compatibility
- Keep all existing public APIs unchanged
- Update StockMapper to work with ServerStock
- Ensure all tests continue to pass

## Implementation Steps

### Step 1: Add Dependency
```yaml
dependencies:
  zenvestor_domain:
    path: ../packages/zenvestor_domain
```

### Step 2: Create ServerStock Wrapper
Create `lib/src/domain/stock/server_stock.dart`:
- Wraps shared Stock for domain logic
- Adds id, createdAt, updatedAt fields
- Implements same factory methods and copyWith

### Step 3: Update Imports Gradually
1. Update error imports in application layer
2. Update value object imports in domain layer
3. Update stock error imports
4. Replace Stock with ServerStock

### Step 4: Update Infrastructure Layer
- Modify StockMapper to convert between ServerStock and Serverpod models
- Update repository implementations

### Step 5: Verify and Clean Up
- Run all tests
- Remove duplicated code only after verification
- Update documentation

## Testing Strategy
- Run tests after each import update
- Create integration tests to verify the wrapper works correctly
- Ensure no breaking changes in the public API

## Rollback Plan
If issues arise:
1. Revert pubspec.yaml change
2. Revert import changes
3. Keep ServerStock as a transitional step if needed