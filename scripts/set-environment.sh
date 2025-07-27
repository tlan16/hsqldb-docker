#!/usr/bin/env sh
set -eo

java_vm_parameters="-Dfile.encoding=UTF-8"
if [ -n "${JAVA_VM_PARAMETERS}" ]; then
  java_vm_parameters=${JAVA_VM_PARAMETERS}
  echo "Environment variable JAVA_VM_PARAMETERS is set. Using java vm parameters: ${java_vm_parameters}"
else
  echo "Environment variable JAVA_VM_PARAMETERS is not set, using default: ${java_vm_parameters}"
fi
export JAVA_VM_PARAMETERS=${java_vm_parameters}

hsqldb_user="SA"
if [ -n "${HSQLDB_USER}" ]; then
  hsqldb_user=${HSQLDB_USER}
  echo "Environment variable HSQLDB_USER is set. Using hsqldb user: ${hsqldb_user}"
else
  echo "Environment variable HSQLDB_USER is not set, using default: ${hsqldb_user}"
fi
export HSQLDB_USER=${hsqldb_user}

hsqldb_password=""
if [ -n "${HSQLDB_PASSWORD}" ]; then
  hsqldb_password=${HSQLDB_PASSWORD}
  echo "Environment variable HSQLDB_PASSWORD is set, which is used as hsqldb password."
else
  echo "Environment variable HSQLDB_PASSWORD is not set, using empty password"
fi
export HSQLDB_PASSWORD=${hsqldb_password}

hsqldb_trace="-trace true"
if [ "${HSQLDB_TRACE}" = 'false' ]; then
  hsqldb_trace="-trace false"
  echo "Environment variable HSQLDB_TRACE is set to false, set trace: ${hsqldb_trace}"
else
  echo "Environment variable HSQLDB_TRACE is not set, using default: ${hsqldb_trace}"
fi
export HSQLDB_TRACE=${hsqldb_trace}

hsqldb_silent="-silent false"
if [ "${HSQLDB_SILENT}" = 'true' ]; then
  hsqldb_silent="-silent true"
  echo "Environment variable HSQLDB_SILENT is set to true, set trace: ${hsqldb_trace}"
fi
export HSQLDB_SILENT=${hsqldb_silent}

hsqldb_remote="-remote_open true"
if [ "${HSQLDB_REMOTE}" = 'false' ]; then
  hsqldb_remote="-remote_open false"
  echo "Environment variable HSQLDB_REMOTE is set to false, set trace: ${hsqldb_trace}"
fi
export HSQLDB_REMOTE=${hsqldb_remote}

hsqldb_database_name="hsqldb"
if [ -n "${HSQLDB_DATABASE_NAME}" ]; then
  hsqldb_database_name=${HSQLDB_DATABASE_NAME}
  echo "Environment variable HSQLDB_DATABASE_NAME is set to: ${hsqldb_database_name}"
else
  echo "Environment variable HSQLDB_DATABASE_NAME is not set, using default: ${hsqldb_database_name}"
fi
export HSQLDB_DATABASE_NAME=${hsqldb_database_name}

hsqldb_database_alias="${hsqldb_database_name}"
if [ -n "${HSQLDB_DATABASE_ALIAS}" ]; then
  hsqldb_database_alias=${HSQLDB_DATABASE_ALIAS}
  echo "Environment variable HSQLDB_DATABASE_ALIAS is set to: ${hsqldb_database_alias}"
else
  echo "Environment variable HSQLDB_DATABASE_ALIAS is not set, using default: ${hsqldb_database_alias}"
fi
export HSQLDB_DATABASE_ALIAS=${hsqldb_database_alias}

hsqldb_host="0.0.0.0"
hsqldb_inetadress=""
if [ -n "${HSQLDB_DATABASE_HOST}" ]; then
  hsqldb_host=${HSQLDB_DATABASE_HOST}
  echo "Environment variable HSQLDB_DATABASE_HOST is set. Using hsqldb host: ${hsqldb_host}"
else
  echo "Environment variable HSQLDB_DATABASE_HOST is not set, using default: ${hsqldb_host}"
fi
export HSQLDB_DATABASE_HOST=${hsqldb_host}
export HSQLDB_INETADDRESS=${hsqldb_inetadress}

export HSQLDB_HOME="${HSQLDB_HOME:=/opt/hsqldb}"
export HSQLDB_JAR="${HSQLDB_JAR:=${HSQLDB_HOME}/hsqldb.jar}"
export HSQLDB_SQLTOOL_JAR="${HSQLDB_SQLTOOL_JAR:=${HSQLDB_HOME}/sqltool.jar}"
