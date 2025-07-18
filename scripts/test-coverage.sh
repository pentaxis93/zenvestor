#!/bin/bash
# Coverage measurement script for Zenvestor

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Detect number of CPU cores for optimal concurrency
if command -v nproc >/dev/null 2>&1; then
    CORES=$(nproc)
elif command -v sysctl >/dev/null 2>&1; then
    CORES=$(sysctl -n hw.ncpu)
else
    CORES=4  # Fallback to 4 cores if detection fails
fi

# Check if lcov is installed
if ! command -v lcov &> /dev/null; then
    echo "lcov not installed"
    exit 1
fi

echo "Measuring test coverage (using $CORES cores)..."
echo ""

# Run tests in parallel
echo "Running tests in parallel..."

# Start server tests in background
(
    cd "$PROJECT_ROOT/zenvestor_server" && \
    if dart test --coverage=coverage -j $CORES >/dev/null 2>&1; then
        # Convert JSON coverage to lcov format
        dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib >/dev/null 2>&1
        # Remove generated files from coverage
        lcov --remove coverage/lcov.info 'lib/src/generated/*' -o coverage/lcov.info >/dev/null 2>&1
        server_coverage=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines" | grep -oE "[0-9]+\.[0-9]+%" | sed 's/%//' | head -1)
        echo "server:${server_coverage:-0}" > /tmp/server_coverage.tmp
    else
        echo "server:0" > /tmp/server_coverage.tmp
    fi
) &
server_pid=$!

# Start flutter tests in background
(
    cd "$PROJECT_ROOT/zenvestor_flutter" && \
    if flutter test --coverage --concurrency=$CORES >/dev/null 2>&1; then
        flutter_coverage=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines" | grep -oE "[0-9]+\.[0-9]+%" | sed 's/%//' | head -1)
        echo "flutter:${flutter_coverage:-0}" > /tmp/flutter_coverage.tmp
    else
        echo "flutter:0" > /tmp/flutter_coverage.tmp
    fi
) &
flutter_pid=$!

# Wait for both tests to complete
wait $server_pid
wait $flutter_pid

# Read results
server_coverage=$(grep "server:" /tmp/server_coverage.tmp 2>/dev/null | cut -d: -f2)
flutter_coverage=$(grep "flutter:" /tmp/flutter_coverage.tmp 2>/dev/null | cut -d: -f2)

# Clean up temp files
rm -f /tmp/server_coverage.tmp /tmp/flutter_coverage.tmp

# Set defaults if empty
server_coverage=${server_coverage:-0}
flutter_coverage=${flutter_coverage:-0}

echo "✅ Tests completed"

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