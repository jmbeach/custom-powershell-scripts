function Get-SqlConnection($connectionString) {
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMOExtended") | Out-Null
	$conn = New-Object Microsoft.SqlServer.Management.Common.ServerConnection
	$conn.ConnectionString = $connectionString
	$server = New-Object Microsoft.SqlServer.Management.Smo.Server $conn
	if ($null -eq $server.Version) { Throw "Can't find the instance $Datasource" }
	$db = $server.Databases[$conn.SqlConnectionObject.Database]
	if ($null -eq $db) { Throw "Can't find the database" }
	return $db
}

function Get-SqlExportPath() {
	$filepath="$env:USERPROFILE\DatabaseBackups"
	if (!$(Test-Path $filepath)) { mkdir $filepath}
	return $filepath
}

function Get-SqlTransferOptions([string]$filePath, $db, [string]$fileSuffix, [boolean]$includeSchema, [boolean]$includeData) {
	$transfer = New-Object Microsoft.SqlServer.Management.Smo.Transfer $db
	$transfer.Options.ScriptBatchTerminator = $true
	$transfer.Options.ToFileOnly = $true
	$transfer.Options.Filename = "$($filePath)\$($db.Name)_$($fileSuffix).sql"
	$transfer.Options.ScriptSchema = $includeSchema
	$transfer.Options.ScriptData = $includeData
	return $transfer
}

function Start-SqlTransfer($truansfer) {
	try {
		$transfer.EnumScriptTransfer()
	}
	catch [System.Exception] {
		$_.Exception
		if ($_.Exception.InnerException) {
			$_.Exception.InnerException
			return
		}
	}

	Write-Host -ForegroundColor Green "Success"
}

function Convert-FileEncodingAscii($fileName) {
	$backupName = $fileName + ".bak"
	Move-Item $fileName $backupName
	Get-Content $backupName | Out-File $fileName -Encoding ascii
	Remove-Item $backupName
}

function Export-SqlSchema($connectionString) {
	$filePath = Get-SqlExportPath
	$ErrorActionPreference = "stop"
	$db = Get-SqlConnection $connectionString
	$transfer = Get-SqlTransferOptions $filePath $db "Schema" $true $false
	Start-SqlTransfer $transfer
	Convert-FileEncodingAscii($transfer.Options.Filename)
}

function Export-SqlData($connectionString) {
	$filePath = Get-SqlExportPath
	$ErrorActionPreference = "stop"
	$db = Get-SqlConnection $connectionString
	$transfer = Get-SqlTransferOptions $filePath $db "Data" $false $true
	Start-SqlTransfer $transfer
	Convert-FileEncodingAscii($transfer.Options.Filename)
}