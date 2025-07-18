# Security Scanning Implementation Plan

## Overview

This plan outlines the implementation of comprehensive security scanning for the Zenvestor project. The security scanning infrastructure will detect vulnerabilities in dependencies, hardcoded secrets, container images, and code patterns across both the Dart/Flutter frontend and Serverpod backend.

### Goals
- Detect and prevent security vulnerabilities before they reach production
- Automate security checks in CI/CD pipeline
- Provide developers with early feedback on security issues
- Maintain compliance with security best practices

### Benefits
- **Proactive Security**: Catch vulnerabilities before deployment
- **Developer Confidence**: Clear security feedback during development
- **Automated Compliance**: Continuous security validation
- **Reduced Risk**: Minimize exposure to known vulnerabilities

## Prerequisites

Before implementing security scanning, ensure:

1. **GitHub Repository Settings**
   - Admin access to repository settings
   - Ability to configure GitHub Actions
   - Access to create repository secrets

2. **Docker** (for local secret scanning)
   - Docker installed locally for developers
   - Docker available in CI environment

3. **Development Environment**
   - Existing CI pipeline (already in place)
   - Git hooks configured via Lefthook (already in place)

## Step-by-Step Implementation

### Step 1: Create Security Workflow File

Create a new GitHub Actions workflow for security scanning.

**File**: `.github/workflows/security.yml`

```yaml
name: Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ '**' ]
  schedule:
    # Run weekly on Mondays at 9 AM UTC
    - cron: '0 9 * * 1'
  workflow_dispatch:  # Allow manual trigger

# Cancel in-progress runs when a new run is triggered
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  security-scan:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for better secret detection

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'

      - name: Setup Dart
        uses: dart-lang/setup-dart@v1
        with:
          sdk: stable
```

**Expected Outcome**: Basic security workflow structure created

### Step 2: Add Dependency Vulnerability Scanning

Add dependency scanning to the security workflow.

**Update**: `.github/workflows/security.yml` (add to steps section)

```yaml
      # Dependency Vulnerability Scanning
      - name: Install dependencies
        run: |
          cd zenvestor_server && dart pub get
          cd ../zenvestor_flutter && flutter pub get

      - name: Check for vulnerable dependencies
        id: dep-scan
        run: |
          echo "🔍 Checking for vulnerable dependencies..."
          
          # Check server dependencies
          cd zenvestor_server
          dart pub outdated --json > ../server-deps.json
          
          # Check Flutter dependencies
          cd ../zenvestor_flutter
          flutter pub outdated --json > ../flutter-deps.json
          
          # Parse results (basic check - enhance as needed)
          cd ..
          if grep -q '"isDiscontinued": true' server-deps.json flutter-deps.json; then
            echo "⚠️ Found discontinued packages"
            echo "discontinued_found=true" >> $GITHUB_OUTPUT
          fi

      - name: Activate and run pana
        run: |
          dart pub global activate pana
          export PATH="$PATH:$HOME/.pub-cache/bin"
          
          echo "📊 Running pana analysis on server..."
          cd zenvestor_server
          pana --no-warning --json > ../server-pana.json || true
          
          echo "📊 Running pana analysis on Flutter..."
          cd ../zenvestor_flutter
          pana --no-warning --json > ../flutter-pana.json || true
          
          # Check scores and fail if below threshold
          cd ..
          server_score=$(jq -r '.scores.grantedPoints' server-pana.json)
          flutter_score=$(jq -r '.scores.grantedPoints' flutter-pana.json)
          
          echo "Server pana score: $server_score"
          echo "Flutter pana score: $flutter_score"
```

**Expected Outcome**: Dependency scanning integrated with pub outdated and pana

### Step 3: Add Secret Detection with Gitleaks

Add secret scanning to prevent hardcoded credentials.

**Update**: `.github/workflows/security.yml` (add to steps section)

```yaml
      # Secret Detection
      - name: Run Gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITLEAKS_ENABLE_UPLOAD_ARTIFACT: false
          GITLEAKS_ENABLE_SUMMARY: true
```

