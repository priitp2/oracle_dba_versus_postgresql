# Creating the environment

```
docker compose up
```

It will take a few minutes to warm up and register everything.

# Services

## PMM

https://localhost:8443/
username: admin
password: demo123

## Database accounts

demo / demo123
postgres / demo123

## Databases

* demo
* postgres

# Running load

```
docker compose exec pg2 sudo -u postgres -i /var/lib/pgsql/runload.sh
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

