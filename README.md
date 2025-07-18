# Zenvestor

A comprehensive investment portfolio management application built with Serverpod and Flutter.

## 🚀 Getting Started

### Prerequisites

- **Dart SDK** (>= 3.0.0)
- **Flutter SDK** (>= 3.0.0)
- **Docker** and **Docker Compose**
- **Go** (for installing development tools)
- **PostgreSQL** (via Docker)

### Quick Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd zenvestor
   ```

2. **Run the development setup script**:
   ```bash
   ./scripts/setup-dev-environment.sh
   ```

   This will:
   - Install Lefthook for git hooks management
   - Configure pre-commit hooks for code quality
   - Verify your Dart and Flutter installations

3. **Start the database**:
   ```bash
   cd zenvestor_server
   docker-compose up -d
   ```

4. **Run the server**:
   ```bash
   dart bin/main.dart
   ```

5. **Run the Flutter app**:
   ```bash
   cd ../zenvestor_flutter
   flutter run
   ```

## 🏗️ Project Structure

```
zenvestor/
├── zenvestor_server/      # Serverpod backend
├── zenvestor_client/      # Generated client code (do not modify)
├── zenvestor_flutter/     # Flutter mobile/web application
├── scripts/               # Development and setup scripts
├── docs/                  # Documentation
└── lefthook.yml          # Git hooks configuration
```

## 🔧 Development

### Git Hooks

This project uses Lefthook to manage git hooks. 

**Pre-commit hooks** automatically:
1. Format code using `dart format`
2. Run static analysis (`dart analyze --fatal-infos` and `flutter analyze --fatal-infos`)

**Pre-push hooks** automatically:
1. Run all unit tests (requires database to be running)

To skip hooks in an emergency:
```bash
LEFTHOOK=0 git commit -m "message"
```

### Manual Setup (Alternative)

If you prefer to set up manually:

1. **Install Lefthook**:
   ```bash
   go install github.com/evilmartians/lefthook@latest
   ```

2. **Add Go bin to PATH**:
   Add to your shell configuration file (.bashrc, .zshrc, etc.):
   ```bash
   export PATH="$PATH:$HOME/go/bin"
   ```

3. **Install git hooks**:
   ```bash
   lefthook install
   ```

### Running Tests

- **Server tests**:
  ```bash
  cd zenvestor_server
  dart test
  ```

- **Flutter tests**:
  ```bash
  cd zenvestor_flutter
  flutter test
  ```

### Code Generation

After modifying `.yaml` protocol files:
```bash
cd zenvestor_server
serverpod generate
```

## 📋 Development Guidelines

- **Test-Driven Development**: Write tests before implementation
- **Type Safety**: All code must pass `dart analyze --fatal-infos`
- **Clean Architecture**: Maintain separation between domain and infrastructure
- **Conventional Commits**: Use format `type(scope): description`

For detailed development guidelines, see [CLAUDE.md](./CLAUDE.md).

## 📝 License

[License information here]

## 👥 Contributing

[Contributing guidelines here]# Test
