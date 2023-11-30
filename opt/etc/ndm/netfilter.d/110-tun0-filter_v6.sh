#!/bin/sh

[ "$type" != "iptables" ] || exit 0
[ "$table" == "filter" ] || exit 0

ip6tables -C FORWARD -o tun0 -j ACCEPT || ip6tables -A FORWARD -o tun0 -j ACCEPT

exit 0
