# Domain-Based Traffic Routing for Keenetic

This repository provides scripts and configurations to route traffic for specific domain names through a tunnel on your Keenetic router, allowing you to bypass censorship.

This setup utilizes the folowing tools:

- `dnsmasq`: Dynamically updates an ipset with IPs resolved for specified domains.
- `dnscrypt`: Secures DNS queries with DNS-over-HTTPS.
- `Shadowsocks`: Establishes an encrypted tunnel for selective traffic routing.
- `iptables`: Sets up rules for traffic forwarding based on domain membership in the ipset.
- `ip route`: Configures routing tables to direct traffic through the Shadowsocks tunnel.
