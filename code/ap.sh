#!/bin/sh
#Copyright(C) 2019  saintcrossbow@gmail.com

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.If not, see http://www.gnu.org/licenses/

cp -f /minipwner/minimodes/AP/network /etc/config/network
cp -f /minipwner/minimodes/AP/wireless /etc/config/wireless

wifi
# 15 secs to resync - hopefully more than enough
sleep 15

# Lights out as we start
echo 0 > /sys/devices/platform/leds-gpio/leds/tp-link:green:3g/brightness
echo 0 > /sys/devices/platform/leds-gpio/leds/tp-link:green:wlan/brightness
echo 0 > /sys/devices/platform/leds-gpio/leds/tp-link:green:lan/brightness

# Stage 1: find current configs and nmap
echo 255 > /sys/devices/platform/leds-gpio/leds/tp-link:green:lan/brightness
SUBNET=$(ip route | grep "src $MAINIP" | awk '{print $1}')

ifconfig > /loot/ifconfig-$(date +'%Y-%m-%d-%H-%M')

# Strategy here is to get maximum input fast
nmap -sS -O -sV -F -oA /loot/nmap-$(date +'%Y-%m-%d-%H-%M') $SUBNET

# Stage 2: tcpdump for 1 minutes
echo 255 > /sys/devices/platform/leds-gpio/leds/tp-link:green:wlan/brightness
tcpdump -i br-lan -s 0 -w /loot/tcpdump_$(date +'%Y-%m-%d-%H-%M').pcap &>/dev/null &
tpid=$!

sleep 60

kill $tpid
wait $tpid
sync

# Stage 3: determine if can access Internet
echo 255 > /sys/devices/platform/leds-gpio/leds/tp-link:green:3g/brightness
ping -c 4 8.8.8.8 > /loot/pingout_$(date +'%Y-%m-%d-%H-%M').txt

sync
# Signal completion
echo 0 > /sys/devices/platform/leds-gpio/leds/tp-link:green:3g/brightness
echo 0 > /sys/devices/platform/leds-gpio/leds/tp-link:green:wlan/brightness
echo 0 > /sys/devices/platform/leds-gpio/leds/tp-link:green:lan/brightness
sleep 1
echo 255 > /sys/devices/platform/leds-gpio/leds/tp-link:green:lan/brightness
echo 255 > /sys/devices/platform/leds-gpio/leds/tp-link:green:wlan/brightness
echo 255 > /sys/devices/platform/leds-gpio/leds/tp-link:green:3g/brightness
sleep 2
echo 0 > /sys/devices/platform/leds-gpio/leds/tp-link:green:3g/brightness
echo 0 > /sys/devices/platform/leds-gpio/leds/tp-link:green:wlan/brightness
echo 0 > /sys/devices/platform/leds-gpio/leds/tp-link:green:lan/brightness
