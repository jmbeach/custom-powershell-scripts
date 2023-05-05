
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