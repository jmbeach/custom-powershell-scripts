# An interface for logging. Other classes should inherit and override methods
class IWriteLogParams {
  [object]$Object;
  [object]$Separator
  [ConsoleColor]$ForegroundColor
  [ConsoleColor]$BackgroundColor
  [bool]$NoNewLine
}
class ILogger {
  [void] WriteLog([IWriteLogParams]$logParams) {}
}

class ConsoleLogger : ILogger {
  [void] WriteLog([IWriteLogParams]$logParams) {
    if ($null -eq $logParams) {
      Write-Host;
      return;
    }

    if ($null -eq $logParams.ForegroundColor) {
      $logParams.ForegroundColor = [ConsoleColor]::White;
    }

    [scriptBlock]$doWrite = {
      if ($null -eq $logParams.ForegroundColor -and $null -eq $logParams.BackgroundColor) {
        Write-Host -Object $logParams.Object -NoNewline -Separator $logParams.Separator;
      }
      elseif ($null -eq $logParams.ForegroundColor) {
        Write-Host -Object $logParams.Object -NoNewline -Separator $logParams.Separator -BackgroundColor $logParams.BackgroundColor;
      }
      elseif ($null -eq $logParams.BackgroundColor) {
        Write-Host -Object $logParams.Object -NoNewline -Separator $logParams.Separator -ForegroundColor $logParams.ForegroundColor;
      }
      else {
        Write-Host -Object $logParams.Object -NoNewline -Separator $logParams.Separator -ForegroundColor $logParams.ForegroundColor -BackgroundColor $logParams.BackgroundColor;
      }
    }

    Invoke-Command $doWrite;
    if (-not $logParams.NoNewLine) {
      Write-Host;
    }
  }
}