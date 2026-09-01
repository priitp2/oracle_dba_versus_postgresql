#!/bin/bash

export PGPASSWORD="demo123"
runtime="${1:-1200}"

echo "Running time: ${runtime}s"

# Run modifications
/usr/pgsql-18/bin/pgbench -h pgdog -p 6432 -U demo \
    -M extended --jobs=1 --client=2 \
    --rate=100 -P 10 \
    --time=$runtime \
    demo &

sleep 2

# Run selects
/usr/pgsql-18/bin/pgbench -h pgdog -p 6432 -U demo --no-vacuum \
    -S -M extended --jobs=1 --client=2 \
    --rate=1000 -P 10 \
    --time=$runtime \
    demo &

sleep $runtime
