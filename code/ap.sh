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

ledState () {
    case $1 in
      "off")
        echo 0 > /sys/devices/platform/leds-gpio/leds/tp-link:green:3g/brightness
        echo 0 > /sys/devices/platform/leds-gpio/leds/tp-link:green:wlan/brightness
        echo 0 > /sys/devices/platform/leds-gpio/leds/tp-link:green:lan/brightness
      ;;
      "on")
        echo 255 > /sys/devices/platform/leds-gpio/leds/tp-link:green:lan/brightness
        echo 255 > /sys/devices/platform/leds-gpio/leds/tp-link:green:wlan/brightness
        echo 255 > /sys/devices/platform/leds-gpio/leds/tp-link:green:3g/brightness
      ;;
      "stage1")
        echo 255 > /sys/devices/platform/leds-gpio/leds/tp-link:green:lan/brightness
      ;;
      "stage2")
        echo 255 > /sys/devices/platform/leds-gpio/leds/tp-link:green:wlan/brightness
      ;;
      "stage3")
        echo 255 > /sys/devices/platform/leds-gpio/leds/tp-link:green:3g/brightness
      ;;
      *)
        echo 255 > /sys/devices/platform/leds-gpio/leds/tp-link:green:3g/brightness
      ;;
    esac
}

cp -f /minipwner/minimodes/AP/network /etc/config/network
cp -f /minipwner/minimodes/AP/wireless /etc/config/wireless

wifi
# 15 secs to resync - hopefully more than enough
sleep 15

# Lights out as we start
ledState "off"

# Stage 1: find current configs and nmap
ledState "stage1"
SUBNET=$(ip route | grep "src $MAINIP" | awk '{print $1}')

ifconfig > /loot/ifconfig-$(date +'%Y-%m-%d-%H-%M')

# Strategy here is to get maximum input fast
nmap -sS -O -sV -F -oA /loot/nmap-$(date +'%Y-%m-%d-%H-%M') $SUBNET

# Stage 2: tcpdump for 1 minutes
ledState "stage2"
tcpdump -i br-lan -s 0 -w /loot/tcpdump_$(date +'%Y-%m-%d-%H-%M').pcap &>/dev/null &
tpid=$!

sleep 60

kill $tpid
wait $tpid
sync

# Stage 3: determine if can access Internet
# Using ideas https://unix.stackexchange.com/questions/190513/shell-scripting-proper-way-to-check-for-internet-connectivity

ledState "stage3"
if ping -q -c 1 -W 1 8.8.8.8 >/loot/pingIPv4_$(date +'%Y-%m-%d-%H-%M').txt; then
  ping1Check=1
else
  ping1Check=0
fi

if ping -q -c 1 -W 1 google.com >/loot/pingOut_$(date +'%Y-%m-%d-%H-%M').txt; then
  ping2Check=1
else
  ping2Check=0
fi

if nc -zw1 google.com 443; then
  httpCheck=1
  echo "HTTP Connection: Good" >/loot/httpOut_$(date +'%Y-%m-%d-%H-%M').txt
else
  echo "HTTP Connection: None" >/loot/httpOut_$(date +'%Y-%m-%d-%H-%M').txt
  httpCheck=0
fi

sync
# Signal completion
ledState "off"
sleep 1
ledState "on"
sleep 2
ledState "off"

# Finally show connectivity in order from top to bottom: ping, DNS, web
if (((ping1Check==1))); then
  ledState "stage1"
fi

if (((ping2Check==1))); then
  ledState "stage2"
fi

if (((httpCheck==1))); then
  ledState "stage3"
fi
