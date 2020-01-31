function c-sharp-delete-bins() {
	Get-ChildItem .\ -include bin,obj -Recurse | foreach ($_) { 
		if (!$_.fullname.Contains('Web')) { 
			rm -rf $_.fullname 
		} 
	}
}
