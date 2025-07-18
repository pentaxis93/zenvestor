# AI Assistant Guidelines for Zenvestor Development

## Core Development Principles

### Test-Driven Development (TDD)

- Always use the TDD approach by building comprehensive test coverage defining all expected behavior before writing implementation code.
  - Write tests first to define the expected behavior
  - The tests should fail initially - let them fail rather than skipping or commenting them out
  - Implement the minimum code necessary to make the tests pass
  - Refactor the code for clarity and maintainability while keeping tests green
  - For Flutter widgets: Write widget tests before implementing the UI
  - For Serverpod endpoints: Write integration tests before implementing the endpoint
  - **IMPORTANT**: Read and follow `/docs/TEST_WRITING_GUIDE.md` for detailed testing practices including:
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

## Serverpod-Specific Guidelines

### Project Structure

- Maintain clean separation between the three Serverpod projects:
  - `zenvestor_server/` - Backend logic only
  - `zenvestor_client/` - Generated code only (never modify)
  - `zenvestor_flutter/` - Flutter UI and client logic

### Code Generation

- Always run `serverpod generate` after modifying YAML files
- Commit both YAML changes and generated code together
- Never manually edit generated files
- If generated code doesn't compile, fix the YAML rather than the generated code

### Domain Modeling

- Keep YAML definitions and domain entities synchronized:
  1. Update YAML file first
  2. Run `serverpod generate`
  3. Update corresponding domain entity to match
  4. Update mappers if fields were added/removed
  5. Run all tests to verify

## Quality Checks

### Before Every Commit

Run ALL quality checks and fix all issues:

```bash
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

- **Server tests**: `dart test` in `zenvestor_server/`
- **Flutter unit/widget tests**: `flutter test` in `zenvestor_flutter/`
- **Integration tests**: `flutter test integration_test` in `zenvestor_flutter/`
- **Coverage**: `flutter test --coverage` then `genhtml coverage/lcov.info -o coverage/html`

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

### Bug Fixes

1. Write failing test that reproduces the bug
2. Fix the bug
3. Verify all tests pass
4. Commit with `fix(<scope>): <description>`

## Architecture-Specific Guidelines

### Clean Architecture Principles

- **Never** import infrastructure code into domain layer
- **Never** import Serverpod into domain entities
- **Always** use repository interfaces in domain layer
- **Always** map between generated DTOs and domain entities

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