**Expected Outcome**: Automated secret scanning on every PR and push

### Step 4: Add Container and Filesystem Scanning with Trivy

Add comprehensive vulnerability scanning for the entire codebase.

**Update**: `.github/workflows/security.yml` (add to steps section)

```yaml
      # Trivy Security Scanning
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH,MEDIUM'
          ignore-unfixed: true

      - name: Upload Trivy results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v3
        if: always()  # Upload even if scan finds issues
        with:
          sarif_file: 'trivy-results.sarif'
          category: 'trivy'
```

**Expected Outcome**: Filesystem scanning with results visible in GitHub Security tab

### Step 5: Add SAST with Semgrep

Add static application security testing for code patterns.

**Update**: `.github/workflows/security.yml` (add to steps section)

```yaml
      # SAST with Semgrep
      - name: Run Semgrep
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/security-audit
            p/secrets
            p/owasp-top-ten
          generateSarif: true

      - name: Upload Semgrep results
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: semgrep.sarif
          category: 'semgrep'
```

**Expected Outcome**: Code pattern security analysis with OWASP coverage

### Step 6: Add Security Status Check

Add a final step to determine overall security status.

**Update**: `.github/workflows/security.yml` (add to steps section)

```yaml
      # Security Status Summary
      - name: Security scan summary
        if: always()
        run: |
          echo "🔐 Security Scan Summary"
          echo "========================"
          
          # Check if any critical issues were found
          if [ -f trivy-results.sarif ]; then
            critical_count=$(jq '[.runs[].results[].level | select(. == "error")] | length' trivy-results.sarif)
            echo "Critical vulnerabilities: $critical_count"
            
            if [ "$critical_count" -gt "0" ]; then
              echo "❌ Critical security issues found!"
              exit 1
            fi
          fi
          
          echo "✅ Security scan completed"
```

**Expected Outcome**: Clear pass/fail status for security checks

### Step 7: Update CI Workflow to Include Security

Modify the existing CI workflow to require security checks.

**Update**: `.github/workflows/ci.yml` (add to the workflow)

```yaml
  # Add this job to make security scan required
  security-check:
    uses: ./.github/workflows/security.yml
    secrets: inherit
```

**Expected Outcome**: Security scanning becomes a required check for PRs

### Step 8: Add Local Pre-commit Secret Detection

Update Lefthook configuration for local secret scanning.

**Update**: `lefthook.yml` (add to pre-commit commands)

```yaml
    # Add this command after format-all
    detect-secrets:
      run: |
        echo "🔐 Scanning for secrets..."
        if command -v docker &> /dev/null; then
          docker run --rm -v "$PWD:/src" zricethezav/gitleaks:latest detect --source="/src" --no-git --verbose || {
            echo "❌ Potential secrets detected! Please review and remove them."
            echo "💡 Tip: Use environment variables or secure vaults for sensitive data."
            exit 1
          }
        else
          echo "⚠️ Docker not found. Skipping local secret scan."
          echo "💡 Install Docker to enable local secret detection."
        fi
      skip:
        - merge
        - rebase
```

**Expected Outcome**: Developers get immediate feedback on potential secrets before commit

### Step 9: Configure Dependabot

Create Dependabot configuration for automated dependency updates.

**File**: `.github/dependabot.yml`

```yaml
version: 2
updates:
  # Dart dependencies for server
  - package-ecosystem: "pub"
    directory: "/zenvestor_server"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
    open-pull-requests-limit: 5
    labels:
      - "dependencies"
      - "security"
    commit-message:
      prefix: "chore"
      prefix-development: "chore"
      include: "scope"

  # Flutter dependencies
  - package-ecosystem: "pub"
    directory: "/zenvestor_flutter"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
    open-pull-requests-limit: 5
    labels:
      - "dependencies"
      - "security"
    commit-message:
      prefix: "chore"
      prefix-development: "chore"
      include: "scope"

  # GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
    open-pull-requests-limit: 5
    labels:
      - "dependencies"
      - "github-actions"
    commit-message:
      prefix: "ci"
      include: "scope"
```

