# gluetun-deluge port manager
Automatically updates the listening port for deluge to the port forwarded by [Gluetun](https://github.com/qdm12/gluetun/). 

Using qBittorent? See here: [gluetun-qbittorrent-port-manager](https://github.com/plaexmaster/gluetun-qbittorrent-port-manager).

## Description
[Gluetun](https://github.com/qdm12/gluetun/) has the ability to forward ports for supported VPN providers, but Deluge does not have the ability to update its listening port dynamically.
This script available as a docker container automatically detects changes to the forwarded_port file created by [Gluetun](https://github.com/qdm12/gluetun/) and updates the Deluge's listening port. It also configure random port to false since we want to decide our own ports. This script uses curl to update the config.

## Setup
Add a mounted volume to [Gluetun](https://github.com/qdm12/gluetun/) (e.g. /yourfolder:/tmp/gluetun).

Finally, add the following snippet to your `docker-compose.yml`, substituting the default values for your own.

```yml
...

  gluetun-deluge-port-manager:
    image: plaexmstr/gluetun-deluge-port-manager
    container_name: gluetun-deluge-port-manager
    volumes:
      - /yourfolder:/gluetun #set "yourfolder" to the same directory you used for Gluetun
    network_mode: "service:gluetun"
    environment:
      DELUGE_SERVER: localhost
      DELUGE_PORT: 8112
      DELUGE_PASS: YOURPASSWORD #change this to your own
      PORT_FORWARDED: /gluetun/forwarded_port
    restart: unless-stopped

...
```
