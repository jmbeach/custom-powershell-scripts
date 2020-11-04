$completions = @(
  'list',
  'on',
  'off',
  'proxy',
  'node_mirror',
  'npm_mirror',
  'uninstall',
  'use',
  'root',
  'version'
);

$nvmCompleter = {
  param($wordToComplete, $commandAst, $cursorPosition)
  $command = $commandAst.ToString();
  $commandParts = $command.Split(' ');
  if ($commandParts.Length -eq 1) {
    $completions | ForEach-Object { $_ };
  } elseif ($commandParts.Length -eq 2 -and $cursorPosition -le $command.Length) {
    Complete-NvmWord2 -word $wordToComplete;
  } elseif ($commandParts.Length -lt 4) {
    $subCommand = $commandParts[1];
    if ($subCommand -eq 'use') {
      Complete-NvmVersions -word $wordToComplete;
    }
  }
}

Register-ArgumentCompleter -Native -CommandName nvm -ScriptBlock $nvmCompleter;

function Get-NvmVersions () {
  $options = nvm list;
  $options = $options | Where-Object { $_.Trim() -ne '' };
  $result = [System.Collections.Generic.List[string]]::new();
  $options | ForEach-Object {
    $r = [regex]::new('\d+\.\d+\.\d+');
    $version = $r.Matches($_).Value;
    $result.Add($version);
  }

  return $result;
}

function Complete-NvmWord2 ($word) {
  $completions | Where-Object {$_.ToUpper().Contains($word.ToUpper().Trim())} | ForEach-Object {
    $_
  }
}

function Complete-NvmVersions ($word) {
  $versions = Get-NvmVersions;
  $versions | Where-Object { $_.ToUpper().Contains($word.ToUpper().Trim())} | ForEach-Object {
    $_
  }
}