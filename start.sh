#!/bin/bash

update_port () {
  PORT=$(cat $PORT_FORWARDED)
  echo "Portnumber ($PORT) loaded from Gluetun..."
  deluge-console "connect $DELUGESERVER:58846 $DELUGE_CLI_USER $DELUGE_CLI_PASS; config --set listen_ports ($PORT,$PORT); config --set random_port false"
}

while true; do
  if [ -f $PORT_FORWARDED ]; then
    update_port
    inotifywait -mq -e close_write $PORT_FORWARDED | while read change; do
      update_port
    done
  else
    echo "Couldn't find file $PORT_FORWARDED"
    echo "Trying again in 10 seconds"
    sleep 10
  fi
done
