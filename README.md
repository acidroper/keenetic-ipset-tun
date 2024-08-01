# Domain-Based Traffic Routing for Keenetic

This repository provides scripts and configurations to route traffic for specific domain names through a tunnel on your Keenetic router, allowing you to bypass censorship.

This setup utilizes the folowing tools:

- `dnsmasq`: Dynamically updates an ipset with IPs resolved for specified domains.
- `dnscrypt`: Secures DNS queries with DNS-over-HTTPS.
- `iptables`: Marks packets belonging to IPs from the ipset.
- `ip route`: Configures routing tables to route marked traffic through the tunnel.
- Shadowsocks or another proxy/VPN: Establishes an encrypted tunnel for selective traffic routing.
