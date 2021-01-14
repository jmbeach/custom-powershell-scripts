
function New-Shim($shimConfig) {
  $tmpFile = New-TemporaryFile;
  $tmpFileName = $tmpFile.FullName.Replace('.tmp', '.ps1');
  Move-Item $tmpFile $tmpFileName;
  $tmpFile = Get-Item $tmpFileName;
  "
function global:$($shimConfig.name) {
  # tag: shim
  & `"$($shimConfig.path)`" $args;
}" | Out-File $tmpFile.FullName;
  & $tmpFile;
  Remove-Item $tmpFile;
}