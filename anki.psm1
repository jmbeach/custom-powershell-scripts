$ANKI_URL = 'http://localhost:8765'
$headers = @{
  'Content-Type' = 'application/json'
}
function Get-AnkiCards([string]$query) {
  if ($query -match '^\w+:.*\s+.*$') {
    $parts = $query.split(":")
    $query = "$($parts[0]):`"$($parts[1])`""
  }
  $body = @{
    action = 'findCards';
    version = 6;
    params = @{
      query = $query
    }
  } | ConvertTo-Json
  return (Invoke-WebRequest -Method Post -Uri $ANKI_URL -Headers $headers -Body $body).Content | ConvertFrom-Json
}