#!/bin/bash

# =========================================
# Customer 360 Demo - Complete Reset Script
# =========================================
# This script automates the complete demo reset and setup process

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SNOWFLAKE_CONNECTION="your_connection_name"  # Update this
DATABASE_NAME="customer_360_db"
WAREHOUSE_NAME="customer_360_wh"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to execute SQL script
execute_sql() {
    local script_file=$1
    local description=$2
    
    print_status "Executing: $description"
    
    if [ -f "$script_file" ]; then
        snowsql -c "$SNOWFLAKE_CONNECTION" -f "$script_file"
        if [ $? -eq 0 ]; then
            print_success "$description completed"
        else
            print_error "$description failed"
            exit 1
        fi
    else
        print_error "Script file not found: $script_file"
        exit 1
    fi
}

# Function to wait for user confirmation
confirm_action() {
    local message=$1
    echo -e "${YELLOW}$message${NC}"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Operation cancelled by user"
        exit 0
    fi
}

# Main execution
main() {
    echo "========================================="
    echo "Customer 360 Demo - Complete Reset"
    echo "========================================="
    echo
    
    # Check if snowsql is available
    if ! command -v snowsql &> /dev/null; then
        print_error "SnowSQL CLI not found. Please install SnowSQL first."
        exit 1
    fi
    
    # Check if connection exists
    if ! snowsql -c "$SNOWFLAKE_CONNECTION" -q "SELECT 1;" &> /dev/null; then
        print_error "Cannot connect to Snowflake with connection: $SNOWFLAKE_CONNECTION"
        print_warning "Please update the SNOWFLAKE_CONNECTION variable in this script"
        exit 1
    fi
    
    print_status "Connected to Snowflake successfully"
    
    # Step 1: Confirm cleanup
    confirm_action "⚠️  This will DELETE all existing demo data and objects."
    
    # Step 2: Cleanup existing demo
    print_status "Starting cleanup process..."
    execute_sql "sql/00_cleanup_demo.sql" "Demo cleanup"
    
    # Step 3: Wait for services to be fully dropped
    print_status "Waiting for Cortex Search services to be fully dropped..."
    sleep 30
    
    # Step 4: Complete setup
    print_status "Starting fresh demo setup..."
    execute_sql "sql/99_complete_setup.sql" "Complete demo setup"
    
    # Step 5: Load full sample data
    print_status "Loading comprehensive sample data..."
    execute_sql "sql/03_sample_data.sql" "Sample data loading"
    
    # Step 6: Wait for search services to index
    print_status "Waiting for Cortex Search services to index..."
    print_warning "This may take 5-10 minutes. You can check status in Snowflake."
    
    # Step 7: Upload semantic model (manual step)
    echo
    print_warning "MANUAL STEP REQUIRED:"
    echo "1. Upload sql/05_semantic_model.yaml to the customer_360_semantic_model_stage"
    echo "2. Run sql/06_cortex_agent.sql to create the full Cortex Agent"
    echo "3. Deploy the Streamlit application"
    echo
    
    # Step 8: Verify installation
    print_status "Running verification tests..."
    
    # Quick verification query
    snowsql -c "$SNOWFLAKE_CONNECTION" -q "
        USE DATABASE $DATABASE_NAME;
        SELECT 
            'Demo Status' AS component,
            'Ready' AS status,
            COUNT(*) AS customer_count 
        FROM customers;
        
        SELECT 
            'Search Services' AS component,
            COUNT(*) AS service_count
        FROM INFORMATION_SCHEMA.CORTEX_SEARCH_SERVICES 
        WHERE SERVICE_SCHEMA = 'PUBLIC';
    "
    
    # Success message
    echo
    print_success "🎉 Demo reset and setup completed successfully!"
    echo
    echo "📋 Next Steps:"
    echo "   1. Upload semantic model: sql/05_semantic_model.yaml"
    echo "   2. Create Cortex Agent: sql/06_cortex_agent.sql"
    echo "   3. Deploy Streamlit app using the files in streamlit/"
    echo "   4. Test all functionality"
    echo
    echo "🔗 Quick Access:"
    echo "   Database: $DATABASE_NAME"
    echo "   Warehouse: $WAREHOUSE_NAME"
    echo "   Schema: PUBLIC"
    echo
}

# Help function
show_help() {
    echo "Customer 360 Demo Reset Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -c, --config   Specify Snowflake connection name"
    echo
    echo "Before running:"
    echo "1. Install SnowSQL CLI"
    echo "2. Configure Snowflake connection"
    echo "3. Update SNOWFLAKE_CONNECTION variable in this script"
    echo
    echo "Example:"
    echo "  $0 -c my_snowflake_connection"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--config)
            SNOWFLAKE_CONNECTION="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Run main function
main 