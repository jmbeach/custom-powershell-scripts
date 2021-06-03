function Get-GitCommitsAheadBehind($gitDir, $branchLeft, $branchRight) {
    if ($null -eq $branchRight) {
        $branchRight = 'origin/develop'
    }

    $output = git --git-dir $gitDir rev-list --left-right --count "$branchRight...$branchLeft"

    # if either branch doesn't exist, this happens
    if ($null -eq $output) {
        $result = [psobject]::new();
        $result | Add-Member -NotePropertyName 'commitsAhead' -NotePropertyValue 0;
        $result | Add-Member -NotePropertyName 'commitsBehind' -NotePropertyValue 0;
        return $result;
    }

    $commitsDifference = $output.Split("`t");
    $commitsAhead = $commitsDifference[1];
    $commitsBehind = $commitsDifference[0];
    $result = [psobject]::new();
    $result | Add-Member -NotePropertyName 'commitsAhead' -NotePropertyValue $commitsAhead;
    $result | Add-Member -NotePropertyName 'commitsBehind' -NotePropertyValue $commitsBehind;
    return $result;
}

function Get-GitCurrentBranch($gitDir, $projectDir) {
    $branches = git --git-dir $gitDir --work-tree $projectDir branch
    $currentBranch = $branches | Where-Object { $_.StartsWith('*') }
    $currentBranch = $currentBranch.Trim().Replace('*', '').Trim();
    return $currentBranch;
}

function Get-GitBranches($gitDir, $projectDir) {
    $branches = git --git-dir $gitDir --work-tree $projectDir branch
    for ($i = 0; $i -lt $branches.Count; $i = $i + 1) {
        $branches[$i] = $branches[$i].Replace('*', '').Trim();
    }

    return $branches;
}

function Set-GitUserJared () {
    git config --global user.email 'jaredbeachdesign@gmail.com';
    git config --global user.name 'jmbeach'
}

function Set-GitUserIronJared () {
    git config --global user.email 'beachj@ironsolutions.com';
    git config --global user.name 'Jared Beach'
}

enum GitChangeType {
    Added
    Modified
    Deleted
}

class GitChange {
    [string]$fileName;
    [GitChangeType]$changeType;
    [boolean]$isStaged;
}

class GitStatus {
    [string]$branch;
    [boolean]$upToDate;
    [System.Collections.Generic.List[GitChange]]$changes = [System.Collections.Generic.List[GitChange]]::new()
}

function Get-GitStatus () {
    $status = git status;
    $result = [GitStatus]::new()
    $staged = $true;
    $status | ForEach-Object {
        $line = $_.Trim();
        if ($line.Contains('Changes to be committed:')) {
            $staged = $true;
            return;
        } elseif ($line.Contains('Changes not staged for commit:')) {
            $staged = $false;
            return;
        } elseif ($line.Contains('Untracked files:')) {
            $staged = $false;
            return;
        } elseif ($line.Contains('use "git')) {
            # Skip these "tip" lines
            return;
        } elseif ($line.Contains('On branch')) {
            $branch = $line.Split('On branch')[1].Trim()
            $result.branch = $branch;
            return;
        } elseif ($line.Contains('Your branch is up to date')) {
            $result.upToDate = $true;
            return;
        } elseif ($line.Contains('Your branch is not up to date')) {
            $result.upToDate = $false;
            return;
        }

        $change = [GitChange]::new();
        $change.isStaged = $staged;
        if ($line.Contains('new file:')) {
            $change.fileName = $line.Split('new file:')[1].Trim();
            $change.changeType = [GitChangeType]::Added;
        } elseif ($line.Contains('deleted:')) {
            $change.fileName = $line.Split('deleted:')[1].Trim();
            $change.changeType = [GitChangeType]::Deleted;
        } elseif ($line.Contains('modified:')) {
            $change.fileName = $line.Split('modified:')[1].Trim();
            $change.changeType = [GitChangeType]::Modified;
        } else {
            $change.fileName = $line.Trim();
            $change.changeType = [GitChangeType]::Added;
        }

        if ([string]::IsNullOrEmpty($change.fileName)) {
            return;
        }

        $result.changes.Add($change);
    }

    return $result;
}

class GitDiff {
    [string]$fileName;
    [System.Collections.Generic.List[string]]$addedLines = [System.Collections.Generic.List[string]]::new();
}
function Get-GitDiffs () {
    $diff = git --no-pager diff;
    $result = [System.Collections.Generic.List[GitDiff]]::new();
    $currentDiff = $null;
    $diff | ForEach-Object {
        $line = $_;
        if ($line.StartsWith('diff --git')) {
            if ($null -ne $currentDiff) {
                # Done processing last diff
                $result.Add($currentDiff);
            }

            $currentDiff = [GitDiff]::new();
            $currentDiff.fileName = $line.Split(' ')[2].Substring(2).Trim()

            # done processing this line
            return;
        }

        if ($line.StartsWith('index ')) {
            return;
        }

        if ($line.StartsWith('+++ ') -or $line.StartsWith('--- ') -or $line.StartsWith('@@')) {
            return;
        }

        if ($line.StartsWith('+')) {
            $currentDiff.addedLines.Add($line.Substring(1));
        }
    }

    $result.Add($currentDiff);
    return $result;
}