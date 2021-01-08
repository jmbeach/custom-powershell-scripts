function findProgram ([string] $programName) {
	Get-ChildItem -Path $programFiles -Recurse -Include $("*" + $programName + "*.exe")
	Get-ChildItem -Path $programFiles86 -Recurse -Include $("*" + $programName + "*.exe")
	Get-ChildItem -Path $programFiles86D -Recurse -Include $("*" + $programName + "*.exe")
	Get-ChildItem -Path $programFilesD -Recurse -Include $("*" + $programName + "*.exe")
	Get-ChildItem -Path $appDataLocal -Recurse -Include $("*" + $programName + "*.exe")
}

function Write-SpacesOverTabs([string] $fileName, [int] $spaceCount) {
	if (!$spaceCount -eq 0) {
		(Get-Content $fileName).Replace("`t", "    ") | Out-File $fileName -Encoding ascii
		return
	}

	$strTab = "";
	
	for ($i = 0; $i -lt $spaceCount; $i = $i + 1) {
		$strTab += " "
	}

	(Get-Content $fileName).Replace("`t", $strTab) | Out-File $fileName -Encoding ascii
	return
}

function Write-ShortenedSpaceTabs([string] $fileName) {
	(Get-Content $fileName).Replace("    ", "  ") | Out-File $fileName -Encoding ascii
	return
}

function Write-UnixNewlines([string] $fileName) {
	(Get-Content $fileName).Replace("`r`n", "`n") | Out-File $fileName -Encoding ascii
	return
}

function Write-DosNewlines([string] $fileName) {
	(Get-Content $fileName).Replace("`n", "`r`n") | Out-File $fileName -Encoding ascii
	return
}

function Convert-FileEncodingAscii($fileName) {
	$backupName = $fileName + ".bak"
	Move-Item $fileName $backupName
	Get-Content $backupName | Out-File $fileName -Encoding ascii
	Remove-Item $backupName
}

function Convert-FileToGmailSendable([string] $fileName) {
	$newName = $fileName.Replace("exe", "abc")
	$finalName = $fileName.Replace("exe", "123")
	$zipName = $fileName.Replace("exe", "zip")

	Copy-Item $fileName $newName

	7z a "$zipName" "$newName"

	Copy-Item $zipName $finalName
}

function Get-ProgramsOnPath() {
	$($env:PATH).Split(';') | ForEach-Object { dir $_ *.exe } | ForEach-Object { $_.Name + ' - ' + $_.Directory } | sort
}

function Convert-HtmlToPlainText([string] $content) {
	return $content -replace '<[^>]+>',''
}

function Get-LockingProcess($file) {
	handle | select-string $file -Context 3
}

function Get-Base64StringFromFile($file) {
	$bytes = [System.IO.File]::ReadAllBytes($file);
	return [System.Convert]::ToBase64String($bytes);
}

function Copy-ItemRemote {
  <#
    .SYNOPSIS
      Copies a file to a remote destination via a powershell session
  
    .DESCRIPTION
      Useful for copying files from a powershell v5+ instance to a
      powershell <v5 powershell instance.

      Inspired by inspired by https://social.technet.microsoft.com/Forums/en-US/64a3d37c-9828-4feb-817a-d28e7a147f25/copy-file-from-local-to-remote?forum=winserverpowershell
  
    .EXAMPLE
      Copy-Item ./to-copy.txt c:\my-destination $session
  
    .LINK
      link to further docs
  #>
  [CmdletBinding()]
  param (
      <#
       .PARAMETER filePath
         Path to the file to copy
      #>
      [Parameter()][string] $filePath,
      <#
       .PARAMETER destination
         Full path to the remote destination
      #>
      [Parameter()][string] $destination,
      <#
       .PARAMETER session
         Session instance used to copy the file
      #>
      [Parameter()][PSSession] $session
  )
  Invoke-Command -Session $session -ScriptBlock {
    param($txt)
    [System.Io.File]::WriteAllText($destination, $txt);
  } -ArgumentList ([System.IO.File]::ReadAllText($filePath));
}