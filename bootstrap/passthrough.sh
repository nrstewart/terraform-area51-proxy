#!/bin/bash

my_ip=$(ip a | grep -A3 eth0: | grep inet | awk {'print $2'} | awk -F\/ {'print $1'})
me=$(hostname)
case $me in
  innsmouth)
    my_port="2200"
    ;;
  azathoth)
    my_port="2300"
    ;;
  shub-niggurath)
    my_port="2400"
    ;;
  yog-sothoth)
    my_port="2500"
    ;;
esac
rsh -i ~/.ssh/id_rsa 192.168.1.254 "sudo echo 'iptables -t nat -A PREROUTING -p tcp --dport ${my_port} -j DNAT --to-destination ${my_ip}:22' >> /etc/rac-iptables.sh && sudo /etc/rac-iptables.sh"
