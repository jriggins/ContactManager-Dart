#!/bin/bash
set -e

create_schema() {
  echo "Waiting on Postgres to start before creating schema"
  sleep 2

  echo "Creating schema"
  gosu postgres psql -f contactManager.sql
}

if [ "$1" = 'postgres' ]; then
  # Have postgres own this directory.
  # Even though the base postgres:9.4 Dockerfile does this
  # somehow root owns it by the time we get here. :/
  # We apparently need it in order for the socket fd to be 
  # placed here.
  chown -R postgres "$PGPATH"
  
  if [ -z "$(ls -A "$PGDATA")" ]; then
    gosu postgres initdb

    sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'/" "$PGDATA"/postgresql.conf
    
    { echo; echo 'host all all 0.0.0.0/0 trust'; } >> "$PGDATA"/pg_hba.conf

    create_schema & 
  fi
 
  exec gosu postgres "$@"
fi

exec "$@"
