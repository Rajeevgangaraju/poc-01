# -------------------------------
# Stage 1: Build (Maven)
# -------------------------------
FROM maven:3.9.6-eclipse-temurin-11 AS build

WORKDIR /app

# Copy pom.xml and download dependencies first (layer caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests


# -------------------------------
# Stage 2: Runtime (Lightweight JDK)
# -------------------------------
FROM eclipse-temurin:11-jre-alpine

WORKDIR /app

# Copy jar from build stage
COPY --from=build /app/target/devsecops-poc-1.0.0.jar app.jar

# Expose application port
EXPOSE 8080

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
