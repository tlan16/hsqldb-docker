#!/usr/bin/env sh
cd "${0%/*}" || exit 1
set -eo

. set-environment.sh

java -jar "${HSQLDB_SQLTOOL_JAR}" db
