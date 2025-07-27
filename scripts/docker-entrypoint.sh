#!/usr/bin/env sh
cd "${0%/*}" || exit 1
set -eo

. set-environment.sh

cat > /opt/hsqldb/sqltool.rc <<_EOF_
urlid ${hsqldb_database_alias}
url jdbc:hsqldb:hsql://${hsqldb_host}/${hsqldb_database_alias}
username SA
password
_EOF_

cat > ~/sqltool.rc <<_EOF_
urlid db
url jdbc:hsqldb:hsql://hsqldb/${hsqldb_database_alias}
username SA
password
_EOF_

echo "JAVA_VM_PARAMETERS=${JAVA_VM_PARAMETERS}"
echo "HSQLDB_DATABASE_NAME=${HSQLDB_DATABASE_NAME}"
echo "HSQLDB_DATABASE_ALIAS=${HSQLDB_DATABASE_ALIAS}"
echo "HSQLDB_USER=${HSQLDB_USER}"
if [ -n "${HSQLDB_PASSWORD}" ]; then
  echo "Environment variable HSQLDB_PASSWORD is set."
fi

java ${JAVA_VM_PARAMETERS} \
 -cp "${HSQLDB_JAR}" \
 org.hsqldb.Server \
 -database.0 \
 "file:/opt/database/${HSQLDB_DATABASE_NAME};user=${HSQLDB_USER};password=${HSQLDB_PASSWORD}" \
 -dbname.0 ${HSQLDB_DATABASE_ALIAS} \
 ${HSQLDB_TRACE} \
 ${HSQLDB_SILENT} \
 ${HSQLDB_REMOTE} \
;
