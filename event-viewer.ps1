function Get-EventViewerSystemErrorsFromToday() {
  return Get-WinEvent -FilterHashtable @{logname='system'; level=2; StartTime=(Get-Date).date}
}

function Get-EventViewerApplicationErrorsFromToday() {
  return Get-WinEvent -FilterHashtable @{logname='application'; level=2; StartTime=(Get-Date).date}
}