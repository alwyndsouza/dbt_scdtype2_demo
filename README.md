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
bash dbt_scd2_demo.sh
```

### 4. Cleaning Up

After running the tests, you can run the `cleanup.sh` script to remove all generated files, including the virtual environment, dbt artifacts, and the duckdb database file. This will reset the project to its original state.

```bash
bash cleanup.sh
```
---

# Custom SCD Type 2 Implementation

This document explains the custom SCD Type 2 implementation in this dbt project.

## Overview

This implementation uses a custom approach to handle Slowly Changing Dimensions Type 2, which allows for tracking historical data changes without relying on dbt's built-in snapshot functionality. This provides more control over the logic, especially for complex scenarios.

The logic is implemented in the `dim_customers` model, which is materialized as an incremental table.

## Models

### Staging
-   `stg_crm__customers`: This model stages the raw customer data from the source system. It is assumed that the source provides a `last_modified_date` and an `operation_type` (INSERT, UPDATE, DELETE).

### Intermediate
-   `int_crm__customers_scd`: This model prepares the data for the SCD logic. It generates a surrogate key (`scd_id`) based on the columns we want to track for changes. It also sets the `effective_start_date`.

### Marts
-   `dim_customers`: This is the main SCD Type 2 model. It is an incremental model that identifies new and changed records, expires old records, and inserts new records.

## Custom SCD Type 2

This implementation provides more control over the logic. You can customize how changes are detected, how records are expired, and how the `effective_start_date` and `effective_end_date` are calculated. This is useful for complex scenarios, such as when the source system does not provide a reliable updated timestamp.
