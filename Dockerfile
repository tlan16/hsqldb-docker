FROM maven:3-eclipse-temurin-24-alpine AS download-stage
# setup java environment
WORKDIR /opt/hsqldb
# Download hsqldb
RUN --mount=type=cache,target=/root/.m2 \
    mvn dependency:copy --batch-mode \
      --define artifact=org.hsqldb:hsqldb:LATEST \
      --define outputDirectory=.
RUN mv --verbose hsqldb-*.jar hsqldb.jar

# Download sqltool
RUN --mount=type=cache,target=/root/.m2 \
    mvn dependency:copy --batch-mode \
      --define artifact=org.hsqldb:sqltool:LATEST \
      --define outputDirectory=.
RUN mv --verbose sqltool-*.jar sqltool.jar

FROM alpine AS final-stage
WORKDIR /app

# Copy dependencies from the download stage
COPY --from=download-stage /opt/java/openjdk/ /opt/java/openjdk/
COPY --from=download-stage /opt/hsqldb/ /opt/hsqldb/

# setup runtime environment
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
COPY scripts/ /app/scripts/
ENV PATH="/app/scripts:${PATH}"
COPY scripts/set-environment.sh /app/set-environment.sh
WORKDIR /app

ENTRYPOINT []
CMD ["docker-entrypoint.sh"]

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=30s --start-interval=1s \
  CMD docker-healthcheck.sh || exit 1
