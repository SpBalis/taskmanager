# Step 1: Build stage
FROM maven:3.9.6-eclipse-temurin-21 as build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Step 2: Run stage
FROM eclipse-temurin:21-jdk-alpine
VOLUME /tmp
WORKDIR /app
COPY --from=build /app/target/taskmanager-*.jar app.jar

# Application run
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
