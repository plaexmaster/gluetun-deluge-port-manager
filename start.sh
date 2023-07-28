#!/bin/bash

update_port () {
  PORT=$(cat $PORT_FORWARDED)
  echo "Portnumber ($PORT) loaded from Gluetun..."
  FORMATTED_PORT="[$PORT, $PORT]"
  echo "Portnumber formatted to fit Deluge config: $FORMATTED_PORT"
  rm -f "/gluetun/deluge_cookies.txt"
  echo "Accessing Deluge WEBUI..."
  curl -s -c /gluetun/deluge_cookies.txt -H "Content-Type: application/json" -d '{"method": "auth.login", "params": ["'$DELUGE_PASS'"], "id": 1}' $DELUGE_SERVER:$DELUGE_PORT/json
  response=$(curl -s -b /gluetun/deluge_cookies.txt -H "Content-Type: application/json" -d '{"method": "web.get_hosts", "params": [], "id": 1}' $DELUGE_SERVER:$DELUGE_PORT/json)
  hostid=$(echo "$response" | jq -r '.result[0][0]')
  echo "HostID set to: $hostid"
  curl -s -b /gluetun/deluge_cookies.txt -H "Content-Type: application/json" -d '{"method": "web.connect", "params": ["'$hostid'"], "id": 1}' $DELUGE_SERVER:$DELUGE_PORT/json
  curl -s -b /gluetun/deluge_cookies.txt -H "Content-Type: application/json" -d '{"method": "core.set_config", "params": [{"random_port": false}], "id": 1}' $DELUGE_SERVER:$DELUGE_PORT/json
  curl -s -b /gluetun/deluge_cookies.txt -H "Content-Type: application/json" -d '{"method": "core.set_config", "params": [{"listen_ports": "'$FORMATTED_PORT'"}], "id": 1}' $DELUGE_SERVER:$DELUGE_PORT/json
  rm -f "/gluetun/deluge_cookies.txt"
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
