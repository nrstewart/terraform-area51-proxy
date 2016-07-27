#!/bin/bash
echo " ===> Installing additional packages"
sudo apt-get install -y python-neutronclient
echo " ====> setting proxy as router for internal traffic to internet"
sudo cp ~/eth1.cfg /etc/network/interfaces.d/eth1.cfg
sudo ifdown eth1; sudo ifup eth1
my_ip=$(ip a | grep -A3 eth0: | grep inet | awk {'print $2'} | awk -F\/ {'print $1'})
sudo echo "iptables -t nat -A POSTROUTING -p tcp ! -s 10.3.0.0/16 -d 10.3.0.0/16 -j SNAT --to ${my_ip}" >> /etc/rac-iptables.sh
sudo echo "iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /etc/rac-iptables.sh
sudo echo "iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT" >> /etc/rac-iptables.sh
sudo sed -i '/^#\(.*\)ipv6.conf.all.forwarding/s/^#//' /etc/sysctl.conf
sysctl -w net.ipv6.conf.all.forwarding=1
sudo /usr/local/bin/proxyServer
echo " ====> disable port security and port security-groups for proxy internal interface"
source ~/openrc
port_id=$(neutron port-list | grep 192.168.1.254 | awk '{print $2}')
neutron port-update --no-security-groups $port_id
neutron port-update --port-security-enabled=False $port_id
