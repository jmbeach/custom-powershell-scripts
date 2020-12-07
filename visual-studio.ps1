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

function Stash-VsBinaries() {
    $dirs = Get-ChildItem -Directory -Re net45 | Where-Object {$_.FullName -notlike '*packages*'}
    mkdir ./stashed-bins
    $dirs | ForEach-Object {
        $dir = $_;
        $desired = Get-ChildItem $dir.FullName | Where-Object {$_.Name.EndsWith(".pdb") -or $_.Name.EndsWith(".dll")};
        $desired | ForEach-Object {
            Copy-Item -Force $_ ./stashed-bins
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
    $dirs | ForEach-Object {
        $dir = $_;
        $package = Parse-VsPackageName $dir.Name;
        
        # find similar stashed package
        $match = $stashedPackages | Where-Object {$package.name -like "*$($_.name)*" -and $package.version -eq $_.version} | ForEach-Object { $_ };
        if ($match.Length -lt 1) { return; }
        if ($match.Length -gt 1) {
            $match = $match[0];
        }
        $matchDir = "$stashDir/$($match.name).$($match.version)";
        Write-Host "Replacing packages for $($dir.Name)"
        Get-ChildItem $dir.FullName -Recurse | Where-Object {$_.Name.EndsWith(".dll")} | ForEach-Object {
            $dll = $_;
            $dllMatch = Get-ChildItem "$matchDir/$($dll.Name)";
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