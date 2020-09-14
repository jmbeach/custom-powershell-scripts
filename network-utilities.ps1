function Get-ProcessByPort ($port) {
  $connection = Get-NetTCPConnection -LocalPort $port
  return Get-Process -Id $connection.OwningProcess
}

function Scan-PortsForProcesses($startingPort, $endingPort) {
  for ($i = $startingPort; $i -le $endingPort; $i++) {
    try {
      Get-ProcessByPort $i
    }
    catch {}
  }
}