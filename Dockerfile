# ============================================================
# Smart Inventory Control System — Production Dockerfile
# Target: Render.com (Docker Web Service)
# Database: External MySQL (Aiven / FreeSQLDatabase / any MySQL host)
#           Set DB_URL, DB_USERNAME, DB_PASSWORD as env vars in Render
# ============================================================

# Stage 1: Build the Maven WAR
FROM maven:3.8.5-openjdk-8-slim AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B

# ============================================================
# Stage 2: Tomcat 9 Runtime
# ============================================================
FROM tomcat:9.0-jdk8-openjdk-slim

# Remove default Tomcat webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR as ROOT.war so it runs at / (no /smart_inventory prefix)
COPY --from=builder /app/target/smart_inventory.war /usr/local/tomcat/webapps/ROOT.war

# Copy init SQL into image for reference (actual DB setup done externally)
COPY schema.sql /docker-entrypoint-initdb.d/01-schema.sql
COPY src/main/resources/seed_products.sql /docker-entrypoint-initdb.d/02-seed-products.sql
COPY src/main/resources/seed_additional_10.sql /docker-entrypoint-initdb.d/03-seed-extra.sql

# Render assigns PORT via env var — configure Tomcat to listen on it
COPY docker/server.xml /usr/local/tomcat/conf/server.xml

# Expose the port Render will use (default 8080, overridden by $PORT)
EXPOSE 8080

# Startup: apply PORT env var to Tomcat then launch
CMD ["/bin/sh", "-c", "sed -i \"s/8080/${PORT:-8080}/g\" /usr/local/tomcat/conf/server.xml && catalina.sh run"]
