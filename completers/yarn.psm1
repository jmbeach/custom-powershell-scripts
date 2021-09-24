$commands = @(
  'access',
  'add',
  'audit',
  'autoclean',
  'bin',
  'cache',
  'check',
  'config',
  'create',
  'exec',
  'generate-lock-entry',
  'generateLockEntry',
  'global',
  'help',
  'import',
  'info',
  'init',
  'install',
  'licenses',
  'link',
  'list',
  'login',
  'logout',
  'node',
  'outdated',
  'owner',
  'pack',
  'policies',
  'publish',
  'remove',
  'run',
  'tag',
  'team',
  'unlink',
  'unplug',
  'upgrade',
  'upgreade-interactive',
  'upgradeInteractive',
  'version',
  'versions',
  'why',
  'workspace',
  'workspaces'
)
$scriptblock = {
  param($wordToComplete, $commandAst, $currentPosition);
  $command = $commandAst.ToString();
  $commandParts = $command.Split(' ');
  if ($commandParts.Length -eq 1) {
    $commands
    Get-YarnProjectCommands
  } elseif ($commandParts.Length -eq 2) {
    $commands | Where-Object { "*$_*" -like "*$wordToComplete*" }
    Get-YarnProjectCommands | Where-Object { "*$_*" -like "*$wordToComplete*" }
  }
}
Register-ArgumentCompleter -Native -CommandName yarn -ScriptBlock $scriptblock;

function Get-YarnProjectCommands () {
  $result = [System.Collections.Generic.List[string]]::new();
  yarn run --json 2>$null | ForEach-Object {
    $line = $_ | ConvertFrom-Json;
    if ($line.data.PSObject.TypeNames -contains 'System.String') {
      if ($line.data.Contains('Commands available from binary scripts: ')) {
        $result.AddRange($line.data.Replace('Commands available from binary scripts: ', '').Split(', '));
      }
    } else {
      $line.data.items | ForEach-Object {
        if ($_.StartsWith('{')) {
          return;
        }
        $result.Add($_);
      }
    }
  }
  return $result;
}