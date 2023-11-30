#!/bin/sh

[ "$1" != "start" ] && exit 0

### Create set
ipset -! create unblock6 hash:net family inet6 timeout 86400

### Create routing tables for marked packets
if [ -z "$(ip -6 route list table 1)" ]; then
    ip -6 rule add fwmark 1 table 1
    ip -6 route add default dev tun0 table 1
fi

exit 0
