#!/bin/bash

python3.12 -m venv /var/lib/pgsql/patroni01_venv
/var/lib/pgsql/patroni01_venv/bin/pip install --upgrade pip
/var/lib/pgsql/patroni01_venv/bin/pip install patroni[etcd3,psycopg3] cdiff etcd3
