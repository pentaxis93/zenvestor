#!/bin/bash
# Debug version of coverage measurement script for Zenvestor
# This version includes diagnostic logging to identify CI issues

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

echo "=== DEBUG: Coverage measurement starting (using $CORES cores) ==="
echo "=== DEBUG: Current directory: $(pwd) ==="
echo "=== DEBUG: Project root: $PROJECT_ROOT ==="
echo ""

# Run tests in parallel
echo "Running tests in parallel..."

# Create debug log directory
DEBUG_DIR="$PROJECT_ROOT/coverage-debug-logs"
mkdir -p "$DEBUG_DIR"
echo "=== DEBUG: Log directory created at $DEBUG_DIR ==="

# Start server tests in background
(
    echo "=== DEBUG: Server coverage starting at $(date) ===" > "$DEBUG_DIR/server.log"
    cd "$PROJECT_ROOT/zenvestor_server"
    echo "=== DEBUG: Changed to directory: $(pwd) ===" >> "$DEBUG_DIR/server.log"
    
    # Generate references for all source files to ensure accurate coverage
    echo "=== DEBUG: Running dlcov gen-refs ===" >> "$DEBUG_DIR/server.log"
    dlcov gen-refs >> "$DEBUG_DIR/server.log" 2>&1
    GEN_REFS_EXIT=$?
    echo "=== DEBUG: dlcov gen-refs exit code: $GEN_REFS_EXIT ===" >> "$DEBUG_DIR/server.log"
    
    # Check if the references file was created
    if [ -f "test/dlcov_references_test.dart" ]; then
        echo "=== DEBUG: dlcov_references_test.dart created successfully ===" >> "$DEBUG_DIR/server.log"
        echo "=== DEBUG: File size: $(wc -l test/dlcov_references_test.dart) ===" >> "$DEBUG_DIR/server.log"
    else
        echo "=== DEBUG: ERROR - dlcov_references_test.dart NOT created ===" >> "$DEBUG_DIR/server.log"
    fi
    
    # Run tests with coverage using the coverage package for pure Dart projects
    echo "=== DEBUG: Running tests with coverage ===" >> "$DEBUG_DIR/server.log"
    SERVERPOD_RUN_MODE=test dart pub global run coverage:test_with_coverage \
        --package . \
        --out coverage \
        -- --concurrency=$CORES >> "$DEBUG_DIR/server.log" 2>&1
    TEST_EXIT=$?
    echo "=== DEBUG: Test exit code: $TEST_EXIT ===" >> "$DEBUG_DIR/server.log"
    
    if [ $TEST_EXIT -eq 0 ]; then
        echo "=== DEBUG: Tests passed, checking coverage ===" >> "$DEBUG_DIR/server.log"
        
        # Check if lcov.info was created
        if [ -f "coverage/lcov.info" ]; then
            echo "=== DEBUG: lcov.info exists, size: $(wc -l coverage/lcov.info) ===" >> "$DEBUG_DIR/server.log"
        else
            echo "=== DEBUG: ERROR - lcov.info NOT created ===" >> "$DEBUG_DIR/server.log"
        fi
        
        # Use dlcov to check coverage, including untested files
        echo "=== DEBUG: Running dlcov to check coverage ===" >> "$DEBUG_DIR/server.log"
        dlcov_output=$(dlcov -c 0 --include-untested-files=true \
            --exclude-suffix=".g.dart,.freezed.dart" \
            --exclude-files="*/lib/server.dart,*/lib/src/generated/*" 2>&1)
        DLCOV_EXIT=$?
        echo "=== DEBUG: dlcov exit code: $DLCOV_EXIT ===" >> "$DEBUG_DIR/server.log"
        echo "=== DEBUG: dlcov full output: ===" >> "$DEBUG_DIR/server.log"
        echo "$dlcov_output" >> "$DEBUG_DIR/server.log"
        echo "=== DEBUG: End of dlcov output ===" >> "$DEBUG_DIR/server.log"
        
        # Extract coverage percentage from dlcov output
        server_coverage=$(echo "$dlcov_output" | grep -oE "code coverage [0-9]+\.[0-9]+%" | grep -oE "[0-9]+\.[0-9]+" | head -1)
        echo "=== DEBUG: Extracted coverage: ${server_coverage:-NONE} ===" >> "$DEBUG_DIR/server.log"
        echo "server:${server_coverage:-0}" > /tmp/server_coverage.tmp
    else
        echo "=== DEBUG: Tests failed with exit code $TEST_EXIT ===" >> "$DEBUG_DIR/server.log"
        echo "server:0" > /tmp/server_coverage.tmp
    fi
    echo "=== DEBUG: Server coverage completed at $(date) ===" >> "$DEBUG_DIR/server.log"
) &
server_pid=$!

