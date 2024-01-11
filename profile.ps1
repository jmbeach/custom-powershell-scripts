# Makes completion work more like linux
Import-Module PSReadLine

# Set Tab to complete intstead of arrow keys
Set-PSReadLineKeyHandler -Key Tab -Function Complete

. $HOME/code/github/private-powershell-scripts/profile.ps1
Import-Module $HOME/code/github/custom-powershell-scripts/youtube.psm1
Import-Module $HOME/code/github/custom-powershell-scripts/aws.psm1
Import-Module $HOME/code/github/custom-powershell-scripts/anki.psm1

if (-not $env:AWS_REGION) {
  $env:AWS_REGION = 'us-east-1'
}
if (-not $env:AWS_PROFILE) {
  $env:AWS_PROFILE = 'jmbeach'
}
function prompt {
  Write-Host -NoNewline "[$env:AWS_PROFILE]" -ForegroundColor Green
  Write-Host -NoNewline " [$env:AWS_REGION]" -ForegroundColor Yellow
  Write-Host -NoNewline " $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1))";
  return " "
}

