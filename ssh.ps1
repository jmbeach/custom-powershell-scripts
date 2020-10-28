$sshCompleter = {
  param($wordToComplete, $commandAst, $cursorPosition)

  # is this the second parameter?
  $is2nd = 4 + $wordToComplete.length - $cursorPosition -eq 0;
  if ($is2nd) {
    Complete-HostName $wordToComplete
  }
}

function Get-SshHosts($sshFile) {
  if ($null -eq $sshFile) {
    $sshFile = "$home/.ssh/config";
  }

  $sshConfig = Get-Content $sshFile;
  $result = [System.Collections.Generic.List[object]]::new();
  $activeHost = $null;
  $sshConfig | ForEach-Object {
    $line = $_.ToString();
    # if the line doesn't start with whitespace, it's a host
    if ($line.TrimEnd() -eq $line.Trim() -and $line.Length -gt 0) {
      if ($null -ne $activeHost) {
        $result.Add($activeHost);
      }

      $activeHost = [psobject]::new();

      $activeHost | Add-Member -NotePropertyName 'name' -NotePropertyValue ($line.Trim() -split 'Host ')[1];
    } elseif ($line.Trim().StartsWith('User', 'CurrentCultureIgnoreCase')) {
      $activeHost | Add-Member -NotePropertyName 'user' -NotePropertyValue ($line.Trim() -split 'User ')[1];
    } elseif ($line.Trim().StartsWith('Hostname', 'CurrentCultureIgnoreCase')) {
      $activeHost | Add-Member -NotePropertyName 'hostname' -NotePropertyValue ($line.Trim() -split 'Hostname ')[1];
    } elseif ($line.Trim().StartsWith('Port', 'CurrentCultureIgnoreCase')) {
      $activeHost | Add-Member -NotePropertyName 'port' -NotePropertyValue ($line.Trim() -split 'Port ')[1];
    } elseif ($line.Trim().StartsWith('IdentityFile', 'CurrentCultureIgnoreCase')) {
      $activeHost | Add-Member -NotePropertyName 'identityFile' -NotePropertyValue ($line.Trim() -split 'IdentityFile ')[1];
    }
  }

  if ($null -ne $activeHost) {
    $result.Add($activeHost);
  }

  return $result;
}

function Complete-HostName($word) {
  $hostNames = (Get-SshHosts).name;
  $hostNames | Where-Object {
    $_.ToUpper() -like "*$($word.ToUpper())*"
  } | ForEach-Object {
    $_;
  }
}

Register-ArgumentCompleter -Native -CommandName ssh -ScriptBlock $sshCompleter;

# Making an exception for bad naming here because it's an alias for the actual unix command
# Inspired by https://www.chrisjhart.com/Windows-10-ssh-copy-id/
function Ssh-Copy-Id($i, $target) {
  if (![System.IO.File]::Exists($i)) {
    Write-Host -ForegroundColor Red -Object "Input file doesn't exist.";
    return;
  }

  Get-Content $i | ssh $target "cat >> .ssh/authorized_keys";
}