#!/bin/bash

if [ ! -f /var/lib/pgsql/patroni.yml ]; then
    source /var/lib/pgsql/.docker_env
    if [ -z "$PATRONIHOST" ]; then
        PATRONIHOST=`hostname -s`
    fi

    HOSTIP=`hostname -I|cut -d' ' -f1`
    export PATRONIHOST HOSTIP
    envsubst < /var/lib/pgsql/patroni.yml.template > /var/lib/pgsql/patroni.yml
fi

/var/lib/pgsql/patroni01_venv/bin/patroni /var/lib/pgsql/patroni.yml
