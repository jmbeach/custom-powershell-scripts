$sshCompleter = {
  param($wordToComplete, $commandAst, $cursorPosition)

  # is this the second parameter?
  $is2nd = 4 + $wordToComplete.length - $cursorPosition -eq 0;
  if ($is2nd) {
    Complete-HostName $wordToComplete
  }
}

function Get-SshHosts() {
  $sshConfig = Get-Content "$home/.ssh/config";
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

      $activeHost | Add-Member -NotePropertyName 'name' -NotePropertyValue $line.Split('Host ')[1];
    } elseif ($line.Trim().StartsWith('User')) {
      $activeHost | Add-Member -NotePropertyName 'user' -NotePropertyValue $line.Trim().Split('User ')[1];
    } elseif ($line.Trim().StartsWith('Hostname')) {
      $activeHost | Add-Member -NotePropertyName 'hostname' -NotePropertyValue $line.Trim().Split('Hostname ')[1];
    } elseif ($line.Trim().StartsWith('Port')) {
      $activeHost | Add-Member -NotePropertyName 'port' -NotePropertyValue $line.Trim().Split('Port ')[1];
    } elseif ($line.Trim().StartsWith('IdentityFile')) {
      $activeHost | Add-Member -NotePropertyName 'identityFile' -NotePropertyValue $line.Trim().Split('IdentityFile ')[1];
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