**Expected Outcome**: Automated PRs for dependency updates with security fixes

### Step 10: Add Security Badge to README

Add a security scan status badge to show current security status.

**Update**: `README.md` (add near other badges)

```markdown
[![Security Scan](https://github.com/YOUR_ORG/zenvestor/actions/workflows/security.yml/badge.svg)](https://github.com/YOUR_ORG/zenvestor/security)
```

**Expected Outcome**: Visible security status on repository homepage

## Testing and Verification

### Verify Each Component

1. **Test Secret Detection**
   ```bash
   # Create a test file with a fake secret
   echo "aws_secret_key = 'AKIAIOSFODNN7EXAMPLE'" > test-secret.txt
   git add test-secret.txt
   git commit -m "test: verify secret detection"
   # Should be blocked by pre-commit hook
   ```

2. **Test Dependency Scanning**
   ```bash
   # Trigger security workflow manually
   # Go to Actions tab > Security Scan > Run workflow
   ```

3. **Verify SARIF Upload**
   - Check GitHub Security tab after workflow completes
   - Should see results from Trivy and Semgrep

4. **Test PR Blocking**
   - Create PR with known security issue
   - Verify security check blocks merge

### Integration Testing

1. **Full Pipeline Test**
   - Make a change that triggers all scanners
   - Verify all checks run in parallel
   - Confirm results appear in PR checks

2. **Performance Validation**
   - Security scan should complete within 5-10 minutes
   - Should not significantly impact CI total time

## Maintenance Guidelines

### Regular Updates

1. **Weekly Tasks**
   - Review Dependabot PRs
   - Check for new security advisories
   - Update security tool versions

2. **Monthly Tasks**
   - Review security scan findings
   - Update scanning rules/configs
   - Audit false positives

3. **Quarterly Tasks**
   - Review and update security thresholds
   - Evaluate new security tools
   - Security training for team

### Configuration Management

1. **Scanner Configuration Files**
   - `.gitleaks.toml` - Customize secret patterns
   - `.trivyignore` - Suppress false positives
   - `.semgrep.yml` - Custom rules

2. **Threshold Adjustments**
   - Start with CRITICAL/HIGH blocking
   - Gradually increase strictness
   - Document exceptions

## Troubleshooting

### Common Issues and Solutions

1. **False Positives in Secret Detection**
   ```yaml
   # Create .gitleaks.toml
   [allowlist]
   paths = [
     "docs/examples/.*",
     ".*_test\\.dart$"
   ]
   ```

2. **Dependency Conflicts**
   - Use `dependency_overrides` carefully
   - Document why override is needed
   - Set reminder to remove override

3. **Scanner Timeouts**
   - Increase timeout in workflow
   - Use scan path filtering
   - Cache scanner databases

4. **SARIF Upload Failures**
   ```yaml
   # Add retry logic
   - name: Upload results with retry
     uses: github/codeql-action/upload-sarif@v3
     with:
       sarif_file: results.sarif
     continue-on-error: true
     id: upload
   
   - name: Retry upload if failed
     if: steps.upload.outcome == 'failure'
     uses: github/codeql-action/upload-sarif@v3
     with:
       sarif_file: results.sarif
   ```

### Getting Help

1. **Tool Documentation**
   - [Gitleaks Docs](https://github.com/gitleaks/gitleaks)
   - [Trivy Docs](https://aquasecurity.github.io/trivy)
   - [Semgrep Docs](https://semgrep.dev/docs)

2. **GitHub Security**
   - [GitHub Security Features](https://docs.github.com/en/code-security)
   - [Dependabot Configuration](https://docs.github.com/en/code-security/dependabot)

## Summary

This implementation plan provides comprehensive security scanning for the Zenvestor project. Following these steps will establish:

- Automated vulnerability detection
- Secret scanning prevention  
- Dependency security updates
- Code security analysis
- Developer-friendly feedback

The security infrastructure will integrate seamlessly with existing CI/CD pipelines while maintaining high development velocity.