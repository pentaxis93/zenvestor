# AI Assistant Guidelines for Zenvestor Development

## Documentation Discovery

Before starting any development task, review the core project context and development guides:

### Core Documents
Start with the `/docs/core-documents/` directory to understand the project's foundation:
- **zenvestor-project-brief.md** - Read this first for high-level project context
- **zenvestor-prd.md** - Consult for detailed feature requirements and specifications
- **zenvestor-architecture.md** - Reference for technical architecture decisions
- **zenvestor-ux-spec.md** - Review for UI/UX guidelines and design patterns

### Development Guides
Then scan the `/docs/development-guides/` directory for implementation practices:
- Use the LS tool to list all files in `/docs/development-guides/`
- Review the filenames to understand what documentation is available
- Read relevant guides based on the task at hand (e.g., TEST_WRITING_GUIDE.md for testing tasks, ARCHITECTURE_GUIDE.md for architectural decisions)
- The documentation in this directory contains essential development practices that must be followed

### Serverpod Documentation
For detailed Serverpod-specific implementation guidance, reference `/docs/serverpod-docs/`:
- **Get Started** (`/01-get-started/`) - Creating endpoints, models, database operations, deployment
- **Concepts** (`/06-concepts/`) - Working with endpoints, models, database relations, authentication, testing
- **Database** (`/06-concepts/06-database/`) - CRUD operations, relations, transactions, migrations
- **Authentication** (`/06-concepts/11-authentication/`) - Setup, providers (email, Google, Apple, Firebase), custom implementations
- **Testing** (`/06-concepts/19-testing/`) - Testing strategies and best practices for Serverpod
- **Deployments** (`/07-deployments/`) - Deployment strategies for GCP, AWS, and other platforms

## Core Development Principles

### Test-Driven Development (TDD)

- Always use the TDD approach by building comprehensive test coverage defining all expected behavior before writing implementation code.
  - Write tests first to define the expected behavior
  - The tests should fail initially - let them fail rather than skipping or commenting them out
  - Implement the minimum code necessary to make the tests pass
  - Refactor the code for clarity and maintainability while keeping tests green
  - For Flutter widgets: Write widget tests before implementing the UI
  - For Serverpod endpoints: Write integration tests before implementing the endpoint
  - **IMPORTANT**: Read and follow `/docs/development-guides/TEST_WRITING_GUIDE.md` for detailed testing practices including:
    - Using mocktail for mocking dependencies
    - Using alchemist for golden testing
    - Creating domain-specific test fixtures instead of generic faker data
    - Following proper test organization and naming conventions

### Type Safety

- Full type safety is mandatory in all production code and test code
  - All code must pass Dart's strict analysis (`dart analyze --fatal-infos`) before committing
  - Use explicit type annotations rather than relying solely on type inference
  - Never use `dynamic` unless interfacing with external untyped data
  - Use sealed classes and exhaustive pattern matching where appropriate
  - For value objects: Always use factory constructors with validation

### Code Documentation

- When implementing a temporary fix or deferring a task, document it with a clear TODO or FIXME comment:
  ```dart
  // TODO: Implement pagination when we have more than 100 stocks
  // FIXME: Handle network timeout gracefully instead of showing generic error
  ```
- Document complex business logic with explanatory comments
- Use dartdoc comments (`///`) for all public APIs

## Shared Domain Package Guidelines

### Overview

The Zenvestor project uses a shared domain package (`zenvestor_domain`) that contains framework-agnostic business logic, domain entities, value objects, and error types that are shared between the server and Flutter applications.

### Package Structure

- **Location**: `/packages/zenvestor_domain/`
- **Purpose**: Single source of truth for business logic and domain modeling
- **Framework**: Completely framework-agnostic (no Serverpod or Flutter dependencies)
- **Import Convention**: Use namespace aliases for clarity
  ```dart
  import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;
  ```

### When to Use Shared Domain

Place code in the shared domain package when:
- It represents core business concepts (entities, value objects)
- It contains business validation logic
- It defines domain-specific errors
- It needs to be used by both server and Flutter projects
- It has no framework dependencies

Keep code in project-specific domain when:
- It requires framework-specific features (Serverpod Session, Flutter BuildContext)
- It contains infrastructure concerns (database IDs, timestamps)
- It's only relevant to one project

### Server Wrapper Pattern

For server-specific infrastructure concerns, use the wrapper pattern:
```dart
// In zenvestor_server/lib/src/domain/
class ServerStock extends shared.Stock {
  final int id;
  final DateTime createdAt;
  
  ServerStock({
    required this.id,
    required this.createdAt,
    required super.tickerSymbol,
    // ... other shared fields
  });
}
```

### Testing Shared Domain Code

- Tests go in `/packages/zenvestor_domain/test/`
- Use shared fixtures across projects
- Maintain 100% coverage for shared domain code
- Run tests with: `dart test` in the package directory

### Version Management

- The shared domain package has its own version in `pubspec.yaml`
- Use path dependencies for local development:
  ```yaml
  dependencies:
    zenvestor_domain:
      path: ../packages/zenvestor_domain
  ```
- Consider publishing as a separate package for production

### Import Examples

```dart
// In server code
import 'package:zenvestor_domain/zenvestor_domain.dart' as shared;

// Using shared domain types
final stock = shared.Stock(
  tickerSymbol: shared.TickerSymbol('AAPL'),
  companyName: shared.CompanyName('Apple Inc.'),
  // ...
);

// In Flutter code
import 'package:zenvestor_domain/zenvestor_domain.dart' as domain;

// Using shared value objects
final ticker = domain.TickerSymbol('GOOGL');
```

## Serverpod-Specific Guidelines

