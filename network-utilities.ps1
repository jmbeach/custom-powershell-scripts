function Get-ProcessByPort ($port) {
  if ($IsMacOS) {
    $result = netstat -vanp tcp | Select-String $port;
    $isInt = $false;
    $numbers = $result -split '\s+' | Where-Object { [Int]::TryParse($_, [ref]$isInt) -and $_ -ne '0' }
    $foundPid = $numbers[-1];
    return Get-Process -Id $foundPid
  } else {
    $connection = Get-NetTCPConnection -LocalPort $port
    return Get-Process -Id $connection.OwningProcess
  }
}

function Scan-PortsForProcesses($startingPort, $endingPort) {
  for ($i = $startingPort; $i -le $endingPort; $i++) {
    try {
      Get-ProcessByPort $i
    }
    catch {}
  }
}