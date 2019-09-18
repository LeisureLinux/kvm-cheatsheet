#!/bin/bash
# 注意：本脚本默认掩码 255.255.255.0
DEV=$1
IP=$2
GW=$(echo $IP|awk -F'.' '{print $1 "." $2 "." $3 ".1" }')
[ -z "${IP}" ] && echo "Syntax: $0 网卡设备名(eth0) IP地址" && exit 1
UUID=$(nmcli con show|grep ${DEV}|tail -1|awk '{print $NF}')
[ -z "${UUID}" ] && echo "出错了，网卡设备 ${DEV} 对应的 UUID 没找着！" && exit 2
DNS="114.114.114.114 8.8.8.8 8.8.4.4"
SEARCH="local yj777.cn"
nmcli con delete $UUID
nmcli con add type ethernet ifname ${DEV} con-name ${DEV} \
  autoconnect yes ip4 ${IP}/24 gw4 ${GW}
nmcli con mod ${DEV} ipv4.method manual 
nmcli con mod ${DEV} ipv4.dns "${DNS}"
nmcli con mod ${DEV} ipv4.dns-search "${SEARCH}"
nmcli con down ${DEV} && nmcli con up ${DEV}
#nmcli con show ${DEV}
