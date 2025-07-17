#!/bin/bash
# Setup script for Zenvestor development environment
# This script installs and configures all necessary tools for development

set -e

echo "🚀 Setting up Zenvestor development environment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Detect OS
OS="$(uname -s)"
ARCH="$(uname -m)"

# Check if Go is installed
if ! command -v go &> /dev/null; then
    print_error "Go is not installed. Please install Go first: https://golang.org/doc/install"
    exit 1
fi

# Install lefthook
echo "Installing lefthook..."
go install github.com/evilmartians/lefthook@latest

# Check if Go bin is in PATH
GO_BIN_PATH="$HOME/go/bin"
if [[ ":$PATH:" != *":$GO_BIN_PATH:"* ]]; then
    print_warning "Go bin directory is not in PATH"
    echo "Add the following to your shell configuration file (.bashrc, .zshrc, etc.):"
    echo ""
    echo "    export PATH=\"\$PATH:\$HOME/go/bin\""
    echo ""
    
    # Detect shell
    SHELL_NAME=$(basename "$SHELL")
    if [ "$SHELL_NAME" = "bash" ]; then
        RC_FILE="$HOME/.bashrc"
    elif [ "$SHELL_NAME" = "zsh" ]; then
        RC_FILE="$HOME/.zshrc"
    else
        RC_FILE="your shell configuration file"
    fi
    
    echo "For immediate use in this session, run:"
    echo "    export PATH=\"\$PATH:\$HOME/go/bin\""
    echo ""
    
    # Temporarily add to PATH for this script
    export PATH="$PATH:$GO_BIN_PATH"
fi

# Install git hooks via lefthook
echo "Installing git hooks..."
if lefthook install; then
    print_status "Git hooks installed successfully"
else
    print_error "Failed to install git hooks"
    exit 1
fi

# Verify installation
echo ""
echo "Verifying installation..."
if command -v lefthook &> /dev/null; then
    LEFTHOOK_VERSION=$(lefthook version)
    print_status "Lefthook installed: $LEFTHOOK_VERSION"
else
    print_warning "Lefthook installed but not in current PATH"
    print_warning "Please restart your shell or run: export PATH=\"\$PATH:\$HOME/go/bin\""
fi

# Check Dart/Flutter setup
echo ""
echo "Checking Dart and Flutter setup..."
if command -v dart &> /dev/null; then
    print_status "Dart is installed: $(dart --version 2>&1 | head -n1)"
else
    print_error "Dart is not installed. Please install Dart SDK"
fi

if command -v flutter &> /dev/null; then
    print_status "Flutter is installed: $(flutter --version | head -n1)"
else
    print_error "Flutter is not installed. Please install Flutter SDK"
fi

echo ""
echo "✅ Development environment setup complete!"
echo ""
echo "Next steps:"
echo "1. If prompted above, add Go bin to your PATH"
echo "2. Restart your terminal or source your shell configuration"
echo "3. Run 'lefthook run pre-commit' to test the hooks"
echo ""
echo "To skip hooks in an emergency: LEFTHOOK=0 git commit -m \"message\""