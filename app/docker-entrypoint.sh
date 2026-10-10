#!/bin/sh
set -eu

CONFIG_FILE="/usr/share/nginx/html/dashboard-config.json"

APP_ENV_VALUE="${APP_ENV:-unknown}"

if [ -n "${APP_SECRET:-}" ]; then
    SECRET_PRESENT=true
else
    SECRET_PRESENT=false
fi

cat > "$CONFIG_FILE" <<JSON
{
  "appEnv": "$APP_ENV_VALUE",
  "secretPresent": $SECRET_PRESENT
}
JSON

# Record startup activity on the persistent volume.
if [ -d /data ] && [ -w /data ]; then
    printf '%s | Production-1 application started | environment=%s\n' \
        "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$APP_ENV_VALUE" \
        >> /data/application.log
fi
