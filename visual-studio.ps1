function Hide-VsWindows {
    Get-Process *.vshost | ForEach-Object {
        try {
            $_.MainWindowHandle | Move-Window (Get-Desktop 2) | Out-Null
        } catch {}
    }
}

function Show-VsWindows {
    Get-Process *.vshost | ForEach-Object {
        try {
            $_.MainWindowHandle | Move-Window (Get-Desktop 0) | Out-Null
        } catch {}
    }
}

function Remove-VsBinsRecursive() {
	Get-ChildItem .\ -include bin,obj -Recurse | ForEach-Object ($_) { 
		Remove-Item -Recurse -Force $_.fullname 
	}
}

function Stash-VsBinariesInFolder($dir, $framework) {
    $desired = Get-ChildItem $dir.FullName | Where-Object {$_.Name.EndsWith(".pdb")};
    $desired | ForEach-Object {
        $dll = $_.FullName.Replace(".pdb", ".dll");
        $xml = $_.FullName.Replace(".pdb", ".xml");
        if (-not (Test-Path $dll)) {
            return;
        }

        $frameworkDir = "./stashed-bins/$framework"
        if (-not (Test-Path $frameworkDir)) {
            mkdir $frameworkDir;
        }

        Copy-Item -Force $_ "$frameworkDir/$($_.Name)"
        Write-Host "Stashed $($_.FullName)"

        # An associated dll should exist
        Copy-Item -Force $dll "$frameworkDir/$($_.Name.Replace(".pdb", ".dll"))"
        Write-Host "Stashed $dll"

        if (Test-Path $xml) {
            Copy-Item -Force $xml "$frameworkDir/$($_.Name.Replace(".pdb", ".xml"))"
        }
    }
}
function Stash-VsBinaries() {
    $dirs = Get-ChildItem -Directory -Re -Path . -Name Debug | Where-Object {$_ -notlike "*obj\*" -and $_ -notlike "*packages\*" -and $_ -notlike "*tests\*"} | ForEach-Object { Get-Item $_ }
    mkdir ./stashed-bins
    $dirs | ForEach-Object {
        $dir = $_;
        Stash-VsBinariesInFolder $dir "";
        $subdirectories = Get-ChildItem -Directory -Path $dir.FullName;
        $subdirectories | ForEach-Object {
            Stash-VsBinariesInFolder $_ "$($_.Name)";
        }
    }
}

function Parse-VsPackageName($name) {
    $reg = [System.Text.RegularExpressions.Regex]::new("([a-zA-Z.]+)\.(\d+\.\d+(\.\d+)?)");
    $matched = $reg.Matches($name);
    $packageName = $matched.Groups[1].Value;
    $version = $matched.Groups[2].Value;
    $package = [psobject]::new();
    $package | Add-Member -NotePropertyName "name" -NotePropertyValue $packageName;
    $package | Add-Member -NotePropertyName "version" -NotePropertyValue $version;
    return $package;
}

function Replace-VsBinariesWithStashed() {
    if (-not (test-path packages)) {
        Write-Host -ForegroundColor Red "No packages folder in this directory"
        return;
    }

    $dirs = Get-ChildItem ./packages;
    $stashDir = "$home/code/stashed-bins"

    $stashedPackages = Get-ChildItem $stashDir | ForEach-Object { Parse-VsPackageName $_.Name }

    # foreach package
    $dirs | ForEach-Object {
        $dir = $_;
        $package = Parse-VsPackageName $dir.Name;
        
        # find similar stashed package
        $match = $stashedPackages | Where-Object {$package.name -like "*$($_.name)*" -and $package.version -eq $_.version} | ForEach-Object { $_ };
        if ($match.Length -lt 1) { return; }
        if ($match.Length -gt 1) {
            $match = $match[$match.Length - 1];
        }
        $matchDir = "$stashDir/$($match.name).$($match.version)";
        Write-Host "Replacing packages for $($dir.Name)"
        
        # foreach target framework
        Get-ChildItem "$($dir.FullName)/lib" | ForEach-Object {
            $frameworkDir = $_;
            if (-not (Test-Path "$matchDir/$($frameworkDir.Name)")) {
                return;
            }

            Get-ChildItem $frameworkDir.FullName | Where-Object {$_.Name.EndsWith(".dll")} | ForEach-Object {
                $dll = $_;
                $dllMatch = Get-ChildItem "$matchDir/$($frameworkDir.Name)/$($dll.Name)";
                if ($null -ne $dllMatch) {
                    Copy-Item -Force $dllMatch.FullName $dll.FullName
                    Write-Host "`tReplaced $($dll.FullName) with $($dllMatch.FullName)";
                    if (Test-Path $dllMatch.FullName.Replace(".dll", ".pdb")) {
                        Copy-Item -Force $dllMatch.FullName.Replace(".dll", ".pdb") $dll.FullName.Replace(".dll", ".pdb");
                        Write-Host "`tReplaced $($dll.FullName.Replace(".dll", ".pdb")) with $($dllMatch.FullName.Replace(".dll", ".pdb"))";
                    }
                }
            }
        }
    }
}
