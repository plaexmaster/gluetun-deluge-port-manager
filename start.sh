#!/bin/bash

update_port () {
  PORT=$(cat $PORT_FORWARDED)
  echo "Portnumber ($PORT) loaded from Gluetun..."
  echo "Accessing Deluge WEBUI..."
  cookie=$(curl -s -c - -H "Content-Type: application/json" -d '{"method": "auth.login", "params": ["'$DELUGE_PASS'"], "id": 1}' $DELUGE_SERVER:$DELUGE_PORT/json) > /dev/null
  response=$(echo "$cookie" | curl -s -b - -H "Content-Type: application/json" -d '{"method": "web.get_hosts", "params": [], "id": 1}' $DELUGE_SERVER:$DELUGE_PORT/json) > /dev/null
  hostid=$(echo "$response" | jq -r '.result[0][0]')
  echo "HostID set to: $hostid"
  echo "$cookie" | curl -s -b - -H "Content-Type: application/json" -d '{"method": "web.connect", "params": ["'$hostid'"], "id": 1}' $DELUGE_SERVER:$DELUGE_PORT/json > /dev/null
  echo "$cookie" | curl -s -b - -H "Content-Type: application/json" -d '{"method": "core.set_config", "params": [{"random_port": false}], "id": 1}' $DELUGE_SERVER:$DELUGE_PORT/json > /dev/null
  response1=$(echo "$cookie" | curl -s -b - -H "Content-Type: application/json" -d '{"method": "core.get_config_value", "params": ["random_port"], "id": 1}' $DELUGE_SERVER:$DELUGE_PORT/json) > /dev/null
  randomportstatus=$(echo "$response1" | jq -r '.result')
  echo "Random port changed to: $randomportstatus"
  echo "$cookie" | curl -s -b - -H "Content-Type: application/json" -d '{"method": "core.set_config", "params": [{"listen_ports": ["'$PORT'", "'$PORT'"]}], "id": 1}' $DELUGE_SERVER:$DELUGE_PORT/json > /dev/null
  response2=$(echo "$cookie" | curl -s -b - -H "Content-Type: application/json" -d '{"method": "core.get_config_value", "params": ["listen_ports"], "id": 1}' $DELUGE_SERVER:$DELUGE_PORT/json) > /dev/null
  listenports=$(echo "$response2" | jq -r '.result')
  echo "Ports changed to $listenports"
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
