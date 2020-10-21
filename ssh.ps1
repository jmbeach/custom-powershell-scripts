$sshCompleter = {
  param($wordToComplete, $commandAst, $cursorPosition)

  # is this the second parameter?
  $is2nd = 4 + $wordToComplete.length - $cursorPosition -eq 0;
  if ($is2nd) {
    Complete-HostName $wordToComplete
  }
}

function Get-SshHostNames() {
  $sshConfig = Get-Content "$home/.ssh/config";
  $result = [System.Collections.Generic.List[string]]::new();
  $sshConfig | ForEach-Object {
    $line = $_.ToString();
    if (-not $line.StartsWith(" ") -and $line.Length -gt 0) {
      $result.Add($line.Split('Host ')[1]);
    }
  }

  return $result;
}

get-SshHostNames

function Complete-HostName($word) {
  $hostNames = Get-SshHostNames;
  $hostNames | Where-Object {
    $_.ToUpper() -like "*$($word.ToUpper())*"
  } | ForEach-Object {
    $_;
  }
}

Register-ArgumentCompleter -Native -CommandName ssh -ScriptBlock $sshCompleter;