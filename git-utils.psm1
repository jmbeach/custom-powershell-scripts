function Get-GitCommitsAheadBehindDevelop($gitDir, $branchLeft, $branchRight) {
    if ($null -eq $branchRight) {
        $branchRight = 'origin/develop'
    }

    $commitsDifference = (git --git-dir $gitDir rev-list --left-right --count "$branchRight...$branchLeft").Split("`t");
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