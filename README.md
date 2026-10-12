# UpRock CLI

Docker image for the [UpRock CLI](https://github.com/uprockcom/cli) v0.0.37. The container runs the earning daemon in the foreground and restarts it if it exits. Login state is kept in a Docker volume.

Linux amd64 and arm64 are supported. The image includes Chromium because the daemon uses it for crawl work.

## Start

```bash
docker compose up -d --build
```

The daemon starts immediately. It does not earn until you log in.

## Log in

`auth login` needs a terminal so it can prompt for the email code:

```bash
docker compose exec uprock uprock auth login --email you@example.com
```

Non-interactive login:

```bash
SESSION=$(docker compose exec -T uprock uprock auth request --email you@example.com 2>/dev/null)
docker compose exec -T uprock uprock auth confirm --session "$SESSION" --code 123456
```

Check that earning is on:

```bash
docker compose exec uprock uprock daemon status
```

The session is stored in the `uprock-data` volume and survives container restarts.

## Logs

```bash
docker compose logs -f
```

Or from inside the container:

```bash
docker compose exec uprock uprock daemon logs -f
docker compose exec uprock uprock daemon logs -n 50
docker compose exec uprock uprock daemon logs --grep error
```

## Stop

```bash
docker compose stop
docker compose up -d
```

`docker compose down` removes the container and keeps the volume. `docker compose down -v` deletes the volume and the saved login.

## Notes

This image runs `uprock daemon run` as the main process. Do not use `uprock daemon install` here. That command registers a systemd, launchd, or Task Scheduler service, and this container has none of those. Compose `restart: unless-stopped` is what brings the daemon back after a crash or reboot.

Auth tokens and the daemon database live under `/data/UpRock` in the volume.
