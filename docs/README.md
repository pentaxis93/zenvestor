# Zenvestor Documentation

This directory contains all technical documentation for the Zenvestor project. Documentation is organized into categories based on purpose and permanence.

## 📁 Directory Structure

### `/core-documents/` - Core Project Documentation
Foundational documents that define the project's vision, architecture, and specifications. These should be the primary reference for understanding the project's purpose and design.

- **zenvestor-project-brief.md** - High-level project overview and objectives
- **zenvestor-prd.md** - Product requirements document with detailed feature specifications
- **zenvestor-architecture.md** - Technical architecture and system design
- **zenvestor-ux-spec.md** - User experience specifications and design guidelines

### `/development-guides/` - Permanent Development Guides
Essential guides that should always be consulted by developers. These documents define our core development practices and standards.

- **TEST_WRITING_GUIDE.md** - Comprehensive guide for writing tests using mocktail, alchemist, and domain-specific fixtures
- **ARCHITECTURE_GUIDE.md** - Clean architecture principles and patterns used throughout the project
- **COMPONENT_GUIDE.md** - Flutter component structure and best practices
- **TESTING_AND_CODE_QUALITY_STRATEGY.md** - Overall testing strategy and code quality standards

### `/feature-plans/` - Temporary Feature Implementation Plans
Step-by-step implementation guides for specific features. These are reference documents used during active development of features.

- **ADD_STOCK_IMPLEMENTATION_PLAN.md** - Detailed plan for implementing the add stock feature

### `/serverpod-docs/` - Serverpod Official Documentation
Comprehensive Serverpod framework documentation for implementing complex features. This is the official Serverpod documentation that provides in-depth guidance on all framework capabilities.

- **Get Started** (`01-get-started/`) - Fundamentals of creating endpoints, models, and database operations
- **Concepts** (`06-concepts/`) - Core Serverpod concepts including sessions, exceptions, caching, authentication, and testing
- **Database** (`06-concepts/06-database/`) - Complete guide to database operations, relations, migrations, and transactions
- **Authentication** (`06-concepts/11-authentication/`) - Implementing authentication with various providers
- **Testing** (`06-concepts/19-testing/`) - Serverpod-specific testing patterns and best practices
- **Deployments** (`07-deployments/`) - Production deployment strategies for various cloud platforms
- **Tools** (`09-tools/`) - Development tools including Insights and LSP

### `/project-analysis/` - Project Analysis and Reports
Analysis documents and inventories that help understand the current state of the project.

- **SERVERPOD_DEMO_FILES_INVENTORY.md** - Inventory of demo files from Serverpod that may need cleanup

## 📋 Usage Guidelines

### For New Developers
1. Begin with the core documents in `/core-documents/` to understand the project vision and architecture
2. Read all documents in `/development-guides/` to understand our development approach
3. Pay special attention to `ARCHITECTURE_GUIDE.md` and `TEST_WRITING_GUIDE.md`
4. For Serverpod basics, start with `/serverpod-docs/01-get-started/` to understand endpoints, models, and database operations
5. Reference these guides frequently during development

### When Implementing Features
1. Check if there's an existing implementation plan in `/feature-plans/`
2. Use the plan as a reference but adapt to current project state
3. For Serverpod-specific features, consult `/serverpod-docs/` for detailed implementation patterns
4. Update or create new plans for complex features

### Contributing Documentation
- **Development Guides**: Only add/modify after team discussion. These are permanent references.
- **Feature Plans**: Create for complex features requiring step-by-step guidance. Can be archived after feature completion.
- **Project Analysis**: Add reports that help understand or improve the codebase.

## 🔗 Integration with CLAUDE.md

The root `CLAUDE.md` file references several documents here, particularly:
- `/docs/development-guides/TEST_WRITING_GUIDE.md` - Referenced for TDD practices
- Other guides may be referenced as needed

Always ensure CLAUDE.md stays synchronized with documentation structure changes.