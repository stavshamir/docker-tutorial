# Use an official MySQL runtime as a parent image
FROM mysql:latest

# Set the working directory to /app
WORKDIR /app

# Copy the SQL script to create the database and table into the container
COPY ./init.sql /docker-entrypoint-initdb.d/

# Set environment variables
ENV MYSQL_ROOT_PASSWORD=password
ENV MYSQL_DATABASE=knights

# Expose port 3306 for MySQL connections
EXPOSE 5000