#!/bin/bash
set -e

echo "=============================================================================="
echo "                          DBT SCD TYPE 2 DEMO                                 "
echo "=============================================================================="
echo ""

# 1. Setup Virtual Environment and Install Dependencies
echo "+--------------------------------------------------------------------------+"
echo "|                    PHASE 1: ENVIRONMENT SETUP                           |"
echo "+--------------------------------------------------------------------------+"
echo "Creating virtual environment..."
python3 -m venv .venv > /dev/null 2>&1
echo "✓ Virtual environment created"

echo "Activating virtual environment..."
source .venv/bin/activate > /dev/null 2>&1
echo "✓ Virtual environment activated"

echo "Installing dependencies from requirements.txt..."
pip install -r requirements.txt > /dev/null 2>&1
echo "✓ Dependencies installed"

echo "Installing dbt dependencies..."
dbt deps > /dev/null 2>&1
echo "✓ dbt dependencies installed"
echo ""

# 2. Setup dbt profile
echo "+--------------------------------------------------------------------------+"
echo "|                     PHASE 2: DBT CONFIGURATION                          |"
echo "+--------------------------------------------------------------------------+"
echo "Setting up dbt profile directory..."
export DBT_PROFILES_DIR=.
echo "✓ dbt profile configured (profiles.yml should be in project root)"
echo ""

# 3. Initial Load
echo "+--------------------------------------------------------------------------+"
echo "|                      PHASE 3: INITIAL DATA LOAD                         |"
echo "+--------------------------------------------------------------------------+"
echo "Running dbt seed (loading seed data)..."
dbt seed -q
echo "✓ Seed data loaded"

echo "Running dbt models..."
dbt run -q
echo "✓ Initial dbt run completed"
echo ""

# 4. Query Initial State
echo "+--------------------------------------------------------------------------+"
echo "|                    PHASE 4: INITIAL STATE VERIFICATION                  |"
echo "+--------------------------------------------------------------------------+"
echo "Querying initial state of dim_customers table:"
echo "----------------------------------------------------------------------"
dbt run-operation query_dim_customers
echo ""

# 5. Prepare for and run Incremental Load
echo "+--------------------------------------------------------------------------+"
echo "|                   PHASE 5: INCREMENTAL DATA PROCESSING                  |"
echo "+--------------------------------------------------------------------------+"
echo "Updating customer data for incremental load..."
dbt run-operation update_customers > /dev/null 2>&1
echo "✓ Customer data updated"

echo "Running incremental dbt models..."
dbt run > /dev/null 2>&1
echo "✓ Incremental dbt run completed"
echo ""

# 6. Query Final State
echo "+--------------------------------------------------------------------------+"
echo "|                     PHASE 6: FINAL STATE VERIFICATION                   |"
echo "+--------------------------------------------------------------------------+"
echo "Querying final state of dim_customers using custom scd type 2:"
echo "----------------------------------------------------------------------"
dbt run-operation query_dim_customers
echo ""

echo "=============================================================================="
echo "                             DEMO COMPLETED SUCCESSFULLY                      "
echo "=============================================================================="