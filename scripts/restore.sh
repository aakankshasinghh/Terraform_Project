#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${ROOT_DIR}/docker-compose.yml"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <backup.sql>" >&2
  exit 1
fi

BACKUP_FILE="$1"
if [[ ! -f "${BACKUP_FILE}" ]]; then
  echo "Backup file not found: ${BACKUP_FILE}" >&2
  exit 1
fi

# Restore into a separate database so the source database remains untouched.
docker compose -f "${COMPOSE_FILE}" exec -T db \
  psql -U appuser -d postgres -v ON_ERROR_STOP=1 \
  -c "DROP DATABASE IF EXISTS hotel_restore;" \
  -c "CREATE DATABASE hotel_restore;"

docker compose -f "${COMPOSE_FILE}" exec -T db \
  psql -U appuser -d hotel_restore -v ON_ERROR_STOP=1 < "${BACKUP_FILE}"

BOOKINGS=$(docker compose -f "${COMPOSE_FILE}" exec -T db \
  psql -U appuser -d hotel_restore -tAc "SELECT COUNT(*) FROM hotel_bookings;")
EVENTS=$(docker compose -f "${COMPOSE_FILE}" exec -T db \
  psql -U appuser -d hotel_restore -tAc "SELECT COUNT(*) FROM booking_events;")

echo "Restore completed into hotel_restore."
echo "hotel_bookings: ${BOOKINGS}"
echo "booking_events: ${EVENTS}"
