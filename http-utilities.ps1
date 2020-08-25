function Get-HttpBasicAuthHeader($username) {
  if ($null -eq $username) {
    $username = Read-Host 'Username';
  }

  $password = Read-Host 'Password' -AsSecureString;

  $username64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($username));
  $password64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(($password | ConvertFrom-SecureString)));
  return $('Basic ' + $username64 + ':' + $password64);
}