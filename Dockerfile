# Stage 1: Build
# Use the specified Windows Server Core Insider image
FROM mcr.microsoft.com/windows/servercore/insider:10.0.26244.5000 AS build

# Set environment variables for Maven
ENV MAVEN_VERSION=3.9.9
ENV MAVEN_HOME=C:\apache-maven-${MAVEN_VERSION}\apache-maven-${MAVEN_VERSION}
ENV PATH=%MAVEN_HOME%\bin;%PATH%

# Install Maven manually
SHELL ["powershell", "-Command"]
RUN Invoke-WebRequest -Uri "https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.zip" -OutFile "apache-maven-3.9.9-bin.zip" ; \
    New-Item -Path "C:\apache-maven-3.9.9" -ItemType Directory -Force ; \
    Expand-Archive -Path "apache-maven-3.9.9-bin.zip" -DestinationPath "C:\apache-maven-3.9.9" -Force ; \
    Remove-Item -Path "apache-maven-3.9.9-bin.zip" -Force

# Set the working directory inside the container
WORKDIR /app

# Copy the pom.xml and source code to the container
COPY pom.xml .
COPY src ./src

# Build the application (compile and package the .jar file)
RUN mvn clean package -DskipTests

# Stage 2: Runtime
# Use the specified Windows Server Core Insider image for runtime
FROM mcr.microsoft.com/windows/servercore/insider:10.0.26244.5000

# Set the working directory inside the container
WORKDIR /app

# Copy the packaged jar file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the port your application will run on
EXPOSE 8080

# Command to run the application
CMD ["java", "-jar", "app.jar"]
