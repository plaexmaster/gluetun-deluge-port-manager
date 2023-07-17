FROM ubuntu:jammy

LABEL version="1.0"

RUN apt-get update
RUN apt-get install --yes --quiet curl inotify-tools jq

ENV DELUGE_SERVER=localhost
ENV DELUGE_PORT=8112
ENV DELUGE_PASS=deluge
ENV PORT_FORWARDED=tmp/gluetun/forwarded_port

COPY ./start.sh ./start.sh
RUN chmod 770 ./start.sh

CMD ["./start.sh"]
