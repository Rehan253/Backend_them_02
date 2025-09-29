#!/usr/bin/env sh
set -eu

echo "[entrypoint] Booting as_backend_theme2…"

# load /app/.env if present

if [ -f "/app/.env" ]; then
  echo "[entrypoint] Loading /app/.env"
  set -a
  . /app/.env
  set +a
else
  echo "[entrypoint] /app/.env not found (ok if env vars come from docker-compose)."
fi

# Validate required env vars for a Phoenix release
: "${DATABASE_URL:?DATABASE_URL is required}"
: "${SECRET_KEY_BASE:?SECRET_KEY_BASE is required}"
export PORT="${PORT:-4000}"

# Wait for the database to be ready
#    pg_isready supports a full connection string with -d "$DATABASE_URL"
PG_READY_MAX_ATTEMPTS="${PG_READY_MAX_ATTEMPTS:-30}"
PG_READY_SLEEP_SECS="${PG_READY_SLEEP_SECS:-1}"

echo "[entrypoint] Waiting for database to accept connections…"
attempt=0
until pg_isready -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$PGDATABASE" >/dev/null 2>&1; do

  attempt=$((attempt+1))
  if [ "$attempt" -ge "$PG_READY_MAX_ATTEMPTS" ]; then
    echo "[entrypoint] Database not ready after $PG_READY_MAX_ATTEMPTS attempts. Exiting."
    exit 1
  fi
  echo "[entrypoint] DB not ready yet (attempt $attempt). Sleeping ${PG_READY_SLEEP_SECS}s…"
  sleep "$PG_READY_SLEEP_SECS"
done
echo "[entrypoint] Database is ready."

#Run Ecto migrations in the release
#    This uses Ecto.Migrator directly; no custom Release module required.
echo "[entrypoint] Running database migrations…"
bin/as_backend_theme2 eval "Application.ensure_all_started(:as_backend_theme2); Ecto.Migrator.with_repo(AsBackendTheme2.Repo, fn repo -> Ecto.Migrator.run(repo, Application.app_dir(:as_backend_theme2, \"priv/repo/migrations\"), :up, all: true) end)"


# Start the application (release)
echo "[entrypoint] Starting application…"
exec bin/as_backend_theme2 start
