#!/bin/bash
# Find untested code in Zenvestor projects
# Shows all files with untested lines and their coverage

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

# Option to show only summary
SHOW_LINES=${1:-yes}  # Show untested lines by default

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Finding untested code (using $CORES cores for tests)..."
echo ""

# Function to analyze coverage for a project
analyze_project_coverage() {
    local project=$1
    local project_path="$PROJECT_ROOT/$project"
    
    if [ ! -d "$project_path" ]; then
        return
    fi
    
    cd "$project_path"
    
    # Run tests if no coverage data exists
    if [ ! -f "coverage/lcov.info" ]; then
        echo "No coverage data for $project. Running tests..."
        if [ "$project" = "zenvestor_server" ]; then
            dart test --coverage=coverage -j $CORES >/dev/null 2>&1
            dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib >/dev/null 2>&1
            lcov --remove coverage/lcov.info 'lib/src/generated/*' -o coverage/lcov.info >/dev/null 2>&1
        else
            flutter test --coverage --concurrency=$CORES >/dev/null 2>&1
        fi
        
        if [ ! -f "coverage/lcov.info" ]; then
            echo "Failed to generate coverage data for $project"
            return
        fi
    fi
    
    echo -e "${GREEN}=== $project ===${NC}"
    echo ""
    
    # Parse lcov.info to find files with untested code
    current_file=""
    current_source_file=""
    lines_hit=0
    lines_total=0
    declare -a uncovered_lines=()
    files_with_untested=0
    total_files=0
    
    while IFS= read -r line; do
        if [[ $line == SF:* ]]; then
            # Process previous file if exists
            if [ -n "$current_file" ] && [ $lines_total -gt 0 ]; then
                # Skip generated files
                if [[ ! "$current_file" =~ generated/ ]]; then
                    total_files=$((total_files + 1))
                    coverage=$(echo "scale=1; $lines_hit * 100 / $lines_total" | bc)
                    
                    # Show file if it has any untested lines
                    if [ ${#uncovered_lines[@]} -gt 0 ]; then
                        files_with_untested=$((files_with_untested + 1))
                    if [ "$coverage" = "100.0" ]; then
                        printf "${GREEN}%-60s %5.1f%%${NC}\n" "$current_file" "$coverage"
                    else
                        printf "${YELLOW}%-60s %5.1f%%${NC}\n" "$current_file" "$coverage"
                    fi
                    
                    # Show uncovered lines if requested
                    if [ "$SHOW_LINES" = "yes" ]; then
                        echo -e "${RED}  Untested lines:${NC}"
                        
                        # Read the actual source file to show context
                        if [ -f "$current_source_file" ]; then
                            # Group consecutive lines
                            local start_line=""
                            local end_line=""
                            
                            for line_num in "${uncovered_lines[@]}"; do
                                if [ -z "$start_line" ]; then
                                    start_line=$line_num
                                    end_line=$line_num
                                elif [ $line_num -eq $((end_line + 1)) ]; then
                                    end_line=$line_num
                                else
                                    # Print the range
                                    if [ $start_line -eq $end_line ]; then
                                        echo "    Line $start_line"
                                        sed -n "${start_line}p" "$current_source_file" | sed 's/^/      /'
                                    else
                                        echo "    Lines $start_line-$end_line"
                                        sed -n "${start_line},${end_line}p" "$current_source_file" | sed 's/^/      /'
                                    fi
                                    echo ""
                                    start_line=$line_num
                                    end_line=$line_num
                                fi
                            done
                            
                            # Print last range
                            if [ -n "$start_line" ]; then
                                if [ $start_line -eq $end_line ]; then
                                    echo "    Line $start_line"
                                    sed -n "${start_line}p" "$current_source_file" | sed 's/^/      /'
                                else
                                    echo "    Lines $start_line-$end_line"
                                    sed -n "${start_line},${end_line}p" "$current_source_file" | sed 's/^/      /'
                                fi
                            fi
                        else
                            # Just list line numbers if can't read file
                            echo -n "    Lines: "
                            printf '%s ' "${uncovered_lines[@]}"
                            echo ""
                        fi
                        echo ""
                    fi
                fi
                fi
            fi
            
            # Start new file
            current_source_file="${line#SF:}"
            current_file="${current_source_file#lib/}"  # Remove lib/ prefix for display
            lines_hit=0
            lines_total=0
            uncovered_lines=()
            
        elif [[ $line == DA:* ]]; then
            # Line coverage data: DA:line_number,hit_count
            IFS=',' read -r line_info hits <<< "${line#DA:}"
            IFS=':' read -r line_num _ <<< "$line_info"
            
            lines_total=$((lines_total + 1))
            if [ "$hits" != "0" ]; then
                lines_hit=$((lines_hit + 1))
            else
                uncovered_lines+=("$line_num")
            fi
        fi
    done < "coverage/lcov.info"
    
    # Process last file
    if [ -n "$current_file" ] && [ $lines_total -gt 0 ]; then
        # Skip generated files
        if [[ ! "$current_file" =~ generated/ ]]; then
            total_files=$((total_files + 1))
            coverage=$(echo "scale=1; $lines_hit * 100 / $lines_total" | bc)
            
            # Show file if it has any untested lines
            if [ ${#uncovered_lines[@]} -gt 0 ]; then
                files_with_untested=$((files_with_untested + 1))
            if [ "$coverage" = "100.0" ]; then
                printf "${GREEN}%-60s %5.1f%%${NC}\n" "$current_file" "$coverage"
            else
                printf "${YELLOW}%-60s %5.1f%%${NC}\n" "$current_file" "$coverage"
            fi
            
            # Show uncovered lines if requested
            if [ "$SHOW_LINES" = "yes" ]; then
                echo -e "${RED}  Untested lines:${NC}"
                
                if [ -f "$current_source_file" ]; then
                    # Group consecutive lines
                    local start_line=""
                    local end_line=""
                    
                    for line_num in "${uncovered_lines[@]}"; do
                        if [ -z "$start_line" ]; then
                            start_line=$line_num
                            end_line=$line_num
                        elif [ $line_num -eq $((end_line + 1)) ]; then
                            end_line=$line_num
                        else
                            # Print the range
                            if [ $start_line -eq $end_line ]; then
                                echo "    Line $start_line"
                                sed -n "${start_line}p" "$current_source_file" | sed 's/^/      /'
                            else
                                echo "    Lines $start_line-$end_line"
                                sed -n "${start_line},${end_line}p" "$current_source_file" | sed 's/^/      /'
                            fi
                            echo ""
                            start_line=$line_num
                            end_line=$line_num
                        fi
                    done
                    
                    # Print last range
                    if [ -n "$start_line" ]; then
                        if [ $start_line -eq $end_line ]; then
                            echo "    Line $start_line"
                            sed -n "${start_line}p" "$current_source_file" | sed 's/^/      /'
                        else
                            echo "    Lines $start_line-$end_line"
                            sed -n "${start_line},${end_line}p" "$current_source_file" | sed 's/^/      /'
                        fi
                    fi
                else
                    # Just list line numbers if can't read file
                    echo -n "    Lines: "
                    printf '%s ' "${uncovered_lines[@]}"
                    echo ""
                fi
                echo ""
            fi
        fi
        fi
    fi
    
    if [ $files_with_untested -eq 0 ]; then
        echo -e "${GREEN}All code is fully tested! 100% coverage${NC}"
    else
        echo -e "Found ${RED}$files_with_untested${NC} of $total_files files with untested code"
    fi
    
    echo ""
}

# Main execution
echo "Usage: $0 [show-lines]"
echo "  show-lines  - Show untested lines: yes/no (default: yes)"
echo ""
echo "Examples:"
echo "  $0          # Show all files with untested lines"
echo "  $0 no       # Show only files with untested code, no line details"
echo ""

# Check if bc is installed (needed for floating point math)
if ! command -v bc &> /dev/null; then
    echo "Error: bc is not installed. Please install it:"
    echo "  Ubuntu/Debian: sudo apt-get install bc"
    echo "  macOS: should be pre-installed"
    exit 1
fi

# Check if coverage package is installed for Dart
if ! dart pub global list | grep -q coverage; then
    echo "Installing coverage package..."
    dart pub global activate coverage
fi

# Analyze both projects in parallel
echo "Analyzing projects in parallel..."
echo ""

# Create temp files for output
SERVER_OUT="/tmp/zenvestor_server_coverage_$$.tmp"
FLUTTER_OUT="/tmp/zenvestor_flutter_coverage_$$.tmp"

# Run analyses in parallel
(analyze_project_coverage "zenvestor_server" > "$SERVER_OUT") &
server_pid=$!

(analyze_project_coverage "zenvestor_flutter" > "$FLUTTER_OUT") &
flutter_pid=$!

# Wait for both to complete
wait $server_pid
wait $flutter_pid

# Display results
cat "$SERVER_OUT"
cat "$FLUTTER_OUT"

# Clean up temp files
rm -f "$SERVER_OUT" "$FLUTTER_OUT"

echo -e "${GREEN}Analysis complete.${NC}"
echo ""
echo "Tips:"
echo "- Focus on files with lowest coverage first"
echo "- Write tests for business logic before getters/setters"
echo "- Test error cases and edge conditions"
echo "- Use './scripts/test-coverage.sh' to check overall coverage percentages"