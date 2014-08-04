# vim:set ft=dockerfile:

#
# docker build -t jr4consulting/postgres:9.4 .
# docker run -p 5432:5432 --name contact-mgr-db -d jr4consulting/postgres:9.4
#
# Note:
# If using boot2docker, you need to forward a host port to 5432 on the guest
#

FROM postgres:9.4

ADD ./docker-entrypoint.sh /
ADD ./contactManager.sql /

RUN apt-get install -y openssh-server

# During dev phase
#RUN apt-get install -y vim-tiny
#RUN apt-get install -y net-tools

# Added PGPATH reference to work around a permissions
# issue when trying to launch the DB instance
ENV PGPATH /var/run/postgresql
ENV PGDATA /var/run/postgresql/data

VOLUME /var/run/postgresql

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 22

CMD ["postgres"]
