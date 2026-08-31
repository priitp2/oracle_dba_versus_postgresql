#!/bin/bash

envfile="/var/lib/pgsql/.docker_env"
echo "export PATRONIHOST=$PATRONIHOST" > "$envfile"

mkdir -p /var/lib/pgsql/data
chown postgres:postgres /var/lib/pgsql/data
chmod 700 /var/lib/pgsql/data

sudo -u postgres -i bash /var/lib/pgsql/docker-start.sh
