FROM oraclelinux:9
ARG python=python3.12
SHELL ["/bin/bash","-c"]
RUN echo '' > /etc/dnf/vars/ociregion
RUN dnf upgrade
RUN dnf install vim unzip less hostname sudo oracle-epel-release-el9 gettext ${python} ${python}-pip
COPY docker-entrypoint.sh /usr/local/bin/
COPY pmm_install.sh postgres_install.sh /
RUN chmod 700 /postgres_install.sh && /postgres_install.sh
COPY patroni_install.sh patroni.yml.template docker-start.sh pgsql_profile initpostgres.sql runload.sh /var/lib/pgsql/
RUN  chmod 777 /var/lib/pgsql/patroni_install.sh \
    && chmod 777 /usr/local/bin/docker-entrypoint.sh \
    && chown postgres:postgres /var/lib/pgsql/docker-start.sh \
    && chmod 770 /var/lib/pgsql/docker-start.sh \
    && mv /var/lib/pgsql/pgsql_profile /var/lib/pgsql/.pgsql_profile \
    && chown postgres:postgres /var/lib/pgsql/.pgsql_profile \
    && chmod 600 /var/lib/pgsql/.pgsql_profile \
    && chmod 700 /pmm_install.sh && /pmm_install.sh \
    && chmod 777 /var/lib/pgsql/runload.sh && chown postgres:postgres /var/lib/pgsql/runload.sh \
    && sudo -u postgres -i /var/lib/pgsql/patroni_install.sh
VOLUME /var/lib/pgsql/data
EXPOSE 5432
EXPOSE 8080
ENTRYPOINT ["docker-entrypoint.sh"]
