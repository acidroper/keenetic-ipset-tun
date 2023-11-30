#!/bin/sh

[ "$1" != "start" ] && exit 0

### Create set
ipset -! create unblock4 hash:net timeout 86400

### Create routing tables for marked packets
if [ -z "$(ip route list table 1)" ]; then
    ip rule add fwmark 1 table 1
    ip route add default dev tun0 table 1
fi

exit 0
