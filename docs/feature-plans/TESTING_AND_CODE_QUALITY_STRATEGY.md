# Testing and Code Quality Strategy

## Executive Summary

This document outlines a comprehensive strategy to upgrade Zenvestor's testing and code quality infrastructure from the current basic setup to a professional-grade system that ensures code reliability, maintainability, and developer productivity. The strategy is designed to align with the TDD principles and strict type safety requirements outlined in CLAUDE.md.

## Current State Assessment

### zenvestor_server (Backend)

**Current Configuration:**
- **Linting**: `package:lints/recommended.yaml` (84 rules)
- **Custom Rules**: 
  - `unawaited_futures: true`
  - `avoid_print: true`
- **Testing**: Basic setup with `test: ^1.24.2` and `serverpod_test: 2.9.1`
- **Coverage**: Not configured
- **CI/CD**: Deployment only, no quality checks

**Gaps:**
- No strict analysis mode
- No mocking framework
- No coverage reporting
- No automated quality gates

### zenvestor_flutter (Frontend)

**Current Configuration:**
- **Linting**: `package:flutter_lints/flutter.yaml` (94 rules)
- **Testing**: Basic `flutter_test` SDK dependency
- **Coverage**: Not configured
- **Integration Tests**: Not set up
- **CI/CD**: No quality checks

**Gaps:**
- No custom lint rules
- No mocking framework
- No visual regression testing
- No integration test infrastructure

### CI/CD Pipeline

**Current State:**
- GitHub Actions for deployment (GCP/AWS)
- No testing in pipeline
- No pre-commit hooks
- No pull request quality gates

## Available Tools and Technologies

### Linting Packages Comparison

| Package | Rules | Strictness | Maintenance | Recommendation |
|---------|-------|------------|-------------|----------------|
| **lints/recommended** | 84 | Basic | Official | Current (upgrade needed) |
| **flutter_lints** | 94 | Basic | Official | Current (upgrade needed) |
| **very_good_analysis** | 188 | Very High | Active | **Recommended** |
| **pedantic** | ~60 | Medium | Google | Alternative |
| **lint** | 150+ | High | Community | Alternative |

### Testing Tools

#### Unit Testing & Mocking
- **mocktail**: Modern, type-safe mocking without code generation
- **mockito**: Traditional mocking with code generation
- **faker**: Test data generation

#### Coverage Tools
- **coverage**: Core LCOV generation
- **test_coverage**: Simplified coverage commands with HTML reports
- **codecov/coveralls**: Cloud coverage tracking

#### Flutter-Specific Testing
- **golden_toolkit**: Visual regression testing
- **integration_test**: E2E testing framework
- **patrol**: Enhanced integration testing with native interactions

#### Code Quality Analysis
- **dart_code_metrics**: Cyclomatic complexity, maintainability index
- **import_sorter**: Automated import organization
- **analyzer_plugin**: Custom rule creation

## Implementation Strategy

### Phase 1: Foundation (Week 1-2)

**1.1 Upgrade Linting Configuration**

Create standardized `analysis_options.yaml` for both projects:

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "lib/src/generated/**"
    - "test/integration/test_tools/**"
  
  errors:
    missing_required_param: error
    missing_return: error
    todo: warning
    deprecated_member_use_from_same_package: ignore

linter:
  rules:
    # Project-specific overrides
    public_member_api_docs: false  # Enable later
    sort_pub_dependencies: false
    avoid_print: true
    
    # Additional strict rules
    always_put_control_body_on_new_line: true
    always_specify_types: true
    avoid_positional_boolean_parameters: true
    prefer_single_quotes: true
    sort_constructors_first: true
```

**1.2 Add Core Testing Dependencies**

For `zenvestor_server/pubspec.yaml`:
```yaml
dev_dependencies:
  mocktail: ^1.0.0
  test_coverage: ^1.0.0
  faker: ^2.1.0
```

For `zenvestor_flutter/pubspec.yaml`:
```yaml
dev_dependencies:
  mocktail: ^1.0.0
  golden_toolkit: ^0.15.0
  integration_test:
    sdk: flutter
```

### Phase 2: Testing Infrastructure (Week 3-4)

**2.1 Configure Coverage Reporting**

Create `tool/coverage.sh`:
```bash
#!/bin/bash
# Generate coverage report for all packages

echo "Running tests with coverage..."

# Server coverage
cd zenvestor_server
dart pub global activate coverage
dart test --coverage=coverage
format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
cd ..

# Flutter coverage
cd zenvestor_flutter
flutter test --coverage
cd ..

# Generate HTML reports
genhtml zenvestor_server/coverage/lcov.info -o coverage/server
genhtml zenvestor_flutter/coverage/lcov.info -o coverage/flutter

