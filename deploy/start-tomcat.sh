#!/bin/sh
set -eu

# Cloud hosts provide their public HTTP port in PORT. Local Docker defaults to 8080.
port="${PORT:-8080}"
case "$port" in
  *[!0-9]*|'') echo "PORT must be a number." >&2; exit 1 ;;
esac

# Update only Tomcat's active default HTTP connector.
sed -i "s/port=\"8080\"/port=\"$port\"/" "$CATALINA_HOME/conf/server.xml"
exec "$CATALINA_HOME/bin/catalina.sh" run
