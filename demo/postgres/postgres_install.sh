#!/bin/bash

pgarch=`uname -m`
pgmajor="18"
dnf install "https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-${pgarch}/pgdg-redhat-repo-latest.noarch.rpm"
dnf install pg_stat_monitor_${pgmajor} pg_wait_sampling_${pgmajor} postgresql${pgmajor}-server postgresql${pgmajor}-contrib postgresql${pgmajor}
dnf install netcat
