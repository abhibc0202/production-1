FROM nginx:alpine

# Copy the dashboard HTML
COPY index.html /usr/share/nginx/html/index.html

# Copy the startup script
COPY docker-entrypoint.sh /docker-entrypoint.d/40-dashboard.sh

# Make the startup script executable
RUN chmod +x /docker-entrypoint.d/40-dashboard.sh

EXPOSE 80
