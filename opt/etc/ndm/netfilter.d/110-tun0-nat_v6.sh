#!/bin/sh

[ "$type" != "iptables" ] || exit 0
[ "$table" == "nat" ] || exit 0

if [ -z "$(ip6tables-save | grep 'POSTROUTING -o tun0 -j SNAT --to-source fe80::9508:a40f:4337:874')" ]; then
ip6tables -t nat -A POSTROUTING -o tun0 -j SNAT --to-source fe80::9508:a40f:4337:874
fi

exit 0
