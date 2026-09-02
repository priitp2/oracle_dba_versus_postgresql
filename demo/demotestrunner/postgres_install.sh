#!/bin/bash

# Install pgbench
pgarch=`uname -m`
pgmajor="18"
dnf install "https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-${pgarch}/pgdg-redhat-repo-latest.noarch.rpm"
dnf install postgresql${pgmajor}

# install venv for some other test scripts
python3.12 -m venv /usr/local/test_venv
/usr/local/test_venv/bin/pip install --upgrade pip
/usr/local/test_venv/bin/pip install "psycopg[binary]"
