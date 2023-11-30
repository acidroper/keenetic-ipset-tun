#!/bin/sh

[ "$type" != "ip6tables" ] || exit 0
[ "$table" == "nat" ] || exit 0

if [ -z "$(iptables-save | grep 'POSTROUTING -o tun0 -j SNAT --to-source 10.255.0.1')" ]; then
iptables -t nat -A POSTROUTING -o tun0 -j SNAT --to-source 10.255.0.1
fi

exit 0
