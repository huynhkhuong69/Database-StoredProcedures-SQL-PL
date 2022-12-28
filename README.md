# Database-StoredProcedures-SQL-PL

Installation:

Execute these commands in the db2 container and terminal/bash

db2 “connect to cs157a”
db2 -td"@" -f p2_create.sql
db2 -td"@" -f p2.sql
db2 -tvf p2test.sql



