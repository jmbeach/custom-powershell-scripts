function Get-ProcessByPort ($port) {
  $connection = Get-NetTCPConnection -LocalPort $port
  return Get-Process -Id $connection.OwningProcess
}