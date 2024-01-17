#!/bin/bash

DB_DUMP_LOCATION="/tmp/psql_data/rates.sql"

echo "*** CREATING DATABASE ***"

psql -U postgres < "$DB_DUMP_LOCATION";

echo "*** DATABASE CREATED! ***"