**Note**: For detailed Serverpod concepts and implementation patterns, consult `/docs/serverpod-docs/`. This documentation provides comprehensive guidance on Serverpod features, best practices, and advanced patterns.

### Project Structure

- Maintain clean separation between projects:
  - `zenvestor_server/` - Backend logic only
  - `zenvestor_client/` - Generated code only (never modify)
  - `zenvestor_flutter/` - Flutter UI and client logic
  - `packages/zenvestor_domain/` - Shared domain logic

### Code Generation

- Always run `serverpod generate` after modifying YAML files
- Commit both YAML changes and generated code together
- Never manually edit generated files
- If generated code doesn't compile, fix the YAML rather than the generated code

### Domain Modeling

- Keep YAML definitions, shared domain, and server domain synchronized:
  1. Update YAML file first
  2. Run `serverpod generate`
  3. Update shared domain entity if the change is business logic
  4. Update server domain wrapper if the change is infrastructure
  5. Update mappers between protocol models and domain entities
  6. Run all tests to verify

## Quality Checks

### Before Every Commit

Run ALL quality checks and fix all issues:

```bash
# In packages/zenvestor_domain/
dart analyze --fatal-infos
dart format .
dart test

# In zenvestor_server/
dart analyze --fatal-infos
dart format .
dart test

# In zenvestor_flutter/
flutter analyze --fatal-infos
dart format .
flutter test
```

### Testing Commands

- **Shared domain tests**: `dart test` in `packages/zenvestor_domain/`
- **Server tests**: `dart test` in `zenvestor_server/`
- **Flutter unit/widget tests**: `flutter test` in `zenvestor_flutter/`
- **Integration tests**: `flutter test integration_test` in `zenvestor_flutter/`
- **Coverage**: `flutter test --coverage` then `genhtml coverage/lcov.info -o coverage/html`
- **Find untested code**: Use `./scripts/find-untested-code.sh` to identify files and specific lines that need test coverage

### Code Formatting

- Always run `dart format .` before committing
- Use trailing commas for better formatting of Flutter widgets

## Git Commit Messages

### Conventional Commit Format

Use the conventional commit format for all commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, missing semicolons, etc.)
- **refactor**: Code changes that neither fix bugs nor add features
- **test**: Adding or updating tests
- **chore**: Changes to build process, dependencies, or tooling

### Examples

```
feat(stock): add grade indicator widget

fix(portfolio): correct allocation calculation for empty portfolios

test(stock): add unit tests for sector-industry validation

chore(deps): upgrade serverpod to 2.0.0

docs(architecture): update component guide with view model pattern
```

### Rules

- Keep subject line under 50 characters
- Use imperative mood ("add" not "added" or "adds")
- Don't capitalize first letter
- No period at the end of subject
- Separate subject from body with blank line
- Omit all references to authorship (especially AI assistants)
- Reference issue numbers in footer when applicable

## Version Management

### Dart/Flutter Version Management

Version management in Dart projects uses `pubspec.yaml`:

```yaml
name: zenvestor_server
version: 1.2.3+45  # version+buildNumber
```

### Version Increment Guidelines

- **Patch version (0.0.X)**: Bug fixes, documentation updates, minor changes
- **Minor version (0.X.0)**: New features that are backward-compatible
- **Major version (X.0.0)**: Breaking changes
  - **IMPORTANT**: Always get explicit approval before incrementing major version
  - Breaking changes include:
    - Removing or renaming API endpoints
    - Changing request/response formats
    - Modifying database schema in incompatible ways

### Version Update Process

1. Update version in all three `pubspec.yaml` files:
   - `zenvestor_server/pubspec.yaml`
   - `zenvestor_client/pubspec.yaml`
   - `zenvestor_flutter/pubspec.yaml`
2. Keep versions synchronized across all projects
3. Update CHANGELOG.md with version changes
4. Tag releases in git: `git tag v1.2.3`

## Development Workflow

### Feature Development

1. Write failing tests that define the feature
2. Implement code to make tests pass
3. Refactor for clarity
4. Run all quality checks
5. Commit with conventional commit message

### Git Commits

- **NEVER** commit changes unless explicitly requested by the user
- When asked to commit, follow the conventional commit format above

### Bug Fixes

1. Write failing test that reproduces the bug
2. Fix the bug
3. Verify all tests pass
4. Commit with `fix(<scope>): <description>`

## Architecture-Specific Guidelines

### Clean Architecture Principles

- **Never** import infrastructure code into domain layer
- **Never** import Serverpod into shared domain entities
- **Always** use repository interfaces in domain layer
- **Always** map between generated DTOs and domain entities
- **Always** keep shared domain completely framework-agnostic
- **Use** server wrappers for infrastructure concerns

### Use Case Implementation

When implementing use cases:
1. Write test defining the use case behavior
2. Create the use case class with single `execute` method
3. Inject repository interfaces, not implementations
4. Use functional error handling (Either types)
5. Keep use cases focused on single business operation

### Flutter Best Practices

- Use `const` constructors wherever possible
- Implement proper `dispose()` methods for controllers
- Use `key` parameters for widget testing
- Keep widgets small and focused
- Separate presentation logic into view models

## Prohibited Practices

- **NEVER** bypass analysis or test failures
- **NEVER** commit code that doesn't pass `dart analyze --fatal-infos`
- **NEVER** use `// ignore:` comments without team approval
- **NEVER** commit untested code
- **NEVER** mix concerns between architectural layers
- **NEVER** put business logic in widgets or endpoints

## Remember

- Code is read more often than written - optimize for readability
- Tests are documentation of intended behavior
- Type safety prevents entire classes of bugs
- Clean architecture boundaries enable team scalability
- Small, focused commits make debugging easier