echo "Coverage reports generated in coverage/"
```

**2.2 Set Up Integration Tests**

Create `zenvestor_flutter/integration_test/app_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zenvestor_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('full app smoke test', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Add integration test scenarios
    });
  });
}
```

### Phase 3: CI/CD Automation (Week 5-6)

**3.1 Create Comprehensive CI Pipeline**

Create `.github/workflows/ci.yml`:
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      
      - name: Install dependencies
        run: |
          cd zenvestor_server && dart pub get
          cd ../zenvestor_flutter && flutter pub get
      
      - name: Analyze server
        run: cd zenvestor_server && dart analyze --fatal-infos
      
      - name: Analyze Flutter
        run: cd zenvestor_flutter && flutter analyze --fatal-infos
      
      - name: Check formatting
        run: |
          cd zenvestor_server && dart format --set-exit-if-changed .
          cd ../zenvestor_flutter && dart format --set-exit-if-changed .

  test:
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4
      - uses: dart-lang/setup-dart@v1
      - uses: subosito/flutter-action@v2
      
      - name: Run server tests
        run: cd zenvestor_server && dart test
      
      - name: Run Flutter tests
        run: cd zenvestor_flutter && flutter test
      
      - name: Generate coverage
        run: |
          cd zenvestor_server && dart test --coverage=coverage
          cd ../zenvestor_flutter && flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./zenvestor_server/coverage/lcov.info,./zenvestor_flutter/coverage/lcov.info
```

**3.2 Add Pre-commit Hooks**

Create `.lefthook.yml`:
```yaml
pre-commit:
  parallel: true
  commands:
    analyze:
      glob: "*.dart"
      run: dart analyze --fatal-infos
    
    format:
      glob: "*.dart"
      run: dart format --set-exit-if-changed {staged_files}
    
    test:
      run: |
        cd zenvestor_server && dart test
        cd ../zenvestor_flutter && flutter test
```

### Phase 4: Advanced Tooling (Week 7-8)

**4.1 Add Code Metrics**

Add to dev_dependencies:
```yaml
dart_code_metrics: ^5.7.6
```

Create `analysis_options_metrics.yaml`:
```yaml
dart_code_metrics:
  metrics:
    cyclomatic-complexity: 20
    maximum-nesting-level: 5
    number-of-parameters: 4
    source-lines-of-code: 50
  metrics-exclude:
    - test/**
    - lib/src/generated/**
  rules:
    - avoid-nested-conditional-expressions
    - no-boolean-literal-compare
    - no-empty-block
    - prefer-trailing-comma
```

**4.2 Custom Analyzer Plugin**

For domain-specific rules, create custom analyzer plugin to enforce:
- Repository interface usage
- Clean architecture boundaries
- Use case pattern compliance

## Success Metrics

### Coverage Targets
- Initial: 60% coverage
- 3 months: 75% coverage
- 6 months: 85% coverage

### Code Quality Metrics
- Zero analyzer warnings
- Cyclomatic complexity < 10 for 90% of methods
- All PRs pass quality gates

### Developer Experience
- Pre-commit hooks catch 90% of issues
- CI feedback within 5 minutes
- Clear error messages and fix suggestions

## Team Adoption Guidelines

### Training Plan
1. Team workshop on new tools and workflows
2. Pair programming sessions for complex testing scenarios
3. Documentation of common patterns and solutions

### Gradual Rollout
1. Start with new features/files
2. Gradually update existing code during regular maintenance
3. Set aside tech debt sprints for major updates

### Support Resources
- Internal wiki with examples
- Slack channel for questions
- Regular code review sessions focusing on quality

## Configuration Templates

### Standard Test Structure
```dart
@TestOn('vm')
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements Repository {}

void main() {
  late MockRepository mockRepository;
  late UseCase useCase;

  setUp(() {
    mockRepository = MockRepository();
    useCase = UseCase(mockRepository);
  });

  tearDown(() {
    reset(mockRepository);
  });

  group('UseCase', () {
    test('should execute successfully', () async {
      // Arrange
      when(() => mockRepository.getData())
          .thenAnswer((_) async => TestData());
      
      // Act
      final result = await useCase.execute();
      
      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.getData()).called(1);
    });
  });
}
```

### Widget Test Template
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('Widget should render correctly', (tester) async {
    await tester.pumpWidgetBuilder(
      MyWidget(),
      wrapper: materialAppWrapper(
        theme: ThemeData.light(),
      ),
    );

    await screenMatchesGolden(tester, 'my_widget_light_theme');
  });
}
```

## Conclusion

This strategy provides a clear path from our current basic setup to a comprehensive testing and code quality system. By following this phased approach, we can systematically improve code quality while maintaining development velocity. The investment in tooling and processes will pay dividends in reduced bugs, easier maintenance, and faster feature development.

Regular reviews and adjustments of this strategy will ensure it continues to meet the team's evolving needs and industry best practices.