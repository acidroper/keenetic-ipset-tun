#!/bin/sh

[ "$type" != "iptables" ] || exit 0
[ "$table" = "nat" ] || exit 0

ip6tables -t nat -C POSTROUTING -o tun0 -j SNAT --to-source fe80::9508:a40f:4337:874 || ip6tables -t nat -A POSTROUTING -o tun0 -j SNAT --to-source fe80::9508:a40f:4337:874

exit 0
