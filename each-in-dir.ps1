function each-in-dir-to-jpg() {
	Get-ChildItem . -Filter * |
	ForEach-Object {
		$newName = $_.FullName + '.jpg'
		mv $_.FullName $newName
	}
}
