
function New-Shim($shimConfig) {
  $tmpFile = New-TemporaryFile;
  $tmpFileName = $tmpFile.FullName.Replace('.tmp', '.ps1');
  Move-Item $tmpFile $tmpFileName;
  $tmpFile = Get-Item $tmpFileName;
  $script = "
function global:$($shimConfig.name) {
  # tag: shim
  if (`$Args.Length -gt 0) {
    & `"$($shimConfig.path)`" `@Args;
  } else {
    & `"$($shimConfig.path)`";
  }";

  if ($shimConfig.devNull -eq $true) {
    $script += " | Out-Null;";
  }

  $script += "
}";
  $script | Out-File $tmpFile.FullName;
  & $tmpFile;
  Remove-Item $tmpFile;
}