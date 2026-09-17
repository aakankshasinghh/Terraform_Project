#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${ROOT_DIR}/backups"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/hotel_${TIMESTAMP}.sql"

mkdir -p "${BACKUP_DIR}"

docker compose -f "${ROOT_DIR}/docker-compose.yml" exec -T db \
  pg_dump -U appuser -d hotel --clean --if-exists > "${BACKUP_FILE}"

echo "Backup created: ${BACKUP_FILE}"
