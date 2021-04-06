# An interface for logging. Other classes should inherit and override methods
class IWriteLogParams {
  [object]$Object;
  [object]$Separator
  [Nullable[ConsoleColor]] $ForegroundColor = $null
  [ConsoleColor]$BackgroundColor
  [bool]$NoNewLine
}
class ILogger {
  [void] WriteLog([IWriteLogParams]$logParams) {}
  [void] WriteError([IWriteLogParams]$logParams) {}
}

class ConsoleLogger : ILogger {
  [void] _writeLog([IWriteLogParams]$logParams, [string]$logType) {
    if ($null -eq $logParams) {
      Write-Host;
      return;
    }

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

    if (-not $logParams.NoNewLine) {
      Write-Host;
    }
  }

  [void] WriteLog([IWriteLogParams]$logParams) {
    if ($null -eq $logParams.ForegroundColor) {
      $logParams.ForegroundColor = [ConsoleColor]::White;
    }

    $this._writeLog($logParams, "INFO");
  }

  [void] WriteError([IWriteLogParams]$logParams) {
    if ($null -eq $logParams.ForegroundColor) {
      $logParams.ForegroundColor = [ConsoleColor]::Red;
    }
    
    $this._writeLog($logParams, "ERROR");
  }
}

class FileLogger: ILogger {
  [string]$file;
  FileLogger($file) {
    $this.file = $file;
  }

  [void] _writeLog([IWriteLogParams]$logParams, [string]$logType) {
    if ($null -eq $logParams) {
      return;
    }

    $logText = $logParams.Object;
    if ($logParams.Object.GetType().Name.Contains("[]") -and $null -ne $logParams.Separator) {
      $logText = [string]::Join($logParams.Separator, $logParams.Object);
    }

    $arguments = @{
      Append=$true;
      FilePath=$this.file;
    }

    if ($logParams.NoNewLine) {
      $arguments.Add("NoNewLine", $logParams.NoNewLine);
    }

    "$([System.DateTime]::Now.ToString("MM-dd-yyyy HH:mm:ss")) - $logType - $logText" | Out-File @arguments;
  }

  [void] WriteLog([IWriteLogParams]$logParams) {
    $this._writeLog($logParams, "INFO");
  }

  [void] WriteError([IWriteLogParams]$logParams) {
    $this._writeLog($logParams, "ERROR");
  }
}

class MultiTargetLogger: ILogger {
  [ILogger[]]$loggers;
  MultiTargetLogger([ILogger[]]$loggers) {
    $this.loggers = $loggers;
  }

  [void] WriteLog([IWriteLogParams]$logParams) {
    $this.loggers | ForEach-Object {
      $_.WriteLog($logParams);
    }
  }

  [void] WriteError([IWriteLogParams]$logParams) {
    $this.loggers | ForEach-Object {
      $_.WriteError($logParams);
    }
  }
}