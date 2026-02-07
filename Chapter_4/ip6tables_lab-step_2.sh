#!/bin/bash
# Refactored ip6tables configuration script
# This script eliminates code duplication by using loops and arrays

# Accept loopback and established connections
sudo ip6tables -A INPUT -i lo -j ACCEPT
sudo ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Accept SSH and DNS services
sudo ip6tables -A INPUT -p tcp --dport ssh -j ACCEPT
sudo ip6tables -A INPUT -p tcp --dport 53 -j ACCEPT
sudo ip6tables -A INPUT -p udp --dport 53 -j ACCEPT

# Accept ICMPv6 types using a loop to eliminate duplication
# Types: 1-4 (error messages), 128-129 (echo request/reply), 130-132 (multicast listener),
# 143 (multicast listener report v2), 134-136 (router/neighbor discovery),
# 141-142 (inverse neighbor discovery), 148-149 (certificate path),
# 151-153 (multicast router)
ICMPV6_TYPES=(1 2 3 4 128 129 130 131 132 143 134 135 136 141 142 148 149 151 152 153)

for type in "${ICMPV6_TYPES[@]}"; do
    sudo ip6tables -A INPUT -p icmpv6 --icmpv6-type "$type" -j ACCEPT
done

# Drop all other traffic
sudo ip6tables -A INPUT -j DROP
