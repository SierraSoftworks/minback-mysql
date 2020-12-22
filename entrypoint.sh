#! /bin/bash
set -e -o pipefail

DB="$1"
ARGS="${@:2}"

mc config host add pg "$MINIO_SERVER" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY" --api "$MINIO_API_VERSION" > /dev/null

ARCHIVE="${MINIO_BUCKET}/${DB}-$(date $DATE_FORMAT).archive"

echo "Dumping $DB to $ARCHIVE"
echo "> mysqldump $DB ${ARGS}"

mysqldump "$DB" $ARGS | mc pipe "pg/$ARCHIVE" || { echo "Backup failed"; mc rm "pg/$ARCHIVE"; exit 1; }

echo "Backup complete"
