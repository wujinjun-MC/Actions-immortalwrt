#!/bin/sh
# 2026-02-24 https://openwrt.org/docs/guide-user/base-system/hotplug#rename_interfaces_by_mac_address
# Map dev name to "{dev_name} {dev_mac}"
while read -r DEV_NAME DEV_MAC; do
    uci set network.${DEV_NAME}.device="${DEV_NAME}"
    uci set network.${DEV_NAME}6.device="${DEV_NAME}"
    uci -q delete network.${DEV_NAME}_dev
    uci set network.${DEV_NAME}_dev="device"
    uci set network.${DEV_NAME}_dev.mac="${DEV_MAC}"
    uci set network.${DEV_NAME}_dev.name="${DEV_NAME}"
done << EOI
wana 11:22:33:44:55:66
wanb aa:bb:cc:dd:ee:ff
EOI

uci commit network
service network restart
