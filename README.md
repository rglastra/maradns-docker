I ended up not using it, but figure it may help someone else down the line.
It sets up a working copy of MaraDNS (pulls in from GitHub, master).

You'll want to edit `/etc/mararc` and `/etc/maradns/*` to set up your own zones. 
Run with `docker run -p 53:53/udp -p 53:53/tcp -d --name=maradns maradns`
