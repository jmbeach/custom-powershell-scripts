function getEthernetInterface() {
	$ethInterface = (Get-JsonFromFile "$home\custom-scripts\ip-config.json").ethernetInterface
	return $ethInterface
}

function set-ip-static ([string]$ip, [string]$strMask, [string]$gateway, [string]$dns1, [string]$dns2, [string]$networkInterface)  {
	netsh interface ipv4 set address name=$networkInterface static $ip $strMask $gateway  1
	netsh interface ipv4 delete dnsservers name=$networkInterface all validate=no
	netsh interface ipv4 set dns name=$networkInterface static addr=$dns1 validate=no
	netsh interface ipv4 add dnsservers name=$networkInterface addr=$dns2 index=2 validate=no
}

function set-ip-disabled([string] $networkInterface) {
	netsh interface set interface $networkInterface disabled
}

function set-ip-enabled([string] $networkInterface) {
	netsh interface set interface $networkInterface enabled
}

function set-ip-wireless-dhcp {
	$networkInterface = "Wi-Fi 2"
	netsh interface ipv4 set address name=$networkInterface dhcp
}

function set-ip-wireless-disabled {
	$networkInterface = "Wi-Fi 2"
	set-ip-disabled $networkInterface
}

function set-ip-wireless-enabled {
	$networkInterface = "Wi-Fi 2"
	set-ip-enabled $networkInterface
}

function set-ip-eth-dhcp {
	netsh interface ipv4 set address name=(getEthernetInterface) dhcp
}

function set-ip-eth-disabled {
	set-ip-disabled (getEthernetInterface)
}

function set-ip-eth-enabled {
	set-ip-enabled (getEthernetInterface)
}

function Reset-IpStack {
	netsh int ip reset
	Restart-Computer
}