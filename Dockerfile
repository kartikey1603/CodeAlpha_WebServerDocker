# Simple web server using nginx in Docker
FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Copy static site
COPY app /usr/share/nginx/html

# Healthcheck: returns 'healthy' if homepage is reachable
HEALTHCHECK --interval=30s --timeout=5s --retries=3  \
 CMD curl -fsS http://localhost/ || exit 1

# Expose HTTP
EXPOSE 80

