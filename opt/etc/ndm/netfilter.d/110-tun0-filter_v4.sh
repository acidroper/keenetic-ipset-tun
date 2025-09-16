#!/bin/sh

[ "$type" != "ip6tables" ] || exit 0
[ "$table" = "filter" ] || exit 0

iptables -C FORWARD -o tun0 -j ACCEPT || iptables -A FORWARD -o tun0 -j ACCEPT

exit 0
