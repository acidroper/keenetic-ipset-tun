#!/bin/sh

[ "$1" == "hook" ] || exit 0
[ "$change" == "link" ] && exit 0
[ "$id" == "Wireguard0" ] || exit 0


case ${id}-${connected}-${link}-${up} in
        ${id}-yes-up-up)
                wg set nwg0 peer ***** allowed-ips 0.0.0.0/0,::/0
        ;;
esac

exit 0
