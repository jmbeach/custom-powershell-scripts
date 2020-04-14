function _buildBasicAuth([string]$urserName, [string]$apiKey) {
  return 'Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$userName`:$apiKey"));
}

function Get-JiraSearchJql(
  [parameter(Mandatory=$true)][string]$baseUrl,
  [parameter(Mandatory=$true)][string]$jqlSearch,
  [parameter(Mandatory=$true)][string]$userName,
  [parameter(Mandatory=$true)][string]$apiKey
) {
  $fullUrl = "$baseUrl/rest/api/2/search?jql=$([uri]::EscapeDataString($jqlSearch))";
  $headers = @{
    authorization = _buildBasicAuth $userName $apiKey;
    accept = 'application/json'
  };

  return (Invoke-WebRequest -Uri $fullUrl -Headers $headers).Content | ConvertFrom-Json;
}

function Get-JiraTicket(
  [parameter(Mandatory=$true)][string]$baseUrl,
  [parameter(Mandatory=$true)][string]$ticketNumber,
  [parameter(Mandatory=$true)][string]$userName,
  [parameter(Mandatory=$true)][string]$apiKey) {
  $fullUrl = "$baseUrl/rest/api/2/issue/$ticketNumber";
  $headers = @{
    authorization = _buildBasicAuth $userName $apiKey;
    accept = 'application/json'
  };

  return (Invoke-WebRequest -Uri $fullUrl -Headers $headers).Content | ConvertFrom-Json;
};