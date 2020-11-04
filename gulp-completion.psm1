$completions = @(
  '--help',
  '--version',
  '--gulpfile',
  '--cwd',
  '--verify',
  '--tasks',
  '--tasks-simple',
  '--tasks-json',
  '--tasks-depth',
  '--compact-tasks',
  '--sort-tasks',
  '--color',
  '--silent',
  '--continue',
  '--series',
  '--log-level'
);

$gulpCompleter = {
  param($wordToComplete, $commandAst, $cursorPosition)
  $command = $commandAst.ToString();
  $commandParts = $command.Split(' ');
  if ($commandParts.Length -eq 1) {
    $completions | ForEach-Object { $_ };
    $tasks = Get-GulpTasks;
    $tasks | ForEach-Object { $_ }
  } elseif ($commandParts.Length -eq 2 -and $cursorPosition -le $command.Length) {
    Complete-GulpWord2 -word $wordToComplete;
  }
}

Register-ArgumentCompleter -Native -CommandName gulp -ScriptBlock $gulpCompleter;

function Get-GulpTasks () {
  $options = gulp --tasks-simple;
  return $options | Where-Object { $_.Trim() -ne '' } | ForEach-Object { $_ };
}

function Complete-GulpWord2 ($word) {
  $completions | Where-Object {$_.ToUpper().Contains($word.ToUpper().Trim())} | ForEach-Object {
    $_
  }
  Get-GulpTasks | Where-Object {$_.ToUpper().Contains($word.ToUpper().Trim())} | ForEach-Object {
    $_
  }
}

function Complete-NvmVersions ($word) {
  $versions = Get-NvmVersions;
  $versions | Where-Object { $_.ToUpper().Contains($word.ToUpper().Trim())} | ForEach-Object {
    $_
  }
}