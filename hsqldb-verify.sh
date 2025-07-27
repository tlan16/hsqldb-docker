#!/bin/bash

# HSQLDB Connection Verification Script
# A lightweight shell script to verify HSQLDB connections

set -e

# Default configuration
HOST="localhost"
PORT="9001"
DATABASE="mydb"
USERNAME="SA"
PASSWORD=""
JAR_PATH="/opt/hsqldb.jar"
TIMEOUT=10
VERBOSE=false
QUIET=false
PORT_ONLY=false
JDBC_ONLY=false
JSON_OUTPUT=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print usage
usage() {
    cat << EOF
HSQLDB Connection Verification Script

Usage: $0 [OPTIONS]

Options:
    -h, --host HOST         HSQLDB host (default: localhost)
    -p, --port PORT         HSQLDB port (default: 9001)
    -d, --database DB       Database name (default: mydb)
    -u, --username USER     Username (default: SA)
    -P, --password PASS     Password (default: empty)
    -j, --jar-path PATH     Path to HSQLDB JAR (default: /opt/hsqldb.jar)
    -t, --timeout SECONDS   Connection timeout (default: 10)
    --port-only             Only check port connectivity
    --jdbc-only             Only test JDBC connection
    --json                  Output results as JSON
    -v, --verbose           Verbose output
    -q, --quiet             Quiet mode
    --help                  Show this help message

Examples:
    $0                                    # Test localhost:9001/mydb
    $0 --host db.example.com --port 9002 # Test remote server
    $0 --port-only                       # Only check port connectivity
    $0 --jdbc-only                       # Only test JDBC connection
    $0 --json                            # Output results as JSON

EOF
}

# Function to log messages
log() {
    if [ "$QUIET" = false ]; then
        echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    fi
}

# Function to log with color
log_success() {
    if [ "$QUIET" = false ]; then
        echo -e "${GREEN}✅ $1${NC}"
    fi
}

log_error() {
    if [ "$QUIET" = false ]; then
        echo -e "${RED}❌ $1${NC}"
    fi
}

log_info() {
    if [ "$QUIET" = false ]; then
        echo -e "${BLUE}🔍 $1${NC}"
    fi
}

log_warning() {
    if [ "$QUIET" = false ]; then
        echo -e "${YELLOW}⚠️  $1${NC}"
    fi
}

# Function to check if port is open
check_port() {
    local host=$1
    local port=$2
    local timeout=$3
    
    if timeout "$timeout" bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to test JDBC connection
test_jdbc_connection() {
    local host=$1
    local port=$2
    local database=$3
    local username=$4
    local password=$5
    local jar_path=$6
    local timeout=$7
    
    # Check if Java is available
    if ! command -v java &> /dev/null; then
        log_error "Java is not available. Cannot test JDBC connection."
        return 1
    fi
    
    # Check if JAR file exists
    if [ ! -f "$jar_path" ]; then
        log_error "HSQLDB JAR file not found at: $jar_path"
        return 1
    fi
    
    # Create temporary Java test program
    local temp_dir=$(mktemp -d)
    local java_file="$temp_dir/HSQLDBTest.java"
    
    cat > "$java_file" << EOF
import java.sql.*;

public class HSQLDBTest {
    public static void main(String[] args) {
        String url = "jdbc:hsqldb:hsql://$host:$port/$database";
        String user = "$username";
        String password = "$password";
        
        try {
            Class.forName("org.hsqldb.jdbc.JDBCDriver");
            Connection conn = DriverManager.getConnection(url, user, password);
            
            // Execute a simple query
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT 1 FROM INFORMATION_SCHEMA.SYSTEM_USERS LIMIT 1");
            
            if (rs.next()) {
                System.out.println("SUCCESS");
                System.exit(0);
            } else {
                System.out.println("FAILED: No result from query");
                System.exit(1);
            }
            
        } catch (Exception e) {
            System.out.println("FAILED: " + e.getMessage());
            System.exit(1);
        }
    }
}
EOF
    
    # Compile and run the test
    if javac -cp "$jar_path" "$java_file" 2>/dev/null && \
       timeout "$timeout" java -cp "$jar_path:$temp_dir" HSQLDBTest 2>/dev/null | grep -q "SUCCESS"; then
        rm -rf "$temp_dir"
        return 0
    else
        rm -rf "$temp_dir"
        return 1
    fi
}

# Function to output JSON result
output_json() {
    local check_type=$1
    local success=$2
    local message=$3
    local error=$4
    
    cat << EOF
{
  "timestamp": "$(date -Iseconds)",
  "check_type": "$check_type",
  "target": "$HOST:$PORT/$DATABASE",
  "success": $success,
  "message": "$message"
EOF
    
    if [ -n "$error" ]; then
        echo ",  \"error\": \"$error\""
    fi
    
    echo "}"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--host)
            HOST="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -d|--database)
            DATABASE="$2"
            shift 2
            ;;
        -u|--username)
            USERNAME="$2"
            shift 2
            ;;
        -P|--password)
            PASSWORD="$2"
            shift 2
            ;;
        -j|--jar-path)
            JAR_PATH="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --port-only)
            PORT_ONLY=true
            shift
            ;;
        --jdbc-only)
            JDBC_ONLY=true
            shift
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    local overall_success=true
    
    if [ "$JSON_OUTPUT" = false ] && [ "$QUIET" = false ]; then
        echo -e "${BLUE}🚀 Starting HSQLDB connection verification...${NC}"
        echo -e "${BLUE}📍 Target: $HOST:$PORT/$DATABASE${NC}"
        echo
    fi
    
    # Port connectivity check
    if [ "$JDBC_ONLY" = false ]; then
        log_info "Checking port connectivity to $HOST:$PORT..."
        
        if check_port "$HOST" "$PORT" "$TIMEOUT"; then
            if [ "$JSON_OUTPUT" = true ]; then
                output_json "port" "true" "Port $PORT is accessible on $HOST"
            else
                log_success "Port $PORT is accessible on $HOST"
            fi
        else
            overall_success=false
            if [ "$JSON_OUTPUT" = true ]; then
                output_json "port" "false" "Cannot connect to $HOST:$PORT" "Connection refused or timeout"
            else
                log_error "Cannot connect to $HOST:$PORT"
            fi
            
            if [ "$PORT_ONLY" = true ]; then
                exit 1
            fi
        fi
    fi
    
    # JDBC connection check
    if [ "$PORT_ONLY" = false ]; then
        log_info "Testing JDBC connection to jdbc:hsqldb:hsql://$HOST:$PORT/$DATABASE..."
        
        if test_jdbc_connection "$HOST" "$PORT" "$DATABASE" "$USERNAME" "$PASSWORD" "$JAR_PATH" "$TIMEOUT"; then
            if [ "$JSON_OUTPUT" = true ]; then
                output_json "jdbc" "true" "JDBC connection successful"
            else
                log_success "JDBC connection successful"
            fi
        else
            overall_success=false
            if [ "$JSON_OUTPUT" = true ]; then
                output_json "jdbc" "false" "JDBC connection failed" "Connection or authentication error"
            else
                log_error "JDBC connection failed"
            fi
        fi
    fi
    
    # Final result
    if [ "$JSON_OUTPUT" = false ] && [ "$QUIET" = false ]; then
        echo
        if [ "$overall_success" = true ]; then
            echo -e "${GREEN}🎉 All checks passed! HSQLDB is healthy and accessible.${NC}"
        else
            echo -e "${RED}💥 Some checks failed. HSQLDB may not be fully accessible.${NC}"
        fi
    fi
    
    # Exit with appropriate code
    if [ "$overall_success" = true ]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main
