function ssh-yfaidev () {
	Enter-PSSession -ComputerName 192.168.200.24 -Credential Administrator
}
function ssh-yfaitest () {
	Enter-PSSession -ComputerName 192.168.200.204 -Credential Administrator
}
