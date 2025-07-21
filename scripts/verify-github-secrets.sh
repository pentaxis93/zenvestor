#!/bin/bash
# Script to verify GitHub secrets are properly configured

echo "Checking GitHub secrets configuration..."
echo

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub"
    echo "Please run: gh auth login"
    exit 1
fi

# Check for required secrets
echo "Checking for required secrets..."
secrets=$(gh secret list | awk '{print $1}')

required_secrets=("POSTGRES_TEST_PASSWORD" "REDIS_TEST_PASSWORD")
missing_secrets=()

for secret in "${required_secrets[@]}"; do
    if echo "$secrets" | grep -q "^$secret$"; then
        echo "✅ $secret is configured"
    else
        echo "❌ $secret is missing"
        missing_secrets+=("$secret")
    fi
done

echo

if [ ${#missing_secrets[@]} -eq 0 ]; then
    echo "✅ All required GitHub secrets are configured!"
else
    echo "❌ Missing secrets: ${missing_secrets[*]}"
    echo
    echo "To add missing secrets, run:"
    for secret in "${missing_secrets[@]}"; do
        echo "  gh secret set $secret -b \"your-password-here\""
    done
    exit 1
fi