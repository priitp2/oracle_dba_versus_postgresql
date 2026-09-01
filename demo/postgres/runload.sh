#!/bin/bash

export PGPASSWORD="demo123"
/usr/pgsql-18/bin/pgbench -h pgdog -p 6432 -U demo \
    -M extended --jobs=1 --client=2 \
    --rate=1000 -P 5 \
    --time=1200 \
    demo
