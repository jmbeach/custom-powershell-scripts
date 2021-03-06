function Create-JoplinNote(
  [parameter(Mandatory = $true)][string]$baseUrl,
  [parameter(Mandatory = $true)][string]$apiKey,
  [parameter(Mandatory = $true)][string]$title,
  [parameter(Mandatory = $true)][string]$body,
  [string]$parent) {
  $fullUrl = "$baseUrl/notes?token=$apiKey";
  [PSCustomObject]$body = [PSCustomObject]@{
    title = $title;
    body = $body;
    parent = $parent;
  };
  $bodyJson = $($body | ConvertTo-Json)
  return Invoke-WebRequest -Uri $fullUrl -ContentType 'application/json' -Method Post -Body $bodyJson;
}

function Get-JoplinNoteSearch(
  [parameter(Mandatory = $true)][string]$baseUrl,
  [parameter(Mandatory = $true)][string]$apiKey,
  [parameter(Mandatory = $true)][string]$query) {
  $fullUrl = "$baseUrl/search?token=$apiKey&query=$query";
  return (Invoke-WebRequest -Uri $fullUrl -Method Get).Content | ConvertFrom-Json;
}