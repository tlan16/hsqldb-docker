FROM eclipse-temurin:24-jre

# Image Environment Variables
ENV HSQLDB_VERSION=2.7.4
ENV AVA_VM_PARAMETERS= \
    HSQLDB_TRACE= \
    HSQLDB_SILENT= \
    HSQLDB_REMOTE= \
    HSQLDB_DATABASE_NAME=default \
    HSQLDB_DATABASE_ALIAS=default \
    HSQLDB_DATABASE_HOST=0.0.0.0 \
    HSQLDB_USER= \
    HSQLDB_PASSWORD=

RUN set -eux; \
    CONTAINER_USER=hsql; \
    CONTAINER_UID=1010; \
    CONTAINER_GROUP=hsql; \
    CONTAINER_GID=1010; \
    if ! getent group "$CONTAINER_GID"; then \
      groupadd -g "$CONTAINER_GID" "$CONTAINER_GROUP"; \
    else \
      CONTAINER_GROUP=$(getent group "$CONTAINER_GID" | cut -d: -f1); \
    fi; \
    useradd -u "$CONTAINER_UID" -g "$CONTAINER_GID" -d "/home/$CONTAINER_USER" -s "/bin/bash" -m "$CONTAINER_USER"; \
    apt-get update && apt-get install -y \
      ca-certificates \
      wget && \
    mkdir -p /opt/database && \
    mkdir -p /opt/hsqldb && \
    mkdir -p /scripts && \
    wget -O /opt/hsqldb/hsqldb.jar https://repo1.maven.org/maven2/org/hsqldb/hsqldb/${HSQLDB_VERSION}/hsqldb-${HSQLDB_VERSION}.jar && \
    wget -O /opt/hsqldb/sqltool.jar https://repo1.maven.org/maven2/org/hsqldb/sqltool/${HSQLDB_VERSION}/sqltool-${HSQLDB_VERSION}.jar && \
    chown -R "$CONTAINER_UID:$CONTAINER_GID" /opt/hsqldb /opt/database /scripts && \
    apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/log/*

VOLUME ["/opt/database","/scripts"]
EXPOSE 9001

USER hsql
WORKDIR /scripts
COPY imagescripts/docker-entrypoint.sh /opt/hsqldb/docker-entrypoint.sh
COPY imagescripts/docker-healthcheck.sh /opt/hsqldb/docker-healthcheck.sh
ENTRYPOINT ["/opt/hsqldb/docker-entrypoint.sh"]
CMD ["hsqldb"]

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=30s --start-interval=1s \
  CMD /opt/hsqldb/docker-healthcheck.sh || exit 1