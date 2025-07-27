FROM ubuntu AS linux-base

FROM linux-base AS python-base
# Setup python environment
WORKDIR /app
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv uv sync

FROM maven:3-eclipse-temurin-24 AS java-base
# setup java environment
COPY --from=maven:3-eclipse-temurin-24 /opt/java/openjdk/ /opt/java/openjdk/
WORKDIR /opt/java/openjdk
RUN --mount=type=cache,target=/root/.m2 \
    mvn dependency:copy --batch-mode \
      --define artifact=org.hsqldb:hsqldb:LATEST \
      --define outputDirectory=./lib \
      --define stripVersion=true

FROM python-base AS app
ENV JAVA_HOME=/opt/java/openjdk
COPY --from=java-base /opt/java/openjdk/ /opt/java/openjdk/
ENTRYPOINT []
