#!/usr/bin/env python3
"""
Customer 360 Demo - Quick Setup Script
=====================================
Interactive Python script for setting up and managing the Customer 360 & AI Assistant demo
"""

import os
import sys
import time
import subprocess
from pathlib import Path
from typing import Optional, List, Dict

# Colors for terminal output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    WHITE = '\033[1;37m'
    NC = '\033[0m'  # No Color

class DemoManager:
    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        self.sql_dir = self.project_root / "sql"
        self.scripts_dir = self.project_root / "scripts"
        self.connection_name = None
        
    def print_colored(self, text: str, color: str = Colors.NC):
        """Print colored text to terminal"""
        print(f"{color}{text}{Colors.NC}")
        
    def print_header(self, text: str):
        """Print section header"""
        self.print_colored("=" * 60, Colors.CYAN)
        self.print_colored(f" {text} ", Colors.WHITE)
        self.print_colored("=" * 60, Colors.CYAN)
        
    def print_success(self, text: str):
        """Print success message"""
        self.print_colored(f"✅ {text}", Colors.GREEN)
        
    def print_error(self, text: str):
        """Print error message"""
        self.print_colored(f"❌ {text}", Colors.RED)
        
    def print_warning(self, text: str):
        """Print warning message"""
        self.print_colored(f"⚠️  {text}", Colors.YELLOW)
        
    def print_info(self, text: str):
        """Print info message"""
        self.print_colored(f"ℹ️  {text}", Colors.BLUE)
        
    def check_prerequisites(self) -> bool:
        """Check if required tools are installed"""
        self.print_header("CHECKING PREREQUISITES")
        
        # Check for SnowSQL
        try:
            result = subprocess.run(['snowsql', '--version'], 
                                  capture_output=True, text=True, check=True)
            self.print_success(f"SnowSQL found: {result.stdout.strip()}")
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            self.print_error("SnowSQL not found. Please install SnowSQL CLI first.")
            self.print_info("Download from: https://docs.snowflake.com/en/user-guide/snowsql-install-config")
            return False
            
    def get_connection_name(self) -> str:
        """Get Snowflake connection name from user"""
        if self.connection_name:
            return self.connection_name
            
        self.print_header("SNOWFLAKE CONNECTION SETUP")
        self.print_info("Available connections:")
        
        # Try to list available connections
        try:
            result = subprocess.run(['snowsql', '-l'], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                print(result.stdout)
            else:
                self.print_warning("Could not list connections")
        except:
            self.print_warning("Could not list connections")
            
        while True:
            connection = input(f"{Colors.CYAN}Enter Snowflake connection name: {Colors.NC}").strip()
            if connection:
                # Test connection
                if self.test_connection(connection):
                    self.connection_name = connection
                    return connection
                else:
                    self.print_error("Connection test failed. Please try again.")
            else:
                self.print_warning("Please enter a valid connection name.")
                
    def test_connection(self, connection: str) -> bool:
        """Test Snowflake connection"""
        self.print_info(f"Testing connection: {connection}")
        try:
            result = subprocess.run([
                'snowsql', '-c', connection, '-q', 'SELECT CURRENT_USER();'
            ], capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                self.print_success("Connection successful!")
                return True
            else:
                self.print_error(f"Connection failed: {result.stderr}")
                return False
        except subprocess.TimeoutExpired:
            self.print_error("Connection timeout")
            return False
        except Exception as e:
            self.print_error(f"Connection error: {str(e)}")
            return False
            
    def execute_sql_file(self, sql_file: str, description: str) -> bool:
        """Execute SQL file using SnowSQL"""
        file_path = self.sql_dir / sql_file
        
        if not file_path.exists():
            self.print_error(f"SQL file not found: {file_path}")
            return False
            
        self.print_info(f"Executing: {description}")
        self.print_info(f"File: {sql_file}")
        
        try:
            result = subprocess.run([
                'snowsql', '-c', self.connection_name, '-f', str(file_path)
            ], capture_output=True, text=True, timeout=300)
            
            if result.returncode == 0:
                self.print_success(f"{description} completed successfully")
                return True
            else:
                self.print_error(f"{description} failed")
                self.print_error(f"Error: {result.stderr}")
                return False
        except subprocess.TimeoutExpired:
            self.print_error(f"{description} timed out")
            return False
        except Exception as e:
            self.print_error(f"Error executing {description}: {str(e)}")
            return False
            
    def cleanup_demo(self) -> bool:
        """Clean up existing demo"""
        self.print_header("CLEANING UP EXISTING DEMO")
        self.print_warning("This will delete all existing demo data!")
        
        confirm = input(f"{Colors.YELLOW}Continue? (y/N): {Colors.NC}").strip().lower()
        if confirm != 'y':
            self.print_info("Cleanup cancelled")
            return False
            
        return self.execute_sql_file("00_cleanup_demo.sql", "Demo cleanup")
        
    def setup_database(self) -> bool:
        """Set up database and tables"""
        self.print_header("SETTING UP DATABASE")
        
        steps = [
            ("01_setup_database.sql", "Database and warehouse setup"),
            ("02_create_tables.sql", "Table creation"),
            ("03_sample_data.sql", "Sample data loading")
        ]
        
        for sql_file, description in steps:
            if not self.execute_sql_file(sql_file, description):
                return False
            time.sleep(2)  # Brief pause between steps
            
        return True
        
    def setup_cortex_search(self) -> bool:
        """Set up Cortex Search services"""
        self.print_header("SETTING UP CORTEX SEARCH")
        self.print_warning("This may take 5-10 minutes for indexing")
        
        if self.execute_sql_file("04_cortex_search.sql", "Cortex Search services"):
            self.print_info("Search services created. Indexing in progress...")
            return True
        return False
        
    def setup_cortex_agent(self) -> bool:
        """Set up Cortex Agent"""
        self.print_header("SETTING UP CORTEX AGENT")
        
        # Check if semantic model exists
        semantic_model = self.project_root / "sql" / "05_semantic_model.yaml"
        if not semantic_model.exists():
            self.print_error("Semantic model file not found!")
            return False
            
        self.print_warning("Manual step required:")
        self.print_info("1. Upload sql/05_semantic_model.yaml to customer_360_semantic_model_stage")
        self.print_info("2. Then run sql/06_cortex_agent.sql")
        
        proceed = input(f"{Colors.CYAN}Have you uploaded the semantic model? (y/N): {Colors.NC}").strip().lower()
        if proceed == 'y':
            return self.execute_sql_file("06_cortex_agent.sql", "Cortex Agent setup")
        else:
            self.print_warning("Cortex Agent setup skipped")
            return False
            
    def check_status(self) -> None:
        """Check demo status"""
        self.print_header("CHECKING DEMO STATUS")
        
        status_file = self.scripts_dir / "check_demo_status.sql"
        if status_file.exists():
            try:
                subprocess.run([
                    'snowsql', '-c', self.connection_name, '-f', str(status_file)
                ], timeout=60)
            except Exception as e:
                self.print_error(f"Status check failed: {str(e)}")
        else:
            self.print_error("Status check script not found")
            
    def show_next_steps(self) -> None:
        """Show next steps for completing the demo"""
        self.print_header("NEXT STEPS")
        
        steps = [
            "1. 📋 Verify all components are working:",
            "   • Check Cortex Search services are indexed",
            "   • Test AI functions",
            "",
            "2. 🚀 Deploy Streamlit application:",
            "   • Go to Snowsight → AI & ML → Studio",
            "   • Create new Streamlit app",
            "   • Upload files from streamlit/ directory",
            "",
            "3. 🎯 Test demo scenarios:",
            "   • High-value customer analysis",
            "   • Churn risk assessment", 
            "   • Support issue analysis",
            "   • Revenue optimization",
            "",
            "4. 🎉 Demo is ready!"
        ]
        
        for step in steps:
            if step.startswith(("1.", "2.", "3.", "4.")):
                self.print_colored(step, Colors.CYAN)
            elif step.startswith("   •"):
                self.print_colored(step, Colors.GREEN)
            else:
                print(step)
                
    def interactive_menu(self) -> None:
        """Show interactive menu"""
        while True:
            self.print_header("CUSTOMER 360 DEMO MANAGER")
            
            options = [
                "1. 🧹 Clean up existing demo",
                "2. 🏗️  Set up database and tables",
                "3. 🔍 Set up Cortex Search",
                "4. 🤖 Set up Cortex Agent",
                "5. 📊 Check demo status",
                "6. 🚀 Complete setup (all steps)",
                "7. 📋 Show next steps",
                "8. ❌ Exit"
            ]
            
            for option in options:
                print(f"  {option}")
                
            print()
            choice = input(f"{Colors.CYAN}Select option (1-8): {Colors.NC}").strip()
            
            try:
                if choice == '1':
                    self.cleanup_demo()
                elif choice == '2':
                    self.setup_database()
                elif choice == '3':
                    self.setup_cortex_search()
                elif choice == '4':
                    self.setup_cortex_agent()
                elif choice == '5':
                    self.check_status()
                elif choice == '6':
                    self.complete_setup()
                elif choice == '7':
                    self.show_next_steps()
                elif choice == '8':
                    self.print_info("Goodbye!")
                    break
                else:
                    self.print_warning("Invalid option. Please select 1-8.")
            except KeyboardInterrupt:
                self.print_info("\nOperation cancelled by user")
            except Exception as e:
                self.print_error(f"Unexpected error: {str(e)}")
                
            input(f"\n{Colors.CYAN}Press Enter to continue...{Colors.NC}")
            
    def complete_setup(self) -> None:
        """Run complete setup process"""
        self.print_header("COMPLETE DEMO SETUP")
        
        steps = [
            ("cleanup", "Clean up existing demo"),
            ("database", "Set up database"),
            ("search", "Set up Cortex Search"),
            ("agent", "Set up Cortex Agent")
        ]
        
        failed_steps = []
        
        for step_name, description in steps:
            if step_name == "cleanup":
                if not self.cleanup_demo():
                    failed_steps.append(description)
            elif step_name == "database":
                if not self.setup_database():
                    failed_steps.append(description) 
            elif step_name == "search":
                if not self.setup_cortex_search():
                    failed_steps.append(description)
            elif step_name == "agent":
                if not self.setup_cortex_agent():
                    failed_steps.append(description)
                    
        if failed_steps:
            self.print_warning("Some steps failed:")
            for step in failed_steps:
                self.print_error(f"  • {step}")
        else:
            self.print_success("Complete setup finished successfully!")
            self.show_next_steps()

def main():
    """Main function"""
    try:
        demo_manager = DemoManager()
        
        # Check prerequisites
        if not demo_manager.check_prerequisites():
            sys.exit(1)
            
        # Get connection name
        demo_manager.get_connection_name()
        
        # Show interactive menu
        demo_manager.interactive_menu()
        
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Setup cancelled by user{Colors.NC}")
        sys.exit(0)
    except Exception as e:
        print(f"{Colors.RED}Fatal error: {str(e)}{Colors.NC}")
        sys.exit(1)

if __name__ == "__main__":
    main() 