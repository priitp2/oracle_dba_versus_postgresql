FROM oraclelinux:9
ARG python=python3.12
SHELL ["/bin/bash","-c"]
RUN echo '' > /etc/dnf/vars/ociregion
RUN dnf upgrade
RUN dnf install vim unzip less hostname oracle-epel-release-el9 gettext ${python} ${python}-pip
COPY docker-entrypoint.sh postgres_install.sh runload.sh runfailtest.py /usr/local/bin/
RUN chmod 777 /usr/local/bin/*.sh /usr/local/bin/runfailtest.py && /usr/local/bin/postgres_install.sh
ENTRYPOINT ["docker-entrypoint.sh"]
