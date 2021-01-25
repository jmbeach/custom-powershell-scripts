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
  #>
  [CmdletBinding()]
  param (
      <#
       .PARAMETER filePath
         Path to the file to copy
      #>
      [Parameter(Mandatory)][string] $filePath,
      <#
       .PARAMETER destination
         Full path to the remote destination
      #>
      [Parameter(Mandatory)][string] $destination,
      <#
       .PARAMETER session
         Session instance used to copy the file
      #>
      [Parameter(Mandatory)][System.Management.Automation.Runspaces.PSSession] $session
  )
  Invoke-Command -Session $session -ScriptBlock {
    param($txt, $destination)
    [System.Io.File]::WriteAllText($destination, $txt);
  } -ArgumentList ([System.IO.File]::ReadAllText($filePath)), $destination;
}

function Get-ChildItemPretty ($dir) {
	if ($null -eq $dir) {
		$dir = '.'
	}

	$children = Get-ChildItem $dir;
	if ($null -eq $children) {return;}
	$dirs = $children | Where-Object {$_.PSIsContainer};
	$files = $children | Where-Object {-not $_.PSIsContainer};
	
  if ($null -ne $files) {
    Write-Host $files[0].Directory.FullName -BackgroundColor DarkGray -NoNewline;
	  Write-Host;
  } elseif ($null -ne $dirs -and $null -ne $dirs[0] -and $null -ne $dirs[0].Parent) {
    Write-Host $dirs[0].Parent.FullName -BackgroundColor DarkGray -NoNewline;
	  Write-Host;
	}
	
	$foreground = $host.ui.RawUI.ForegroundColor
	$host.ui.RawUI.ForegroundColor = 'Magenta';
	$dirs | Sort-Object {$_.Name} | Format-Wide -Property {$_.Name} -AutoSize;
	$host.ui.RawUI.ForegroundColor = $foreground;
	
	$files | Sort-Object {$_.Name} | ForEach-Object {
		Write-Host "  $($_.Name)";
	};
}

Set-Alias -Name ls -Value Get-ChildItemPretty -Option AllScope

function Sort-Numeric {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [object]$InputObject
  )

  End {
	$i = 0;
	$mapped = $input | Foreach-Object {
		$file = $_;
		$fileName = $file;
		if ($file.GetType().Name -eq 'FileInfo') {
			$fileName = $file.Name;
		}
		$r = [Regex]::new('(?<!mp)\d+');
		$match = $r.Match($fileName)
		$sortIndex = $i;
		if ($match.Success) {
			$sortIndex = [int]::Parse($match.Value);
		}

		$result = [psobject]@{
			Data = $file;
			Sort = $sortIndex;
		}

		$i++;
		return $result;
	}

	$mapped | Sort-Object -Property Sort | Foreach-Object { $_.Data };
  }
}