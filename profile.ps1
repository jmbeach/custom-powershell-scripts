. $HOME/code/github/private-powershell-scripts/profile.ps1
Import-Module $HOME/code/github/custom-powershell-scripts/youtube.psm1
Import-Module $HOME/code/github/custom-powershell-scripts/aws.psm1

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

