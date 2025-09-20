# dbt Custom SCD Type 2 Implementation Demo

This dbt project is a demonstration of a custom implementation of Slowly Changing Dimension (SCD) Type 2 logic.

---

## Setup and Testing

This project includes an end-to-end test script that demonstrates the custom SCD Type 2 logic.

### 1. Setup a Virtual Environment and Install Dependencies

It is highly recommended to use a Python virtual environment to keep your project dependencies isolated.

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
dbt deps
```

This will create and activate a virtual environment, and install all the necessary Python and dbt packages.

### 2. Configure your `profiles.yml`

This project is configured to use `duckdb`. You will need to have a `profiles.yml` file in your current directory with the following content:

```yaml
default:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'dbt.duckdb'
```

The test script sets the `DBT_PROFILES_DIR` environment variable automatically.

### 3. Run the Test Script

The `dbt_scd2_demo.sh` script will run the dbt project through an initial and incremental load, and print the final state of the `dim_customers` table.

```bash
./dbt_scd2_demo.sh
```

or run cleanup and demo together

```bash
./cleanup.sh && ./dbt_scd2_demo.sh
```

### 4. Cleaning Up

After running the tests, you can run the `cleanup.sh` script to remove all generated files, including the virtual environment, dbt artifacts, and the duckdb database file. This will reset the project to its original state.

```bash
./cleanup.sh
```

---

## Demo Output

When you run the demo script, you'll see output similar to this:

```
==============================================================================
                          DBT SCD TYPE 2 DEMO                                 
==============================================================================

+--------------------------------------------------------------------------+
|                    PHASE 1: ENVIRONMENT SETUP                           |
+--------------------------------------------------------------------------+
Creating virtual environment...
✓ Virtual environment created
Activating virtual environment...
✓ Virtual environment activated
Installing dependencies from requirements.txt...
✓ Dependencies installed
Installing dbt dependencies...
✓ dbt dependencies installed

+--------------------------------------------------------------------------+
|                     PHASE 2: DBT CONFIGURATION                          |
+--------------------------------------------------------------------------+
Setting up dbt profile directory...
✓ dbt profile configured (profiles.yml should be in project root)

+--------------------------------------------------------------------------+
|                      PHASE 3: INITIAL DATA LOAD                         |
+--------------------------------------------------------------------------+
Running dbt seed (loading seed data)...
✓ Seed data loaded
Running dbt models...
✓ Initial dbt run completed

+--------------------------------------------------------------------------+
|                    PHASE 4: INITIAL STATE VERIFICATION                  |
+--------------------------------------------------------------------------+
Querying initial state of dim_customers table:
----------------------------------------------------------------------
```

**Initial State Results:**
| customer_id | city     | effective_start_date | effective_end_date | active_flag |
|-------------|----------|---------------------|-------------------|-------------|
| 1001        | New York | 2023-01-01          | 9999-12-31        | Y           |

```
+--------------------------------------------------------------------------+
|                   PHASE 5: INCREMENTAL DATA PROCESSING                  |
+--------------------------------------------------------------------------+
Updating customer data for incremental load...
✓ Customer data updated
Running incremental dbt models...
✓ Incremental dbt run completed

+--------------------------------------------------------------------------+
|                     PHASE 6: FINAL STATE VERIFICATION                   |
+--------------------------------------------------------------------------+
Querying final state of dim_customers using custom scd type 2:
----------------------------------------------------------------------
```

**Final State Results:**
| customer_id | city     | effective_start_date | effective_end_date | active_flag |
|-------------|----------|---------------------|-------------------|-------------|
| 1001        | New York | 2023-01-01          | 2023-01-30        | N           |
| 1001        | New York | 2023-01-30          | 2023-03-01        | N           |
| 1001        | Boston   | 2023-03-01          | 9999-12-31        | Y           |

```
==============================================================================
                             DEMO COMPLETED SUCCESSFULLY                      
==============================================================================
```

### Understanding the Results

The demo shows how SCD Type 2 tracks changes over time:

1. **Initial Load**: Customer 1001 starts in New York with an active record
2. **First Change**: Customer moves, creating a new active record and expiring the old one
3. **Second Change**: Customer moves to Boston, again creating a new active record

This demonstrates the core SCD Type 2 functionality: maintaining a complete history of changes while clearly marking which record is currently active.

---

# Custom SCD Type 2 Implementation

This document explains the custom SCD Type 2 implementation in this dbt project.

## Overview

This implementation uses a custom approach to handle Slowly Changing Dimensions Type 2, which allows for tracking historical data changes without relying on dbt's built-in snapshot functionality. This provides more control over the logic, especially for complex scenarios.

The logic is implemented in the `dim_customers` model, which is materialized as an incremental table.

## Models

### Staging
- `stg_crm__customers`: This model stages the raw customer data from the source system. It is assumed that the source provides a `last_modified_date` and an `operation_type` (INSERT, UPDATE, DELETE).

### Intermediate
- `int_crm__customers_scd`: This model prepares the data for the SCD logic. It generates a surrogate key (`scd_id`) based on the columns we want to track for changes. It also sets the `effective_start_date`.

### Marts
- `dim_customers`: This is the main SCD Type 2 model. It is an incremental model that identifies new and changed records, expires old records, and inserts new records.

## Custom SCD Type 2 Benefits

This implementation provides more control over the logic compared to dbt's built-in snapshot functionality:

- **Flexible Change Detection**: Customize how changes are detected based on your specific business rules
- **Custom Effective Dating**: Control how `effective_start_date` and `effective_end_date` are calculated
- **Complex Scenarios**: Handle cases where the source system doesn't provide reliable timestamps
- **Performance Optimization**: Optimize for your specific data volume and change patterns
- **Business Logic Integration**: Integrate complex business rules directly into the SCD logic

## Key Features

- Tracks complete history of dimensional changes
- Maintains active/inactive flags for easy querying
- Uses effective date ranges for point-in-time analysis
- Handles incremental processing for performance
- Supports custom business logic for change detection