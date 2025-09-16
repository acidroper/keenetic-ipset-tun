# Маршрутизация трафика по доменам для Keenetic

Этот репозиторий содержит скрипты и конфигурации для маршрутизации трафика определённых доменных имён через туннель на вашем роутере Keenetic, что позволяет обходить блокировки.

Эта настройка использует следующие инструменты:

- `dnsmasq`: Динамически обновляет `ipset` IP-адресами, полученными для указанных доменов.
- `dnscrypt`: Защищает DNS-запросы с помощью DNS-over-HTTPS.
- `iptables`: Маркирует пакеты, принадлежащие IP-адресам из `ipset`.
- `ip route`: Настраивает таблицы маршрутизации для направления маркированного трафика через туннель.
- Shadowsocks или другой прокси/VPN: Устанавливает зашифрованный туннель для выборочной маршрутизации трафика.

---

# [ENG] Domain-Based Traffic Routing for Keenetic

This repository provides scripts and configurations to route traffic for specific domain names through a tunnel on your Keenetic router, allowing you to bypass censorship.

This setup utilizes the folowing tools:

- `dnsmasq`: Dynamically updates an ipset with IPs resolved for specified domains.
- `dnscrypt`: Secures DNS queries with DNS-over-HTTPS.
- `iptables`: Marks packets belonging to IPs from the ipset.
- `ip route`: Configures routing tables to route marked traffic through the tunnel.
- Shadowsocks or another proxy/VPN: Establishes an encrypted tunnel for selective traffic routing.

