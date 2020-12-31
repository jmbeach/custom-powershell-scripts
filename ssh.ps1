$sshCompleter = {
  param($wordToComplete, $commandAst, $cursorPosition)

  # is this the second parameter?
  $is2nd = 4 + $wordToComplete.length - $cursorPosition -eq 0;
  if ($is2nd) {
    _Complete-HostName $wordToComplete
  }
}

class SshHost {
  [string]$Name;
  [string]$User;
  [string]$HostName;
  [int]$Port;
  [string]$IdentityFile
}

class SshConfig {

}

function ConvertFrom-SshConfigFile (
  <#
   .PARAMETER sshFile
     Path to ssh config file.
     If null, defaults to ~/.ssh/config
  #>
  $sshFile
) {
  <#
    .SYNOPSIS
      Converts an ssh config file into a list of powershell objects;
      each representing a host in the config.
    
    .DESCRIPTION
      Converts an ssh config file into a list of powershell objects
    
    .OUTPUTS
      Returns a list of powershell objects;
      each representing a host in the config.
      Null if no sshFile specified and the default path for one does not exist.
  #>
  if ($null -eq $sshFile) {
    $sshFile = "$home/.ssh/config";
  }

  if (-not (Test-Path $sshFile)) {
    return $null
  }

  $result = [System.Collections.Generic.List[SshHost]]::new();
  $sshHost = $null;

  # looping over the lines in the config file to incrementally build hosts/properties
  $reader = [System.IO.StreamReader]::new($sshFile)

  while ($null -ne ($line = $reader.ReadLine())) {
    # if the line doesn't start with whitespace, it's a host or entity
    if ($line.TrimEnd() -eq $line.Trim() -and $line.Length -gt 0) {
      # Add the previously built entity if one exists
      if ($null -ne $sshHost) {
        $result.Add($sshHost);
      }

      $sshHost = New-Object -TypeName SshHost -Property @{ Name = ($line.Trim() -split 'Host ')[1]; };

      # go straight to next line
      continue;
    }

    # Helper method for detecting properties of SshHosts
    function isProp([string]$propName) {
      return $line.Trim().StartsWith($propName, 'CurrentCultureIgnoreCase');
    }

    function parseProperty([string]$property) {
      return ($line.Trim() -split $property)[1].Trim();
    }

    $props = $sshHost.PSObject.Properties
    $props | ForEach-Object {
      $prop = $_;
      if (-not (isProp -propName $prop.Name)) {
        return;
      }

      $val = parseProperty -property $prop.Name;
      $typeName = $prop.TypeNameOfValue.ToLower().Replace('system.', '');
      switch ($typeName) {
        'string' { 
          $prop.Value = $val;
        }
        'int32' {
          $prop.Value = [int]::Parse($val);
        }
        Default {
          throw "Unexpected property type `"$typeName`"";
        }
      }
    }
  }

  <# The last host has to be added manually because the other hosts
     are added at the top of the loop #>
  if ($null -ne $sshHost) {
    $result.Add($sshHost);
  }

  return $result;
}

function _Complete-HostName() {
  # _ = private. TODO: Change if I decide to make this into a module and just don't export this function
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope = 'Function')]
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]
    $word
  )

  $hostNames = (ConvertFrom-SshConfigFile).name;
  $hostNames | Where-Object {
    $_.ToUpper() -like "*$($word.ToUpper())*"
  } | ForEach-Object {
    $_;
  }
}

Register-ArgumentCompleter -Native -CommandName ssh -ScriptBlock $sshCompleter;

# Inspired by https://www.chrisjhart.com/Windows-10-ssh-copy-id/
function Ssh-Copy-Id {
  # Making an exception for bad naming here because it's an alias for the actual unix command
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope = 'Function')]
  [CmdletBinding()]
  param (
    [Parameter(Required = $true)][string] $target,
    <#
       .PARAMETER identityFile
         Name/path to the identity file you want to copy to the host.
         Defaults to ~/.ssh/id_rsa.pub
      #>
    [Parameter(Required = $false)][string] $identityFile
  )

  if ($null -eq $identityFile) {
    $identityFile = "$($env:USERPROFILE)\.ssh\id_rsa.pub"
  }

  if (!$identityFile.EndsWith('.pub')) {
    $identityFile = "$identityFile.pub"
  }

  if (![System.IO.File]::Exists($identityFile)) {
    Write-Host -ForegroundColor Red -Object "Identity file specified doesn't exist: `"$identityFile`".";
    return;
  }

  Get-Content $identityFile | ssh $target "cat >> .ssh/authorized_keys";
}