# Start flutter tests in background
(
    echo "=== DEBUG: Flutter coverage starting at $(date) ===" > "$DEBUG_DIR/flutter.log"
    cd "$PROJECT_ROOT/zenvestor_flutter"
    echo "=== DEBUG: Changed to directory: $(pwd) ===" >> "$DEBUG_DIR/flutter.log"
    
    # Generate references for all source files to ensure accurate coverage
    echo "=== DEBUG: Running dlcov gen-refs ===" >> "$DEBUG_DIR/flutter.log"
    dlcov gen-refs >> "$DEBUG_DIR/flutter.log" 2>&1
    GEN_REFS_EXIT=$?
    echo "=== DEBUG: dlcov gen-refs exit code: $GEN_REFS_EXIT ===" >> "$DEBUG_DIR/flutter.log"
    
    # Run tests with coverage
    echo "=== DEBUG: Running flutter tests with coverage ===" >> "$DEBUG_DIR/flutter.log"
    flutter test --coverage --concurrency=$CORES >> "$DEBUG_DIR/flutter.log" 2>&1
    TEST_EXIT=$?
    echo "=== DEBUG: Flutter test exit code: $TEST_EXIT ===" >> "$DEBUG_DIR/flutter.log"
    
    if [ $TEST_EXIT -eq 0 ]; then
        echo "=== DEBUG: Flutter tests passed, checking coverage ===" >> "$DEBUG_DIR/flutter.log"
        
        # Check if lcov.info was created
        if [ -f "coverage/lcov.info" ]; then
            echo "=== DEBUG: lcov.info exists, size: $(wc -l coverage/lcov.info) ===" >> "$DEBUG_DIR/flutter.log"
        else
            echo "=== DEBUG: ERROR - lcov.info NOT created ===" >> "$DEBUG_DIR/flutter.log"
        fi
        
        # Use dlcov to check coverage, including untested files
        echo "=== DEBUG: Running dlcov to check coverage ===" >> "$DEBUG_DIR/flutter.log"
        dlcov_output=$(dlcov -c 0 --include-untested-files=true --exclude-suffix=".g.dart,.freezed.dart" --exclude-files="lib/main.dart" 2>&1)
        DLCOV_EXIT=$?
        echo "=== DEBUG: dlcov exit code: $DLCOV_EXIT ===" >> "$DEBUG_DIR/flutter.log"
        echo "=== DEBUG: dlcov full output: ===" >> "$DEBUG_DIR/flutter.log"
        echo "$dlcov_output" >> "$DEBUG_DIR/flutter.log"
        echo "=== DEBUG: End of dlcov output ===" >> "$DEBUG_DIR/flutter.log"
        
        # Extract coverage percentage from dlcov output
        flutter_coverage=$(echo "$dlcov_output" | grep -oE "code coverage [0-9]+\.[0-9]+%" | grep -oE "[0-9]+\.[0-9]+" | head -1)
        echo "=== DEBUG: Extracted coverage: ${flutter_coverage:-NONE} ===" >> "$DEBUG_DIR/flutter.log"
        echo "flutter:${flutter_coverage:-0}" > /tmp/flutter_coverage.tmp
    else
        echo "=== DEBUG: Flutter tests failed with exit code $TEST_EXIT ===" >> "$DEBUG_DIR/flutter.log"
        echo "flutter:0" > /tmp/flutter_coverage.tmp
    fi
    echo "=== DEBUG: Flutter coverage completed at $(date) ===" >> "$DEBUG_DIR/flutter.log"
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

echo ""
echo "=== DEBUG: Logs saved to $DEBUG_DIR ==="
echo "=== DEBUG: Check server.log and flutter.log for details ==="