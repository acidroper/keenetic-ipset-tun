#!/bin/sh

[ "$1" != "start" ] && exit 0

### Create tun interface for shadowsocks
if [ -z "$(ip link list dev tun0)" ]; then
    ip tuntap add mode tun tun0
    ip addr add 10.255.0.1/24 dev tun0
    ip addr add fe80::9508:a40f:4337:874 dev tun0
    ip link set dev tun0 up
fi

exit 0
