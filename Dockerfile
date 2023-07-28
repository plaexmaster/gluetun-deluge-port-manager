FROM ubuntu:jammy

LABEL version="1.0"

ENV DELUGE_SERVER=localhost
ENV DELIGE_CLI_USER=YOURUSERNAME
ENV DELUGE_CLI_PASS=YOURPASSWORD
ENV PORT_FORWARDED=gluetun/forwarded_port

COPY ./start.sh ./start.sh
RUN chmod 770 ./start.sh

CMD ["./start.sh"]
