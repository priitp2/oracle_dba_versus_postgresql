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

Log in to pg1 or pg2 in Docker.
Execute

```
sudo -u postgres -i /var/lib/pgsql/runload.sh
```
