# CodeAlpha — Web Server with Docker

A minimal, production‑style example showing how to serve a static website with nginx inside a Docker container, managed by Docker Compose.

This repository is a small learning task for containerizing a static web server. It includes:
- Dockerfile: builds an nginx-based image and installs `curl` for health checks.
- docker-compose.yml: builds and runs the container, exposes ports, and configures a healthcheck.
- app/index.html: the static site served by nginx.

Repository language composition: HTML (80%), Dockerfile (20%)

---

Table of contents
- Project status
- Prerequisites
- Quickstart (recommended)
- Commands (detailed)
- How it works (files explained)
- Troubleshooting
- Useful tips

---

Project status
- Ready to build and run locally using Docker Desktop or Docker Engine.
- Default mapping: host port `8080` → container port `80`.
- Container name: `codealpha-docker-web`
- Healthcheck: container runs `curl -fsS http://localhost/` to assert readiness.

---

Prerequisites
- Docker Desktop (Windows/macOS) or Docker Engine (Linux) installed and running.
- Docker Compose (either the plugin `docker compose` or the standalone `docker-compose`).
- Terminal / Command Prompt.

---

Quickstart — run the project (recommended)

1. Start Docker Desktop (Windows/macOS) or ensure Docker daemon is running (Linux):
   - Docker Desktop: open the app and wait until it shows "Docker is running".

2. From the repository root (where `docker-compose.yml` lives), build and run:
   ```bash
   # Compose v2 (recommended)
   docker compose up --build

   # To run in background (detached):
   docker compose up --build -d
     ```

3. Open the site in your browser:
   - Visit: http://localhost:8080

4. Stop and remove containers:
   ```bash
   docker compose down
   ```
   - After `down`, reload `http://localhost:8080` — the site should no longer be reachable.

---

Commands — what to use and why

- Build + run (foreground; shows logs)
  ```bash
  docker compose up --build
  ```

- Build + run (detached)
  ```bash
  docker compose up --build -d
  ```

- Stop & remove containers, networks (and optionally volumes)
  ```bash
  docker compose down
  docker compose down -v   # also removes volumes
  ```

- See running containers
  ```bash
  docker ps
  ```

- See all containers (including stopped)
  ```bash
  docker ps -a
  ```

- View container logs
  ```bash
  docker compose logs -f       # all services
  docker logs codealpha-docker-web  # by container name
  ```

- Show port mapping for the container
  ```bash
  docker ps
  # or
  docker port codealpha-docker-web
  ```

- Inspect health status
  ```bash
  docker inspect --format='{{.State.Health.Status}}' codealpha-docker-web
  ```

- Manually test the site from the host
  ```bash
  curl http://localhost:8080
  ```

---

How it works — files explained

- Dockerfile
  - Base image: `nginx:alpine` (small, production-ready nginx image)
  - Installs `curl` (used by the HEALTHCHECK)
  - Copies the `app` folder to the nginx web root: `/usr/share/nginx/html`
  - Adds a `HEALTHCHECK` that returns healthy only if `curl` to `http://localhost/` succeeds
  - Exposes port `80` in the image

  Key lines:
  ```dockerfile
  FROM nginx:alpine
  RUN apk add --no-cache curl
  COPY app /usr/share/nginx/html
  HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -fsS http://localhost/ || exit 1
  EXPOSE 80
  ```

- docker-compose.yml
  - Service name: `web`
  - Build context: `.` (uses Dockerfile in repo root)
  - Container name: `codealpha-docker-web`
  - Port mapping: `"8080:80"` (host:container)
  - Restart policy: `unless-stopped`
  - Duplicate healthcheck configuration (compose-level) mirrors Dockerfile healthcheck

  Key snippet:
  ```yaml
  version: "3.9"
  services:
    web:
      build: .
      container_name: codealpha-docker-web
      ports: ["8080:80"]
      restart: unless-stopped
      healthcheck:
        test: ["CMD-SHELL", "curl -fsS http://localhost/ || exit 1"]
        interval: 30s
        timeout: 5s
        retries: 3
  ```

- app/index.html
  - A minimal static HTML page confirming the server is running and listing image/ports/healthcheck used.

---

Expected behavior and verification

- On successful `docker compose up --build`, Docker will:
  - Build the image (first run).
  - Start the `codealpha-docker-web` container.
  - The container will be reachable at `http://localhost:8080`.
  - `docker ps` should show the container and port mapping (e.g. `0.0.0.0:8080->80/tcp`).
  - `docker inspect` health status should transition to `healthy` after the healthcheck passes.

Example `docker ps` output snippet:
```
CONTAINER ID  IMAGE                          COMMAND                  PORTS                   NAMES
abc123def456  codealpha_web:latest           "nginx -g 'daemon of…"   0.0.0.0:8080->80/tcp    codealpha-docker-web
```

---

Troubleshooting

- Page not loading
  - Ensure Docker is running.
  - Confirm the container state: `docker ps`
  - Confirm port mapping: `docker port codealpha-docker-web`
  - Check logs: `docker logs codealpha-docker-web` or `docker compose logs -f`
  - If the host port `8080` is already used, edit `docker-compose.yml` and change `"8080:80"` to another port (e.g. `"8081:80"`), then rebuild/run.

- Container repeatedly restarting or failing healthcheck
  - Inspect health check logs and container logs for errors.
  - Run `docker inspect` to see health details:
    ```bash
    docker inspect --format='{{json .State.Health}}' codealpha-docker-web | jq
    ```

- Compose command not found
  - If `docker compose` is unavailable, use `docker-compose` (legacy) or install the Docker Compose plugin.

- Permission / volume errors (Windows)
  - Ensure Docker Desktop file sharing includes your project path (if mounting volumes).
  - Run terminal with proper permissions.

---

Useful tips

- Run in detached mode when you don't want the logs to occupy your terminal:
  ```bash
  docker compose up --build -d
  ```

- Rebuild without cache if changes are not reflected:
  ```bash
  docker compose build --no-cache
  docker compose up -d
  ```

- To enter a running container for debugging:
  ```bash
  docker exec -it codealpha-docker-web /bin/sh
  # from inside, you can curl localhost or inspect files under /usr/share/nginx/html
  ```

