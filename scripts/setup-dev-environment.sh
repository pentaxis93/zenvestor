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

# Install security tools
echo ""
echo "Installing security tools..."

# Install Trivy
echo "Installing Trivy..."
if [ "$OS" = "Linux" ]; then
    # Install via apt repository for Debian/Ubuntu
    if command -v apt-get &> /dev/null; then
        # Add Trivy repository
        sudo apt-get update
        sudo apt-get install -y wget apt-transport-https gnupg lsb-release
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
        echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
        sudo apt-get update
        sudo apt-get install -y trivy
    else
        # Generic Linux installation
        print_warning "Installing Trivy via binary download..."
        TRIVY_VERSION=$(curl -s "https://api.github.com/repos/aquasecurity/trivy/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
        wget -O trivy.tar.gz "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"
        tar zxvf trivy.tar.gz
        sudo mv trivy /usr/local/bin/
        rm trivy.tar.gz
    fi
fi

# Verify Trivy installation
if command -v trivy &> /dev/null; then
    print_status "Trivy installed: $(trivy --version | head -n1)"
else
    print_error "Failed to install Trivy"
fi

# Install Semgrep
echo "Installing Semgrep..."
if command -v pip3 &> /dev/null; then
    pip3 install semgrep
    print_status "Semgrep installed via pip3"
elif command -v pip &> /dev/null; then
    pip install semgrep
    print_status "Semgrep installed via pip"
else
    print_error "pip/pip3 not found. Please install Python pip to install Semgrep"
    print_warning "You can install pip with: sudo apt-get install python3-pip"
fi

# Verify Semgrep installation
if command -v semgrep &> /dev/null; then
    print_status "Semgrep installed: $(semgrep --version)"
else
    print_error "Failed to install Semgrep"
    print_warning "Make sure Python pip is installed and ~/.local/bin is in your PATH"
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