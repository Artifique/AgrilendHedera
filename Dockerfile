# Use a lightweight Java 17 image
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the built JAR file from the target directory
# Assuming your JAR is named agrilend-backend-1.0.0.jar based on pom.xml
COPY target/agrilend-backend-1.0.0.jar app.jar

# Expose the port your Spring Boot application runs on
EXPOSE 8080

# Define the command to run your application
ENTRYPOINT ["java", "-jar", "app.jar"]