#!/bin/bash
echo "--- Cleaning up project artifacts ---"
rm -rf dbt_packages logs target dbt.duckdb dbt.duckdb.wal .venv
echo "--- Cleanup complete ---"
