#!/bin/bash

dnf install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
percona-release enable pmm3-client
dnf install pmm-client
