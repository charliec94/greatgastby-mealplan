#!/bin/sh
set -eu
umask 077
if [ "${DATA_DIR:-}" != /app/data ]; then echo 'Container DATA_DIR must be /app/data; bind your appdata folder there' >&2; exit 1; fi
if [ -L /app/data ] || [ -L /app/data/state.json ]; then echo 'Appdata and state.json must not be symlinks' >&2; exit 1; fi
mkdir -p /app/data
if [ "$(id -u)" = 0 ]; then
  # Repair app-owned paths only; never recursively chown Tailscale state.
  chown node:node /app/data
  if [ -f /app/data/state.json ]; then chown node:node /app/data/state.json; chmod 600 /app/data/state.json; fi
  exec su-exec node:node node /app/server.js
fi
exec node /app/server.js
