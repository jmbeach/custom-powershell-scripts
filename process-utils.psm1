<#
  .SYNOPSIS
    Polls for a process to be running by name.
    Once it finds the process, it returns the System.Diagnostics.Process object.

  .OUTPUTS
    System.Diagnostics.Process object;

  .EXAMPLE
    $myProcess = Capture-RunningProcess msbuild
    # run build in visual studio now, and you'll be able to see all of the details
    # of msbuild in the $myProcess object (including the path to the executable).
#>
function Capture-RunningProcess {
  [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseApprovedVerbs', '')]

  [CmdletBinding()]
  param (
    <#
     .PARAMETER ProcessName
       The name of the process to capture the details of
    #>
    [Parameter()][string]$ProcessName
  )

  Write-Host "Attempting to capture process $ProcessName. Press ctrl-c to exit.";
  while ($true) {
    $process = Get-Process $ProcessName -ErrorAction SilentlyContinue;

    if ($null -ne $process) {
      Write-Host -ForegroundColor DarkGreen 'Success';
      return $process;
    }

    Start-Sleep -Seconds 1;
  }
}

function Get-ServicesDetailed {
  Get-Service | ForEach-Object {
    # convert to psobject
    $service = $_ | ConvertTo-Json | ConvertFrom-Json;
    $service | Add-Member -NotePropertyName 'ServiceDll' -NotePropertyValue $null;
    $match = Get-ChildItem HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)
    if ($null -ne $match) {
      if ($null -ne ($match.Property | Where-Object {$_ -eq 'ServiceDll'})) {
        if ($match.Length -gt 0) {
          $match = $match[0];
        }

        $serviceDll = $match.GetValue('ServiceDll');
        $service.ServiceDll = $serviceDll;
      }
    }

    return $service;
  }
}