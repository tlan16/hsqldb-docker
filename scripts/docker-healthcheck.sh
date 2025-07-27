#!/usr/bin/env sh
cd "${0%/*}" || exit 1
set -eo

. set-environment.sh > /dev/null

java -jar "${HSQLDB_SQLTOOL_JAR}" \
  --inlineRc="url=jdbc:hsqldb:hsql://localhost:9001/${HSQLDB_DATABASE_ALIAS},user=${HSQLDB_USER},password=${HSQLDB_PASSWORD}" \
  --sql="SELECT COUNT(*) FROM INFORMATION_SCHEMA.SYSTEM_TABLES;" \
;
