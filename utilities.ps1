function Search-C-FileName([string] $fileName, [string] $fileType)
{
  if (!($fileType -eq ''))
  {
    Get-ChildItem -Path C:\ -Filter *$fileName* -Include *.$fileType -Recurse
  } else
  {
    Get-ChildItem -Path C:\ -Filter *$fileName* -Recurse
  }
}

function Search-Registry($search)
{
  Get-ChildItem HKCU: -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSPath -like $search }
  Get-ChildItem HKLM: -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSPath -like $search }
}

function ConvertFrom-HashTable($inputObject)
{
  $result = [psobject]::new();
  $inputObject.Keys | ForEach-Object {
    $key = $_;
    $value = $inputObject[$key]
    $result | Add-Member -NotePropertyName $key -NotePropertyValue $value;
  }

  return $result;
}

function Convert-Pdfs2Txt ()
{
  Get-ChildItem *.pdf | ForEach-Object { python C:\Python27\Scripts\pdf2txt.py $_.Name | Out-File -Encoding ascii $($_.Name + '.txt') }
}

function Convert-ObjectToHash ($asObj)
{
  $result = @{ };
  $asObj.PSObject.Properties | ForEach-Object {
    $result[$_.Name] = $_.Value;
  }
}

function Convert-Htmls2Txt ()
{
  Get-ChildItem -r *.html | ForEach-Object { pandoc $_.Name -o $($_.Name + '.txt') }
}

function Convert-Pdf2Txt ()
{
  python C:\Python27\Scripts\pdf2txt.py $1 | Out-File -Encoding ascii $($1 + '.txt') 
}

function Get-Colors ()
{
  [Enum]::GetValues([System.ConsoleColor]) | ForEach-Object {
    $colorName = $_;
    if ($colorName.ToString().StartsWith('Dark') -and $colorName.ToString() -ne 'DarkYellow')
    {
      Write-Host -BackgroundColor $colorName $colorName
    } else
    {
      Write-Host -BackgroundColor $colorName -ForegroundColor Black $colorName
    }
  }
}

function Get-EmojiShrug ()
{
  Get-Content $home\shrug.txt
}

function Get-Randomizer ()
{
  [string]$seedString = [System.DateTime]::Now.Ticks.ToString();
  $length = 9;
  $smaller = $seedString.Substring($seedString.Length - $length, $length);
  $seed = [System.Convert]::ToInt32($smaller) - $i;
  $rand = [System.Random]::new($seed);
  return $rand;
}

function Get-RandomText ($length = 10, [switch]$alphaNumeric = $false, [switch]$numeric = $false, [switch]$alpha = $false)
{
  $text = '';
  $nonAlphaNumeric = @(
    58, 59, 60, 61, 62, 63, 64, 91, 92, 93, 94, 95, 96
  );

  for ($i = 0; $i -lt $length; $i++)
  {
    $start = 32;
    $end = 126;
    if ($alphaNumeric)
    {
      $start = 48;
      $end = 122;
    } elseif ($numeric)
    {
      $start = 48;
      $end = 57;
    } elseif ($alpha)
    {
      $start = 65;
      $end = 122;
    }

    $rand = Get-Randomizer;
    $rando = $rand.Next($start, $end);

    # re-roll
    while (($alphaNumeric -or $alpha) -and $nonAlphaNumeric.Contains($rando))
    {
      $rand = Get-Randomizer;
      $rando = $rand.Next($start, $end);
    }

    $text += [System.Convert]::ToChar($rando);
  }

  return $text;
}

function Get-RunningProcessCount ()
{
  $i = 0
  tasklist | sort | foreach { $i = $i + 1 }
  Write-Host $i
}

