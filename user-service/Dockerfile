# Smart Inter-Wilaya Taxi Platform - User Service Dockerfile
FROM maven:3.9.6-openjdk-17-slim AS build

# Set working directory
WORKDIR /build

# Copy pom.xml and pom files first for better layer caching
COPY pom.xml .
COPY user-service/pom.xml ./user-service/

# Download dependencies (this layer will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B

# Copy source code
COPY user-service/src ./user-service/src

# Build the application
RUN mvn clean package -DskipTests

# Production stage
FROM openjdk:17-jre-slim

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Create logs directory
RUN mkdir -p logs

# Copy the built JAR from the build stage
COPY --from=build /build/target/user-service-1.0.0.jar app.jar

# Expose port
EXPOSE 8081

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8081/user-service/api/health || exit 1

# Run the application
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]