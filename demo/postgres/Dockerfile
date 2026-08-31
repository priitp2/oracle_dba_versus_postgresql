ARG arch=arm64
FROM oraclelinux:9
ARG arch
ARG pgarch=aarch64
ARG python=python3.12
ARG pgmajor=18
SHELL ["/bin/bash","-c"]
RUN echo '' > /etc/dnf/vars/ociregion
RUN dnf upgrade
RUN dnf install vim unzip less hostname sudo oracle-epel-release-el9 gettext ${python} ${python}-pip https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-${pgarch}/pgdg-redhat-repo-latest.noarch.rpm
RUN dnf install pg_stat_monitor_${pgmajor} pg_wait_sampling_${pgmajor} postgresql${pgmajor}-server postgresql${pgmajor}-contrib
COPY docker-entrypoint.sh /usr/local/bin/
COPY patroni_install.sh patroni.yml.template docker-start.sh pgsql_profile /var/lib/pgsql/
RUN  chmod 777 /var/lib/pgsql/patroni_install.sh \
    && chmod 777 /usr/local/bin/docker-entrypoint.sh \
    && chown postgres:postgres /var/lib/pgsql/docker-start.sh \
    && chmod 770 /var/lib/pgsql/docker-start.sh \
    && mv /var/lib/pgsql/pgsql_profile /var/lib/pgsql/.pgsql_profile \
    && chown postgres:postgres /var/lib/pgsql/.pgsql_profile \
    && chmod 600 /var/lib/pgsql/.pgsql_profile \
    && sudo -u postgres -i /var/lib/pgsql/patroni_install.sh
VOLUME /var/lib/pgsql/data
EXPOSE 5432
EXPOSE 8080
ENTRYPOINT ["docker-entrypoint.sh"]
