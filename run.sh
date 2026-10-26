#!/bin/sh
set -eu
export HOST="${HOST:-127.0.0.1}"
export PORT="${PORT:-8080}"
exec python3 app.py
