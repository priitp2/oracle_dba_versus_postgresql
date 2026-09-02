# What is it?

Demo environment with two PostgreSQL servers managed with Patroni. It also has pgDog for query load balancing and Percona Monitoring and Management services up.

# Creating the environment

```
docker compose up
```

During the first run (when services are created for the first time), it will take a few minutes to warm up and register everything. PMM takes a few min to register the targets.

# Services

## PMM

https://localhost:8443/
username: admin
password: demo123

## Database accounts

* demo / demo123
* postgres / demo123

## Databases

* demo
* postgres

# Tests

## Running load

The command line argument is the how long is the test running, in seconds (default 1200s)
This test executes two pgbench runners, one 100tps with writing that are all routed to leader instance and one 1000tps with read-only queries, that are load-balanced.

```
docker compose exec demotestrunner runload.sh
docker compose exec demotestrunner runload.sh 600
```

## Failover timings

Start this test (max running time 30m) and then you can do database failure tests (killing container) or switchovers and this test will report the timings how long the service was down for clients.

Via pgDog:

```
docker compose exec demotestrunner runfailtest.py
```

Direct to PostgreSQL leader node:

```
docker compose exec demotestrunner runfailtest.py --direct
```

Direct to PostgreSQL any node (leader or replica):

```
docker compose exec demotestrunner runfailtest.py --direct-any
```

# Patroni commands

```
docker compose exec pg1 sudo -u postgres -i /var/lib/pgsql/patroni01_venv/bin/patronictl -c /var/lib/pgsql/patroni.yml topology
docker compose exec pg1 sudo -u postgres -i /var/lib/pgsql/patroni01_venv/bin/patronictl -c /var/lib/pgsql/patroni.yml switchover
```

# Monitoring

Go to PMM page

## pgDog

To monitor pgDog:
* To go: All Dashboards
* Press: New > Import
* Enter grafana.com dashboard ID: 24583
* Press: Load
* Select the only Data Source available and import it
