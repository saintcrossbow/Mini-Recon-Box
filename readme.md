# MiniReconBox

This project was inspired by the upcoming Shark Jack and existing Netool.io. I really like the look of both of these products but I have way too many InfoSec toys. Suddenly I realized that my minipwner – a gadget I rarely deploy from my arsenal – could be repurposed to get similar details and possibly offer additional functionality.

**Method**

The minipwner offers a warwalk mode and a hidden Access Point as a drop box. 

Find the method of creating one [via Ace Hackware](https://acehackware.zendesk.com/hc/en-us/articles/206785486-MiniPwner-Build-Guide).

The code I’ve created runs payloads when establishing the hidden access point. The idea is that when you are planting the device you get the options of either taking the loot you’ve gathered or just leave the device behind and use the access point later.

**Setup**
1. Create /loot directory
2. Replace ap.sh with the code included in this library

**Deploy**
1. Connect to network jack
2. Set mode to Attack (AP)
3. Turn on device to gather loot
4. Turn off and take device with you or just leave behind as typical WiFi dropbox.

**Testing Status**

All LEDs show normally as the Access Point and network connections are established. To best read it, orient the LEDs where power is on top – the status lights below it are as follows:
* Ethernet
* WLAN
* Internet

Once network connections are opened, the LEDs are then repurposed to show payload status:
1. All LEDs initially go blank.
2. The first LED (Ethernet) indicates the network status payload has started. The interface configuration is saved and piped to a nmap payload that identifies OS and runs basic (safe) scripts. 
3. The second LED (WLAN) indicates a brief sniffer dump has started. For sixty seconds, tcpdump is used to record any information found on the wire.
4. The third LED (Internet) indicates that a ping test has started to see if the subnet can get out to the Internet.
5. All lights will blink once when complete and then indicate connectivity status as per below

**Connectivity Status**

Once all payloads are complete, the outbound connectivity is displayed as follows:
* The first LED (Ethernet) indicates that you can ping outbound based on IPv4
* The second LED (WLAN) indicates that you can resolve DNS outbound
* The third LED (Internet) indicates that you can access external webpages

If all three are lit you are good to go!
