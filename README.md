# CodeAlpha — Web Server using Docker (Task 4)

A minimal example showing how to serve a static website with nginx inside a Docker container, managed with Docker Compose.  
This project demonstrate containerization, running a web server in Docker, and monitoring container health.

Repository contents (important files)
- `Dockerfile` — builds an nginx-based image and installs `curl` for health checks.
- `docker-compose.yml` — builds & runs the container, exposes host port `8080`, and defines a healthcheck.
- `app/index.html` — minimal static site served by nginx.

Quick summary of key values
- Image base: `nginx:alpine`
- Container name: `codealpha-docker-web`
- Host → Container port mapping: `8080:80`
- Healthcheck: `curl -fsS http://localhost/` inside the container

Prerequisites
- Docker Desktop (Windows/macOS) or Docker Engine (Linux) installed and running.
- Docker Compose (the CLI plugin `docker compose` or legacy `docker-compose`).
- Terminal / Command Prompt.

Quickstart — run the project

1. Start Docker (Docker Desktop on Windows/macOS or ensure Docker daemon running on Linux).

2. Open a terminal in the repository root (where `docker-compose.yml` is located) and run:
   ```bash
   # Compose v2 (recommended)
   docker compose up --build

   # or legacy
   docker-compose up --build
   ```
   - To run in background add `-d`:
     ```bash
     docker compose up --build -d
     ```

3. Visit the site:
   - Open: http://localhost:8080
   - If `docker ps` shows a different host port, use that port.

4. Stop and remove containers:
   ```bash
   docker compose down
   # or
   docker-compose down
   ```

Useful commands (verify & debug)
- List running containers:
  ```bash
  docker ps
  ```
- Show all containers (including stopped):
  ```bash
  docker ps -a
  ```
- Show logs:
  ```bash
  docker logs codealpha-docker-web
  # or follow logs:
  docker logs -f codealpha-docker-web
  ```
- Stream Compose service logs:
  ```bash
  docker compose logs -f
  ```
- Show port mappings:
  ```bash
  docker port codealpha-docker-web
  ```
- Inspect container health status:
  ```bash
  docker inspect --format='{{.State.Health.Status}}' codealpha-docker-web
  ```
- Enter running container (for debugging):
  ```bash
  docker exec -it codealpha-docker-web /bin/sh
  # then inside container:
  curl -v http://localhost/
  ls -la /usr/share/nginx/html
  ```
- Rebuild without cache:
  ```bash
  docker compose build --no-cache
  docker compose up -d
  ```

How this project covers the learning objectives Below is a short mapping of the Task learning goals to concrete project elements and practices included in this repository.

1) Learn Docker containerization basics
   - Where: `Dockerfile`
   - How: The Dockerfile demonstrates building an image from `nginx:alpine`, installing packages (`apk add curl`) and copying static content into the image. This shows image layering, small base images, and copying artifacts into image filesystem.

2) Deploy and manage a web server inside Docker containers
   - Where: `docker-compose.yml`, `Dockerfile`, and `app/`
   - How: `docker compose up --build` builds the image and runs the nginx container. Compose simplifies service lifecycle commands (start, stop, rebuild). The container serves static HTML from `/usr/share/nginx/html`.

3) Understand container lifecycle and commands
   - Where: README commands & examples above
   - How: Using `docker compose up`, `docker ps`, `docker logs`, `docker exec`, and `docker compose down` demonstrates starting, inspecting, entering, and stopping containers—core lifecycle operations.

4) Monitor container health and troubleshoot issues
   - Where: `HEALTHCHECK` in both `Dockerfile` and `docker-compose.yml`
   - How: The healthcheck runs `curl -fsS http://localhost/` inside the container. Use `docker inspect` to check `.State.Health.Status` and `docker logs` + `docker compose logs` to troubleshoot failures. Example troubleshooting steps are included in this README.

5) Explore container-based app deployment best practices
   - Where: Project layout and configuration
   - How:
     - Use of a small base image (`nginx:alpine`) for smaller attack surface and faster pulls.
     - Separate static content in `app/` and copy at build time (immutable images).
     - Healthchecks to provide readiness information to orchestrators.
     - Use of Docker Compose for local orchestration and repeatable dev environment.
     - Explicit port mapping and container naming for easier operations.
     - Restart policy (`unless-stopped`) to increase resilience for long-running services.

Files explained (quick)
- Dockerfile
  ```dockerfile
  FROM nginx:alpine
  RUN apk add --no-cache curl
  COPY app /usr/share/nginx/html
  HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -fsS http://localhost/ || exit 1
  EXPOSE 80
  ```
  - Builds an image with nginx, adds `curl` for health checks, copies the static site, sets a healthcheck and exposes HTTP port.

- docker-compose.yml
  ```yaml
  version: "3.9"
  services:
    web:
      build: .
      container_name: codealpha-docker-web
      ports:
        - "8080:80"
      restart: unless-stopped
      healthcheck:
        test: ["CMD-SHELL", "curl -fsS http://localhost/ || exit 1"]
        interval: 30s
        timeout: 5s
        retries: 3
  ```
  - Builds the image from the Dockerfile, runs service `web` with port forwarding, restart policy, and a compose-level healthcheck.

- app/index.html
  - Minimal static HTML page used to confirm the server is working.


Troubleshooting tips
- If `docker compose` is not found, try `docker-compose` or install Docker Compose plugin.
- If port 8080 is in use, edit `docker-compose.yml` (change `"8080:80"` to another host port) or free the port.
- If container fails healthcheck:
  - Check logs: `docker logs codealpha-docker-web`
  - Exec into container: `docker exec -it codealpha-docker-web /bin/sh` and run `curl -v http://localhost/`.
  - Confirm files present in `/usr/share/nginx/html`.
- If image build fails due to network, check network/proxy settings or retry.
