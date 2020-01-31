function Clean-GitStaleBranches {
    $branches = git branch --merged
    $branches.Split("`n") | ForEach-Object {
        git branch -d $_.Trim()
    }
}

function PreviewClean-GitStaleBranches {
    $branches = git branch --merged
    $branches.Split("`n") | ForEach-Object {
        Write-Host $_.trim()
    }
}

function Clean-GitStaleBranchesRemote {
    $branches = git branch -a --merged
    $branches.Split("`n") | ForEach-Object {
        if ($_.Trim().Contains("master")) {
            # return is actually continue in foreach...
            return
        }

        $branchParts = $_.Trim().Split('/')
        $remote = $branchParts[1]
        $branch = $branchParts[2]
        git push $remote --delete $branch
    }

    git remote prune origin
}

function PreviewClean-GitStaleBranchesRemote {
    $branches = git branch -a --merged
    $branches.Split("`n") | ForEach-Object {
        if ($_.Trim().Contains("master")) {
            # return is actually continue in foreach...
            return
        }

        $branchParts = $_.Trim().Split('/')
        $remote = $branchParts[1]
        $branch = $branchParts[2]
        Write-Host "git push $remote --delete $branch"
    }

    Write-Host 'git remote prune origin'
}

function Get-GitCurrentBranch() {
    [string]$branchLine = git branch | select-string -SimpleMatch '*'
    return $branchLine.Replace("*", "").Trim()
}

function Set-GitUpstreamMatch($remote) {
    if ($remote -eq $null -or $remote -eq "") {
        $remote = "origin"
    }

    $currentBranch = Get-GitCurrentBranch
    git branch --set-upstream-to=$remote/$currentBranch
}