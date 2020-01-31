function map-drive-yf-dev ($driveName) {
	$strDrive = "$driveName`:"
	net use $strDrive \\192.168.200.24\d$ /user:Administrator
}
