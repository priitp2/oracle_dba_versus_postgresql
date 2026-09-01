#!/bin/bash

envfile="/var/lib/pgsql/.docker_env"
echo "export PATRONIHOST=$PATRONIHOST" > "$envfile"

mkdir -p /var/lib/pgsql/data
chown postgres:postgres /var/lib/pgsql/data
chmod 700 /var/lib/pgsql/data

if [ ! -f "/var/lib/pgsql/.pgsql_profile" ]; then
    echo "" > /var/lib/pgsql/.pgsql_profile
fi

# Start postgres
sudo -u postgres -i bash /var/lib/pgsql/docker-start.sh &

# Wait for patroni to be up
for i in $(seq 1 60); do
    sleep 1
    nc -z localhost 8080
    [ $? -eq 0 ] && break
done
sleep 20

# Run postgresql init
if [ ! -f /var/lib/pgsql/data/demopgsetupdone ]; then
    patronistatus=`curl  -s -o /dev/null -w "%{http_code}" http://localhost:8080/primary`
    if [ "$patronistatus" == "200" ]; then
        # This is primary instance
        sudo -u postgres -i psql -a -f initpostgres.sql
        sudo -u postgres -i /usr/pgsql-18/bin/pgbench -h localhost -p 5432 -U demo -s 2 -i demo
    fi
    touch /var/lib/pgsql/data/demopgsetupdone
fi


# Configure pmm-agent
if [ ! -f /pmm_configured ]; then
    for i in $(seq 1 60); do
        sleep 1
        nc -z pmm 8443
        [ $? -eq 0 ] && break
    done
    # Wait until pmm admin password gets changed
    sleep 2m
    # Register the agent
    pmm-agent setup --config-file=/usr/local/percona/pmm/config/pmm-agent.yaml --server-address=pmm:8443 \
        --server-username=admin --server-password=demo123 --server-insecure-tls \
        --force $PATRONIHOST generic $PATRONIHOST
    [ $? -eq 0 ] && touch /pmm_configured
fi

# Start pmm-agent
if [ -f /pmm_configured ]; then
    rm -f /pmm-agent.log
    /usr/sbin/pmm-agent --config-file=/usr/local/percona/pmm/config/pmm-agent.yaml > /pmm-agent.log &
fi

# Register pmm postgres
pmm-admin list|grep postgresql_pgstatmonitor_agent
if [ $? -ne 0 ]; then
    pmm-admin add postgresql $PATRONIHOST --server-insecure-tls --query-source=pgstatmonitor --username=postgres --password=demo123 --database=postgres --cluster=demo
fi

# Register patroni
# If it already exists, it will fail, does not matter
pmm-admin add external-serverless --server-insecure-tls --url="http://${PATRONIHOST}:8080/metrics" --skip-connection-check --external-name="${PATRONIHOST}-patroni" --cluster=demo --group=patroni

# Just wait
while :; do
    sleep 1h
done
