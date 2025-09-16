#!/bin/sh

[ "$type" != "iptables" ] || exit 0
[ "$table" = "mangle" ] || exit 0

# [ -z "$(ip6tables-save | grep unblock6)" ] && \
#     ip6tables -w -A PREROUTING -t mangle -m set --match-set unblock6 dst,src -j MARK --set-mark 1

if ! ip6tables-save | grep -q unblock6; then
    ip6tables -w -t mangle -A PREROUTING ! -s fd41:ce44:b4c9:44ca::/64 -m conntrack --ctstate NEW -m set --match-set unblock6 dst -j CONNMARK --set-mark 1
    ip6tables -w -t mangle -A PREROUTING ! -s fd41:ce44:b4c9:44ca::/64 -m set --match-set unblock6 dst -j CONNMARK --restore-mark
fi

exit 0
