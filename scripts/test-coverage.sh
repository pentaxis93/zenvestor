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

# Check if dlcov is installed
if ! command -v dlcov &> /dev/null; then
    echo "dlcov not installed. Installing..."
    dart pub global activate dlcov >/dev/null 2>&1
    if ! command -v dlcov &> /dev/null; then
        echo "Failed to install dlcov. Please run: dart pub global activate dlcov"
        exit 1
    fi
fi

echo "Measuring test coverage (using $CORES cores)..."
echo ""

# Run tests in parallel
echo "Running tests in parallel..."

# Start server tests in background
(
    cd "$PROJECT_ROOT/zenvestor_server" && \
    # Generate references for all source files to ensure accurate coverage
    dlcov gen-refs >/dev/null 2>&1 && \
    # Run tests with coverage (use dart test for pure Dart projects)
    if SERVERPOD_RUN_MODE=test dart test --coverage=coverage --concurrency=$CORES >/dev/null 2>&1; then
        # Use dlcov to check coverage, including untested files
        # Exclude demo files that will be removed
        # Capture the output to extract the percentage
        dlcov_output=$(dlcov -c 0 --include-untested-files=true \
            --exclude-suffix=".g.dart,.freezed.dart" \
            --exclude-files="lib/src/generated/*,lib/src/birthday_reminder.dart,lib/src/web/routes/root.dart,lib/src/web/widgets/built_with_serverpod_page.dart,lib/server.dart,lib/src/greeting_endpoint.dart" 2>&1)
        # Extract coverage percentage from dlcov output
        # dlcov outputs: "[SUCCESS]: The total code coverage X%"
        server_coverage=$(echo "$dlcov_output" | grep -oE "code coverage [0-9]+\.[0-9]+%" | grep -oE "[0-9]+\.[0-9]+" | head -1)
        echo "server:${server_coverage:-0}" > /tmp/server_coverage.tmp
    else
        echo "server:0" > /tmp/server_coverage.tmp
    fi
) &
server_pid=$!

# Start flutter tests in background
(
    cd "$PROJECT_ROOT/zenvestor_flutter" && \
    # Generate references for all source files to ensure accurate coverage
    dlcov gen-refs >/dev/null 2>&1 && \
    # Run tests with coverage
    if flutter test --coverage --concurrency=$CORES >/dev/null 2>&1; then
        # Use dlcov to check coverage, including untested files
        # Exclude main.dart and generated files
        dlcov_output=$(dlcov -c 0 --include-untested-files=true --exclude-suffix=".g.dart,.freezed.dart" --exclude-files="lib/main.dart" 2>&1)
        # Extract coverage percentage from dlcov output
        # dlcov outputs: "[SUCCESS]: The total code coverage X%"
        flutter_coverage=$(echo "$dlcov_output" | grep -oE "code coverage [0-9]+\.[0-9]+%" | grep -oE "[0-9]+\.[0-9]+" | head -1)
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

# Output results
echo "Server:  ${server_coverage}%"
echo "Flutter: ${flutter_coverage}%"