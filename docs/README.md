# Zenvestor Documentation

This directory contains all technical documentation for the Zenvestor project. Documentation is organized into categories based on purpose and permanence.

## 📁 Directory Structure

### `/development-guides/` - Permanent Development Guides
Essential guides that should always be consulted by developers. These documents define our core development practices and standards.

- **TEST_WRITING_GUIDE.md** - Comprehensive guide for writing tests using mocktail, alchemist, and domain-specific fixtures
- **ARCHITECTURE_GUIDE.md** - Clean architecture principles and patterns used throughout the project
- **COMPONENT_GUIDE.md** - Flutter component structure and best practices
- **TESTING_AND_CODE_QUALITY_STRATEGY.md** - Overall testing strategy and code quality standards

### `/feature-plans/` - Temporary Feature Implementation Plans
Step-by-step implementation guides for specific features. These are reference documents used during active development of features.

- **ADD_STOCK_IMPLEMENTATION_PLAN.md** - Detailed plan for implementing the add stock feature

### `/project-analysis/` - Project Analysis and Reports
Analysis documents and inventories that help understand the current state of the project.

- **SERVERPOD_DEMO_FILES_INVENTORY.md** - Inventory of demo files from Serverpod that may need cleanup

## 📋 Usage Guidelines

### For New Developers
1. Start by reading all documents in `/development-guides/` to understand our development approach
2. Pay special attention to `ARCHITECTURE_GUIDE.md` and `TEST_WRITING_GUIDE.md`
3. Reference these guides frequently during development

### When Implementing Features
1. Check if there's an existing implementation plan in `/feature-plans/`
2. Use the plan as a reference but adapt to current project state
3. Update or create new plans for complex features

### Contributing Documentation
- **Development Guides**: Only add/modify after team discussion. These are permanent references.
- **Feature Plans**: Create for complex features requiring step-by-step guidance. Can be archived after feature completion.
- **Project Analysis**: Add reports that help understand or improve the codebase.

## 🔗 Integration with CLAUDE.md

The root `CLAUDE.md` file references several documents here, particularly:
- `/docs/development-guides/TEST_WRITING_GUIDE.md` - Referenced for TDD practices
- Other guides may be referenced as needed

Always ensure CLAUDE.md stays synchronized with documentation structure changes.