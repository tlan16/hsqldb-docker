#!/usr/bin/env sh

java -jar '/opt/hsqldb/sqltool.jar' \
  --inlineRc="url=jdbc:hsqldb:hsql://localhost:9001/default,user=SA,password=" \
  --sql="SELECT COUNT(*) FROM INFORMATION_SCHEMA.SYSTEM_TABLES;"
