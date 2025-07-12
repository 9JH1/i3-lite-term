#!/bin/bash

# --- SETTINGS ---

MAX_RETRYS=10
RETRY_INTERVAL=0
INTERFACE=$(ip addr show | awk '/inet.*brd/{print $NF}')
INTERFACE="wlan0"
HOSTNAME=$(cat /etc/hostname)
PUBLIC_IP=$(ip addr show | grep "brd"  | grep "inet " | awk '{print $4}')
HOSTNAME_SIZE=10
HOSTNAME_MESSAGE="3meMFKR"
# --- END OF SETTINGS ---

#print host information
echo "Info:"
echo " - Hostname = $HOSTNAME"
echo " - Public IP = $PUBLIC_IP"
echo " - Settings:"
echo "    Max Retrys = $MAX_RETRYS"
echo "    Retry Interval = $RETRY_INTERVAL"
echo "    Hostname Size = $HOSTNAME_SIZE"
echo " - MAC Addresses:"
for addr in $(ifconfig | grep ether | awk '{print $2}');do
	printf "    "
	echo $addr
done;
echo -e " - Network Device(s): (using \"\033[95m$INTERFACE\033[0m\")"
for device in $(ip addr show | grep "state" | awk '{print $2}');do
	echo "   ${device::-1}"
done;
read
echo -e "\nStarting MAC Spoof..."
change_mac_address(){
	HEX_VALUES=$(xxd -l 6 -p /dev/urandom | tr -d '\n')
	MAC_ADDRESS=$(echo $HEX_VALUES | sed 's/\(..\)/\1:/g; s/.$//')
	echo "Generated MAC Address: $MAC_ADDRESS"
	echo "Bringing down $INTERFACE"
	ip link set dev $INTERFACE down || {
		echo "Failed to bring $INTERFACE down"
		return 1
	}
	echo "$INTERFACE down"
	echo "Setting MAC address..."
	ip link set dev $INTERFACE address $MAC_ADDRESS || {
		echo "Failed to set MAC adress $MAC_ADDRESS"
		return 1
	}
	echo "MAC address set!"
	echo "Bringing $INTERFACE up"
	ip link set dev $INTERFACE up || {
		echo "Failed to bring $INTERFACE up"
		return 1
	}
	echo "$INTERFACE up"
	return 0

}
# mac spoof
attempt=1
while true;do
	echo "Attempt $attempt of $MAX_RETRYS"
	change_mac_address
	if [ $? -eq 0 ];then
		echo "Mac Address changed successfully"
		break
	else
		echo "Failed Attempt"
	fi;
	if [ $attempt -eq $MAX_RETRYS ];then
		echo "Error: surpassed max_retrys"
		exit 1
	fi
	attempt=$((attempt + 1))
	sleep $RETRY_INTERVAL
done;

gen_rand_char() {
	all_chars="1234567890QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm"
	index=$(($RANDOM % ${#all_chars}))
	rand_char=${all_chars:$index:1}
	echo $rand_char
}
# hostname spoof
echo -e "\nStarting Hostname Spoof..."
random_list=""
echo "Generated Random $HOSTNAME_SIZE CHAR String"
for((i=0; i<$HOSTNAME_SIZE; i++));do
	a=$(gen_rand_char)
	printf "$a"
	random_list="$random_list$a"
done
echo ""
echo "Appended \"$HOSTNAME_MESSAGE\" to $random_list"
random_list="$HOSTNAME_MESSAGE$random_list"
echo $random_list
echo "Applying SHA-256 Hash..."
sha256_hostname=$(echo "$random_list" | sha256sum)
sha256_hostname=${sha256_hostname::-2}
echo "$sha256_hostname"
sha256_hostname=${sha256_hostname:0:${#sha256_hostname}/2}
echo "Sliced Hash: $sha256_hostname"
echo "Changing Hostname to \"$sha256_hostname\""
echo $sha256_hostname > /etc/hostname
echo "Hostname changed successfully"
