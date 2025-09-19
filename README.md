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

---
## Принцип работы

### Общая концепция

Это решение для роутеров Keenetic, которое позволяет направлять трафик к определённым сайтам (доменам) через зашифрованный туннель (в данном случае, созданный с помощью Shadowsocks), в то время как остальной трафик идёт напрямую. Это классический пример `split-tunneling` (раздельного туннелирования), основанного на доменных именах.

### Компоненты и их взаимодействие

Работа системы строится на совместной работе нескольких компонентов: `Shadowsocks` (или другой прокси/VPN), `dnsmasq`, `dnscrypt-proxy`, `ipset` и скриптов для `iptables`.

Вот пошаговое описание процесса:

**1. Создание туннеля и базовой маршрутизации (при старте роутера)**

*   [`opt/etc/shadowsocks-rust.json`](opt/etc/shadowsocks-rust.json): Конфигурационный файл для клиента `shadowsocks-rust`, который создает виртуальный сетевой интерфейс `tun0`.
*   [`opt/etc/ndm/fs.d/100-tun0-interface.sh`](opt/etc/ndm/fs.d/100-tun0-interface.sh): Скрипт создает интерфейс `tun0` при старте системы.
*   [`opt/etc/ndm/fs.d/110-ipset_and_routing_table_v4.sh`](opt/etc/ndm/fs.d/110-ipset_and_routing_table_v4.sh) и [`opt/etc/ndm/fs.d/111-ipset_and_routing_table_v6.sh`](opt/etc/ndm/fs.d/111-ipset_and_routing_table_v6.sh): Эти скрипты создают:
    *   `ipset`-ы `unblock4` и `unblock6` для хранения IP-адресов.
    *   Отдельную таблицу маршрутизации (`table 1`) и правило (`ip rule add fwmark 1 table 1`), которое направляет весь трафик с меткой `1` в эту таблицу.
    *   Маршрут по умолчанию в `table 1`, который направляет весь трафик в интерфейс `tun0`.

**2. Обработка DNS-запросов (ключевой этап)**

*   Когда устройство в локальной сети запрашивает домен (например, `facebook.com`), запрос приходит на `dnsmasq` роутера.
*   `dnsmasq` ([`opt/etc/dnsmasq.conf`](opt/etc/dnsmasq.conf)) перенаправляет запрос на `dnscrypt-proxy` (`127.0.0.1#5335`).
*   `dnscrypt-proxy` ([`opt/etc/dnscrypt-proxy.toml`](opt/etc/dnscrypt-proxy.toml)) безопасно (через DoH) получает IP-адрес и возвращает его `dnsmasq`.
*   `dnsmasq` видит директиву `ipset=/.../facebook.com/.../unblock4,unblock6` и **добавляет полученный IP-адрес в `ipset`-ы `unblock4` и `unblock6`**.
*   `dnsmasq` возвращает IP-адрес клиенту.

**3. Маркировка и перенаправление трафика**

*   Клиент начинает отправлять пакеты на полученный IP-адрес.
*   [`opt/etc/ndm/netfilter.d/100-fwmarks_v4.sh`](opt/etc/ndm/netfilter.d/100-fwmarks_v4.sh) и [`opt/etc/ndm/netfilter.d/101-fwmarks_v6.sh`](opt/etc/ndm/netfilter.d/101-fwmarks_v6.sh): Эти скрипты настраивают `iptables`. Правила проверяют, принадлежит ли IP-адрес назначения пакета `ipset`-у `unblock4` или `unblock6`. Если да, то **соединение помечается меткой `1`**.
*   Ядро системы видит метку `1` и, согласно правилу `ip rule`, использует таблицу маршрутизации `1`.
*   Таблица `1` направляет пакет в интерфейс `tun0`, то есть в туннель.
*   Скрипты [`opt/etc/ndm/netfilter.d/110-tun0-nat_v4.sh`](opt/etc/ndm/netfilter.d/110-tun0-nat_v4.sh), [`opt/etc/ndm/netfilter.d/110-tun0-nat_v6.sh`](opt/etc/ndm/netfilter.d/110-tun0-nat_v6.sh), [`opt/etc/ndm/netfilter.d/110-tun0-filter_v4.sh`](opt/etc/ndm/netfilter.d/110-tun0-filter_v4.sh) и [`opt/etc/ndm/netfilter.d/110-tun0-filter_v6.sh`](opt/etc/ndm/netfilter.d/110-tun0-filter_v6.sh) обеспечивают корректную работу NAT и прохождение трафика через файрвол для туннельного интерфейса.

### Сводка процесса

1.  **Запуск:** Роутер создает туннель, `ipset`-ы и правила маршрутизации.
2.  **DNS-запрос:** Клиент запрашивает домен из списка в `dnsmasq.conf`.
3.  **Наполнение `ipset`:** `dnsmasq` разрешает домен в IP и автоматически добавляет этот IP в `ipset`.
4.  **Маркировка трафика:** `iptables` видит трафик на IP из `ipset` и ставит на него метку.
5.  **Перенаправление:** Ядро направляет маркированный трафик в туннель.
6.  **Остальной трафик:** Если домена нет в списке, его трафик идет напрямую, мимо туннеля.

