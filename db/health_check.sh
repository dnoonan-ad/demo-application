#!/bin/bash

# Replace the following with your actual PostgreSQL connection details
PG_HOST="localhost"
PG_PORT="5432"
PG_USER="postgres"
PG_PASSWORD="example-password"
PG_DATABASE="postgres"

# Check PostgreSQL connection
if pg_isready -h $PG_HOST -p $PG_PORT -U $PG_USER -d $PG_DATABASE -t 1; then
    exit 0  # Success
else
    exit 1  # Failure
fi
