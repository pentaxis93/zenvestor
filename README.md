# Zenvestor

[![Security Scan](https://github.com/pentaxis93/zenvestor/actions/workflows/security.yml/badge.svg)](https://github.com/pentaxis93/zenvestor/actions/workflows/security.yml)

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
   
   Note: The `.env` file with test passwords is already configured for local development.

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

## 🔒 Security

### Password Management

This project uses environment variables and configuration files to manage passwords:

- **Local Development**: Test passwords are provided in `.env` and `config/passwords.yaml`
- **Production**: Never use the test passwords in production environments
- **CI/CD**: Uses GitHub secrets for test passwords (no hardcoded values)

### Important Security Files

- `.env` - Contains actual passwords (gitignored)
- `.env.example` - Template for environment variables
- `config/passwords.yaml` - Serverpod password configuration (gitignored)
- `config/passwords.example.yaml` - Template for Serverpod passwords

**Never commit files containing real passwords to version control!**

### GitHub Secrets Setup (For Contributors)

If you're forking this repository or setting up CI/CD, you'll need to configure the following GitHub secrets:

1. Go to your repository's Settings → Secrets and variables → Actions
2. Add the following repository secrets:
   - `POSTGRES_TEST_PASSWORD`: Password for test PostgreSQL database
   - `REDIS_TEST_PASSWORD`: Password for test Redis instance

Or use the GitHub CLI:
```bash
gh secret set POSTGRES_TEST_PASSWORD -b "your-test-postgres-password"
gh secret set REDIS_TEST_PASSWORD -b "your-test-redis-password"
```

These are only used for running tests in CI and don't need to be highly secure.

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
