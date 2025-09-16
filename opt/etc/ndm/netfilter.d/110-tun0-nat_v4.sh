#!/bin/sh

[ "$type" != "ip6tables" ] || exit 0
[ "$table" = "nat" ] || exit 0

iptables -t nat -C POSTROUTING -o tun0 -j SNAT --to-source 10.255.0.1 || iptables -t nat -A POSTROUTING -o tun0 -j SNAT --to-source 10.255.0.1

exit 0
