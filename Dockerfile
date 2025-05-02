# Use the official Nginx image as the base
FROM nginx:latest

# Copy your HTML file into the container's default web server directory
COPY html  /usr/share/nginx/html/

# Expose the default HTTP port (port 80)
EXPOSE 80