---
## How it works

### Overall Concept

This is a solution for Keenetic routers that allows routing traffic to specific sites (domains) through an encrypted tunnel (in this case, created using Shadowsocks), while all other traffic goes directly. This is a classic example of domain-based `split-tunneling`.

### Components and Interaction

The system relies on the cooperation of several components: `Shadowsocks` (or another proxy/VPN), `dnsmasq`, `dnscrypt-proxy`, `ipset`, and `iptables` scripts.

Here is a step-by-step description of the process:

**1. Tunnel Creation and Base Routing (on router startup)**

*   [`opt/etc/shadowsocks-rust.json`](opt/etc/shadowsocks-rust.json): This is the configuration file for the `shadowsocks-rust` client, which creates a virtual network interface `tun0`.
*   [`opt/etc/ndm/fs.d/100-tun0-interface.sh`](opt/etc/ndm/fs.d/100-tun0-interface.sh): This script creates the `tun0` interface on system startup.
*   [`opt/etc/ndm/fs.d/110-ipset_and_routing_table_v4.sh`](opt/etc/ndm/fs.d/110-ipset_and_routing_table_v4.sh) & [`opt/etc/ndm/fs.d/111-ipset_and_routing_table_v6.sh`](opt/etc/ndm/fs.d/111-ipset_and_routing_table_v6.sh): These scripts create:
    *   `ipsets` named `unblock4` and `unblock6` to store IP addresses.
    *   A separate routing table (`table 1`) and a rule (`ip rule add fwmark 1 table 1`), which directs all traffic with firewall mark `1` to this table.
    *   A default route in `table 1` that sends all its traffic to the `tun0` interface.

**2. DNS Query Handling (The Key Step)**

*   When a device on your local network requests a domain (e.g., `facebook.com`), the request goes to the router's `dnsmasq`.
*   `dnsmasq` ([`opt/etc/dnsmasq.conf`](opt/etc/dnsmasq.conf)) forwards the request to `dnscrypt-proxy` (`127.0.0.1#5335`).
*   `dnscrypt-proxy` ([`opt/etc/dnscrypt-proxy.toml`](opt/etc/dnscrypt-proxy.toml)) securely resolves the IP address (via DoH) and returns it to `dnsmasq`.
*   `dnsmasq` sees the `ipset=/.../facebook.com/.../unblock4,unblock6` directive and **adds the resolved IP address to the `unblock4` and `unblock6` ipsets**.
*   `dnsmasq` returns the IP address to the client.

**3. Traffic Marking and Redirection**

*   The client starts sending packets to the resolved IP address.
*   [`opt/etc/ndm/netfilter.d/100-fwmarks_v4.sh`](opt/etc/ndm/netfilter.d/100-fwmarks_v4.sh) & [`opt/etc/ndm/netfilter.d/101-fwmarks_v6.sh`](opt/etc/ndm/netfilter.d/101-fwmarks_v6.sh): These scripts configure `iptables`. The rules check if the destination IP of a packet belongs to the `unblock4` or `unblock6` `ipset`. If it does, the **connection is marked with firewall mark `1`**.
*   The system's kernel sees the mark `1` and, according to the `ip rule`, uses routing `table 1`.
*   `table 1` directs the packet to the `tun0` interface, i.e., into the tunnel.
*   The [`opt/etc/ndm/netfilter.d/110-tun0-nat_v4.sh`](opt/etc/ndm/netfilter.d/110-tun0-nat_v4.sh), [`opt/etc/ndm/netfilter.d/110-tun0-nat_v6.sh`](opt/etc/ndm/netfilter.d/110-tun0-nat_v6.sh), [`opt/etc/ndm/netfilter.d/110-tun0-filter_v4.sh`](opt/etc/ndm/netfilter.d/110-tun0-filter_v4.sh) and [`opt/etc/ndm/netfilter.d/110-tun0-filter_v6.sh`](opt/etc/ndm/netfilter.d/110-tun0-filter_v6.sh) scripts ensure proper NAT and firewall traversal for the tunneled traffic.

### Process Summary

1.  **Startup:** The router creates the tunnel, `ipsets`, and routing rules.
2.  **DNS Query:** A client requests a domain listed in `dnsmasq.conf`.
3.  **`ipset` Population:** `dnsmasq` resolves the domain to an IP and automatically adds that IP to the `ipset`.
4.  **Traffic Marking:** `iptables` sees traffic going to an IP from the `ipset` and marks it.
5.  **Redirection:** The kernel directs the marked traffic into the tunnel.
6.  **Other Traffic:** If a domain is not on the list, its traffic is not marked and goes directly to the internet, bypassing the tunnel.
