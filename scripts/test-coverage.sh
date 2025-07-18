#!/bin/bash
# Coverage measurement script for Zenvestor

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Check if lcov is installed
if ! command -v lcov &> /dev/null; then
    echo "lcov not installed"
    exit 1
fi

echo "Measuring test coverage..."
echo ""

# Get server coverage
echo -n "Running server tests... "
cd "$PROJECT_ROOT/zenvestor_server" && \
if dart test --coverage=coverage >/dev/null 2>&1; then
    echo -n "converting coverage data... "
    # Convert JSON coverage to lcov format
    dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib >/dev/null 2>&1
    # Remove generated files from coverage
    lcov --remove coverage/lcov.info 'lib/src/generated/*' -o coverage/lcov.info >/dev/null 2>&1
    server_coverage=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines" | grep -oE "[0-9]+\.[0-9]+%" | sed 's/%//' | head -1)
    echo "done"
else
    server_coverage="0"
    echo "failed"
fi
server_coverage=${server_coverage:-0}

# Get flutter coverage  
echo -n "Running Flutter tests... "
cd "$PROJECT_ROOT/zenvestor_flutter" && \
if flutter test --coverage >/dev/null 2>&1; then
    flutter_coverage=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines" | grep -oE "[0-9]+\.[0-9]+%" | sed 's/%//' | head -1)
    echo "done"
else
    flutter_coverage="0"
    echo "failed"
fi
flutter_coverage=${flutter_coverage:-0}

echo ""
echo "Coverage threshold: 45%"
echo ""

# Output results with pass/fail indicators
echo -n "Server:  ${server_coverage}% "
if (( $(echo "$server_coverage < 45" | bc -l) )); then
    echo "❌"
    server_pass=0
else
    echo "✅"
    server_pass=1
fi

echo -n "Flutter: ${flutter_coverage}% "
if (( $(echo "$flutter_coverage < 45" | bc -l) )); then
    echo "❌"
    flutter_pass=0
else
    echo "✅"
    flutter_pass=1
fi

# Exit with error if either fails (matching lefthook behavior)
if [ $server_pass -eq 0 ] || [ $flutter_pass -eq 0 ]; then
    exit 1
fi