function Kill-NonDefault ()
{
  $baseDir = "$HOME/code/github/custom-powershell-scripts";
  $defaultProcesses = Get-Content "$baseDir/default-processes.txt" | ForEach-Object { $_.ToUpper() };
  if ($IsMacOS)
  {
    $defaultProcesses = Get-Content "$baseDir/default-processes-mac.txt" | ForEach-Object { $_.ToUpper() };
  }

  $processes = $processes | Where-Object {
    -not [string]::IsNullOrEmpty($_.Path) -and -not $defaultProcesses.Contains($_.Path.ToUpper())
  }

  If ($IsWindows)
  {
    Write-Information "Getting services..."
    $defaultServices = Get-Content "$baseDir/default-services.txt" | ForEach-Object { $_.ToUpper() };
    $services = Get-Service -ErrorAction SilentlyContinue | Where-Object {
      $svc = $_;
      # Filter out services in default services list (don't want to kill them)
      return $svc.Status -eq "Running" -and $null -eq ($defaultServices | Where-Object { $svc.Name -Like $_ })
    }
    Write-Information "Found $($services.Length) potential services to kill"

    $services | ForEach-Object {
      $continue = Read-Host "Kill service $($_.Name) ($($_.Path ?? $_.BinaryPathName))? [y/n]"
      if ($continue.ToUpper() -eq "Y")
      {
        Write-Information "Stopping service $($_.Name)..."
        net stop $_.Name /yes
        Write-Information "Service $($_.Name) stopped"
      }
    }
  }
  
  Write-Information "Getting processes..."
  $processes = Get-Process -ErrorAction SilentlyContinue `
    | Sort-Object Name `
    | Get-Unique `
    | Where-Object { -not $defaultProcesses.Contains($_.Name.ToUpper()) }
  Write-Information "Found $($processes.Length) potential processes to kill"

  $processes | ForEach-Object {
    $continue = Read-Host "Kill process $($_.name) ($($_.Path))? [y/n]"
    if ($continue.ToUpper() -eq "Y")
    {
      Write-Information "Stopping process $($_.name)..."
      $_ | Stop-Process -Force
      Write-Information "Process $($_.name) stopped"
    }
  }

  $continue = Read-Host "Would you like to kill wsl as well? [y/n]"
  if ($continue.ToUpper() -eq "Y")
  {
    Write-Information "Stopping wsl..."
    wsl --shutdown
    Write-Information "wsl stopped"
  }
}

function Destroy-SearchUI
{
  Get-Process SearchUI | Stop-Process
  Move-Item "C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy\" "C:\Windows\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy.bak" -Force
}

function Kill-Vmware
{
  taskkill /F /IM vmware*
}

function Get-UserGroups($userName)
{
	(New-Object System.DirectoryServices.DirectorySearcher("(&(objectCategory=User)(samAccountName=$($userName)))")).FindOne().GetDirectoryEntry().memberOf
}

function Get-Wallpapers()
{
  $location = "$HOME\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"
  dir $location | foreach {
    if ($_.Length -lt 100kb)
    { return 
    }
    cp $_.FullName $("$home\Pictures\Wallpapers\" + $_.Name + ".jpg");
  }
}

function Write-Tabular([array]$list, [scriptblock]$highlightExpression, $headerUnderlineColor, $highlightColor, $alternateRowColor=$false, $debug = $false)
{
  $first = $list[0];
  $members = $first | Get-Member | Where-Object { $_.MemberType -ne 'Method' };

  if ($null -eq $headerUnderlineColor)
  {
    $headerUnderlineColor = 'Blue';
  }

  if ($null -eq $highlightColor)
  {
    $highlightColor = 'Blue';
  }

  function getTextSize ($text)
  {
    if (-not $IsWindows)
    {
      return $text.Length;
    }
		
    $font = [System.Drawing.Font]::new('Meslo LG M for Powerline', 16, [System.Drawing.FontStyle]::Regular);
    return [System.Windows.Forms.TextRenderer]::MeasureText($text, $font).width;
  }

  $writingDetails = @{ };
  for ($i = 0; $i -lt $members.Length; $i++)
  {
    $member = $members[$i];
    $writingDetails[$member.Name] = @{
      maxLength = getTextSize($member.Name);
    }
  }

  $list | ForEach-Object {
    $item = $_;
    $members | ForEach-Object {
      $member = $_;
      $details = $writingDetails[$member.Name];
      $size = getTextSize($item.PSObject.Properties[$member.Name].Value.ToString());
      $maxLength = $details.maxLength
      if ($size -gt $maxLength)
      {
        $writingDetails[$member.Name].maxLength = $size;
      }
    }
  }
    
  function get-tabCount([string]$val, $details)
  {
    $debugInfo = '';
    $maxTabs = [System.Math]::Floor($details.maxLength / 60);
    $tabCount = 0
    $size = getTextSize($val);
    while ($size -lt $details.maxLength )
    {
      $val += " "
      $size = getTextSize($val)
      $tabCount += 1
    }

    $debugInfo = 'ml:' + $details.maxLength + ',s:' + $size + ',fr:' + [System.Math]::Round($factorRaw, 2) + ',i:' + $inv + ',m:' + $maxTabs + ',t:' + $tabCount + '|';
    $result = @{
      DebugInfo = $debugInfo;
      TabCount  = $tabCount;
    }

    return $result;
  }

  $header = '';
  $underline = '';
  for ($i = 0; $i -lt $members.Length; $i++)
  {
    $member = $members[$i];
    $details = $writingDetails[$member.Name];
    $tabCountResult = get-tabCount -val $member.Name -details $details;
    $tabCount = $tabCountResult.TabCount;
    $header += $member.Name;
    $(1..$member.Name.Length) | ForEach-Object { $underline += "=" };
    if ($tabCount -gt 0 -and $i -ne $members.Length - 1)
    {
      $(1..$tabCount) | ForEach-Object { $header += " " };
      $(1..$tabCount) | ForEach-Object { $underline += "=" }
    }

    if ($i -ne $members.Length - 1)
    {
      $header += " | ";
      $underline += " | ";
    }
  }

  Write-Host $header;
  $underlines = $underline.Split("|");
  for ($i = 0; $i -lt $underlines.Length; $i++)
  {
    $underline = $underlines[$i];
    Write-Host -NoNewline -ForegroundColor $headerUnderlineColor $underline
    if ($i -ne $underlines.Length - 1)
    {
      Write-Host "|" -NoNewline
    }
  }

  # Adds a new line after the underline section of header
  Write-Host

  $i = 0;
  $list | ForEach-Object {
    $item = $_;
    $line = '';

    $debugInfo = "--";
    for ($j = 0; $j -lt $members.Length; $j++)
    {
      $member = $members[$j];
      $val = $item.PSObject.Properties[$member.Name].Value.ToString();
      $details = $writingDetails[$member.Name];
      $tabCountResult = get-tabCount -val $val -details $details;
      $tabCount = $tabCountResult.TabCount;
      if ($null -ne $debug -and $debug.PSObject.TypeNames -contains 'System.Array' -and $debug.Contains($j))
      {
        $debugInfo += $tabCountResult.DebugInfo;
      }

      $line += $val
      if ($tabCount -gt 0)
      {
        $(1..$tabCount) | ForEach-Object { $line += " " };
      }

      if ($j -ne $members.Length - 1)
      {
        $line += " | "
      }
    }

    if ($null -ne $highlightExpression -and $($item | &$highlightExpression))
    {
      $lineParts = $line.Split('|');
      for ($j = 0; $j -lt $lineParts.Length; $j++)
      {
        $part = $lineParts[$j];
        if ($true -eq $alternateRowColor -and $i % 2 -eq 0)
        {
          Write-Host -BackgroundColor White -ForegroundColor $highlightColor $part -NoNewline;
        } else
        {
          Write-Host -ForegroundColor $highlightColor $part -NoNewline;
        }

        if ($j -ne $lineParts.Length - 1)
        {
          Write-Host "|" -NoNewline;
        }
      }
			
      if ($debug -ne $false -and $null -ne $debug)
      {
        Write-Host $debugInfo -NoNewline
      }

      Write-Host;
    } elseif ($true -eq $alternateRowColor -and $i % 2 -eq 0)
    {
      $lineParts = $line.Split('|');
      for ($j = 0; $j -lt $lineParts.Length; $j++)
      {
        $part = $lineParts[$j];
        Write-Host $part -NoNewline -BackgroundColor DarkBlue -ForegroundColor White
        if ($j -ne $lineParts.Length - 1)
        {
          Write-Host "|" -NoNewline;
        }
      }

      if ((-not ($debug -eq $false)) -and $null -ne $debug)
      {
        Write-Host $debugInfo -NoNewline
      }

      Write-Host
    } else
    {
      Write-Host $line -NoNewline
      if ((-not ($debug -eq $false)) -and $null -ne $debug)
      {
        Write-Host $debugInfo -NoNewline
      }

      Write-Host
    }

    $i++
  }
}

function catman ($program)
{
  man -P cat $program
}
