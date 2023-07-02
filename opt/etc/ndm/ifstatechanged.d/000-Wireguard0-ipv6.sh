#!/bin/sh

[ "$1" == "hook" ] || exit 0
[ "$change" == "link" ] || exit 0
[ "$id" == "Wireguard0" ] || exit 0

ip6t() {
	if ! ip6tables -C "$@" &>/dev/null; then
		ip6tables -A "$@"
	fi
}

case ${id}-${change}-${connected}-${link}-${up} in
	${id}-link-yes-up-up)
		ip -6 addr add fd41:ce44:b4c9:44ca::3/64 dev nwg0
		wg set nwg0 peer ***** allowed-ips 0.0.0.0/0,::/0
		ip6t FORWARD -o nwg0 -j ACCEPT
		ip6t POSTROUTING -t nat -o nwg0 -j SNAT --to-source fd41:ce44:b4c9:44ca::3
	;;
esac

exit 0
