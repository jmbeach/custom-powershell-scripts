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
  [System.Nullable[int]]$Port;
  [string]$IdentityFile
}

class SshConfig {
  [System.Collections.Generic.List[SshHost]]$Hosts;
  [string]$IdentityFile;
}

class SshPropertyParser {
  [boolean]isProp($line, $propertyName) {
    return $line.Trim().StartsWith($propertyName, 'CurrentCultureIgnoreCase');
  }

  [string]parse($line, $propertyName, $propertyType) {
    $val = ($line.Trim() -split $propertyName)[1].Trim();
    $typeName = [System.Text.RegularExpressions.RegEx]::new('(?:string|int32)').Matches($propertyType.ToLower())[0].Value;
    switch ($typeName) {
      'string' { 
        return $val;
      }
      'int32' {
        return [int]::Parse($val);
      }
      Default {
        throw "Unexpected property type `"$typeName`"";
      }
    }

    throw "Unknown error parsing property";
  }
}

class SshHostParser {
  [System.IO.TextReader]$reader;

  SshHostParser([System.IO.TextReader]$reader) {
    $this.reader = $reader;
  }

  [boolean]isHostLine() {
    # space = 32. If the line starts with whitespace, it's a host property
    return 32 -eq $this.reader.Peek();
  }

  [SshHost]parse ([string]$line) {
    $sshHost = New-Object -TypeName SshHost -Property @{ Name = ($line.Trim() -split 'Host ')[1]; };
    $propParser = [SshPropertyParser]::new();

    while ($this.isHostLine()) {
      $line = $this.reader.ReadLine();
      $props = $sshHost.PSObject.Properties;
      $props | ForEach-Object {
        $prop = $_;
        if (-not $propParser.isProp($line, $prop.Name)) {
          return;
        }

        $prop.Value = $propParser.parse($line, $prop.Name, $prop.TypeNameOfValue);
      }
    }
    
    return $sshHost;
  }
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
    
    .OUTPUTS
      Returns a list of powershell objects;
      each representing a host in the config.
      Null if no sshFile specified and the default path for one does not exist.
  #>
  if ($null -eq $sshFile) {
    $sshFile = "$home/.ssh/config";
  }

  if (-not (Test-Path $sshFile)) {
    throw "No ssh file found. Tried to use `"$sshFile`"."
  }

  $result = [SshConfig]::new()

  # looping over the lines in the config file to incrementally build hosts/properties
  $reader = [System.IO.StreamReader]::new($sshFile);
  $hostParser = [SshHostParser]::new($reader);
  $propParser = [SshPropertyParser]::new();

  while ($null -ne ($line = $reader.ReadLine())) {
    if ($hostParser.isHostLine()) {
      if ($null -eq $result.Hosts) {
        $result.Hosts = [System.Collections.Generic.List[SshHost]]::new();
        }

        $result.Hosts.Add($hostParser.parse($line));
        continue;
    }

    # if it's not a host line, it's a global setting
    $props = $result.PSObject.Properties | Where-Object { $_.Name -ne 'Hosts' };
    $props | ForEach-Object {
      $prop = $_;
      if (-not $propParser.isProp($line, $prop.Name)) {
        return;
      }

      $prop.Value = $propParser.parse($line, $prop.Name, $prop.TypeNameOfValue);
    }
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