function Convert-ObjectToNestedHash ($obj) {
  $result = @{ };
  $obj.PSObject.Properties | ForEach-Object {
      $innerHash = @{ };
      $_.Value.PSObject.Properties | ForEach-Object {
          $innerHash[$_.Name] = $_.Value;
      }

      $result[$_.Name] = $innerHash;
  }

  return $result;
}
