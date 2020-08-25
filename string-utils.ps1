function Get-AllPermutations([string]$text) {
  $indexSets = Get-PermutationSetByLength $text.Length;
  $allPermutations = [System.Collections.Generic.List[string]]::new();
  $indexSets | ForEach-Object {
    $permutation = '';
    $indexSet = $_;
    $indexSet | ForEach-Object {
      $permutation += $text[$_];
    }

    $allPermutations.Add($permutation)
  }

  return $allPermutations;
}

function Get-EditDistance([string]$a, [string]$b) {
  $matrix = [System.Collections.Generic.List[System.Collections.Generic.List[int]]]::new();

  for ($i = 0; $i -lt $a.Length + 1; $i++) {
    $matrix.Add([System.Collections.Generic.List[int]]::new());
    for ($j = 0; $j -lt $b.Length + 1; $j++) {
      $matrix[$i].Add(0);
    }
  }
  
  for ($i = 0; $i -lt $a.Length + 1; $i++) {
    $matrix[$i][0] = $i;
  }

  for ($i = 0; $i -lt $b.Length + 1; $i++) {
    $matrix[0][$i] = $i;
  }

  for ($i = 0; $i -lt $a.Length; $i++) {
    for ($j = 0; $j -lt $b.Length; $j++) {
      $substitutionCost = 0;
      if ($a[$i] -ne $b[$j]) {
        $substitutionCost = 1;
      }

      $left = $matrix[$i][$j + 1];
      $up = $matrix[$i + 1][$j];
      $diag = $matrix[$i][$j];
      $min = [System.Math]::Min([System.Math]::Min($left + 1, $up + 1), $diag + $substitutionCost);
      $matrix[$i + 1][$j + 1] = $min;
      # Write-Host "$i, $j"
      # Write-Debug2DWordMatrix $a $b $matrix $i $j
    }
  }

  return $matrix[$a.Length][$b.Length];
}

function Write-Debug2DWordMatrix($a, $b, $matrix, $atI, $atJ) {
  Write-Host "     " -NoNewline;
  for ($i = 0; $i -lt $b.Length; $i++) {
    Write-Host "$($b[$i])  " -NoNewline;
  }

  Write-Host

  for ($i = 0; $i -lt $a.Length + 1; $i++) {
    $row = $matrix[$i];
    if ($i -gt 0) {
      Write-Host "$($a[$i - 1]) " -NoNewline
    } else {
      Write-Host "  " -NoNewline
    }
    for ($j = 0; $j -lt $row.Count; $j++) {
      $entry = $row[$j];
      if ($i -eq ($atI + 1) -and $j -eq ($atJ + 1)) {
        Write-Host $entry -BackgroundColor Green -NoNewline -ForegroundColor Black
      }
      else {
        Write-Host $entry -NoNewline
      }
      
      if ($j -ne $row.Count - 1) {
        Write-Host ", " -NoNewline;
      }
    }

    Write-Host;
  }
}

function Get-PermutationSetByLength([int]$length) {
  # list of list of list of ints
  $matrix = [System.Collections.Generic.List[System.Collections.Generic.List[System.Collections.Generic.List[int]]]]::new();
  for ($i = 0; $i -lt $length; $i++) {
    $permutations = [System.Collections.Generic.List[System.Collections.Generic.List[int]]]::new();
    if ($i -eq 0) {
      $permutations.Add($i);
      $matrix.Add($permutations);
      continue;
    }

    # list of list of ints
    [System.Collections.Generic.List[System.Collections.Generic.List[int]]]$previousPermutations = $matrix[$i - 1];
    for ($j = 0; $j -lt $previousPermutations.Count; $j++) {
      [System.Collections.Generic.List[int]]$previousPermutation = $previousPermutations[$j];

      # create one permuatation that is the previous permuation with the new element appended to it
      $permutations.Add((Invoke-CloneListAndInsert $previousPermutation $i ($previousPermutation.Count + 1)));

      # swapping directions makes output nicer
      for ($k = $previousPermutation.Count - 1; $k -gt -1; $k--) {
        $permutations.Add((Invoke-CloneListAndInsert $previousPermutation $i $k));
      }
    }

    $matrix.Add($permutations)
  }

  return $matrix[$matrix.Count - 1]
}

function Invoke-CloneListAndInsert($list, $newItem, $index) {
  $clone = [System.Collections.Generic.List[object]]::new();
  for ($i = 0; $i -lt $list.Count; $i++) {
    if ($i -eq $index) {
      $clone.Add($newItem);
    }

    $clone.Add($list[$i]);
  }

  if ($index -ge $list.Count) {
    $clone.Add($newItem);
  }

  return $clone;
}