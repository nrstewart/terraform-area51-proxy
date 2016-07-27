#!/bin/bash

#my_ip=$(ip a | grep -A3 eth0: | grep inet | awk {'print $2'} | awk -F\/ {'print $1'})
#rsh -i ~/.ssh/id_rsa 192.168.1.254 'sudo iptables -t nat -A PREROUTING -p tcp --dport 2200 -j DNAT --to-destination ${my_ip}:22'
echo "Passthrough would run here"
