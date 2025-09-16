#!/bin/sh

[ "$type" != "ip6tables" ] || exit 0
[ "$table" = "mangle" ] || exit 0

# [ -z "$(iptables-save | grep unblock4)" ] && \
#     iptables -w -A PREROUTING -t mangle -m set --match-set unblock4 dst,src -j MARK --set-mark 1

if ! iptables-save | grep -q unblock4; then
    iptables -w -t mangle -A PREROUTING ! -s 192.168.2.0/24 -m conntrack --ctstate NEW -m set --match-set unblock4 dst -j CONNMARK --set-mark 1
    iptables -w -t mangle -A PREROUTING ! -s 192.168.2.0/24 -m set --match-set unblock4 dst -j CONNMARK --restore-mark
fi

exit 0
