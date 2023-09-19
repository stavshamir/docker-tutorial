# Use an official MySQL runtime as a parent image
FROM mysql:latest

# Set the working directory to /app
COPY ./init.sql /tmp

# Copy the SQL script to create the database and table into the container
CMD [ "mysqld", "--init-file=/tmp/init.sql" ]