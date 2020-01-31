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

function set-ip-eth-wi-internal {
	$ip = "192.168.201.26"
	$strMask = "255.255.255.0"
	$gateway = "192.168.201.254"
	$dns1 = "8.8.8.8"
	$dns2 = "8.8.4.4"
	set-ip-static $ip $strMask $gateway $dns1 $dns2 (getEthernetInterface)
}

function set-ip-wireless-wi-internal {
	$ip = "192.168.201.26"
	$strMask = "255.255.255.0"
	$gateway = "192.168.201.254"
	$dns1 = "8.8.8.8"
	$dns2 = "8.8.4.4"
	$networkInterface = "Wi-Fi 2"
	set-ip-static $ip $strMask $gateway $dns1 $dns2 $networkInterface
}

function set-ip-wireless-wi {
	$ip = "172.25.113.247"
	$strMask = "255.255.248.0"
	$gateway = "172.25.113.1"
	$dns1 = "8.8.8.8"
	$dns2 = "8.8.4.4"
	$networkInterface = "Wi-Fi 2"
	set-ip-static $ip $strMask $gateway $dns1 $dns2 $networkInterface
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

function set-ip-eth-williams-factory {
	$ip = "172.25.113.247"
	$strMask = "255.255.248.0"
	$gateway = "172.25.113.1"
	$dns1 = "8.8.8.8"
	$dns2 = "8.8.4.4"
	$networkInterface = "Ethernet"
	set-ip-static $ip $strMask $gateway $dns1 $dns2 $networkInterface
}

function Reset-IpStack {
	netsh int ip reset
	Restart-Computer
}