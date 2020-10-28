# Taken from https://devblogs.microsoft.com/scripting/psimaging-part-1-test-image/
$imgHeaders = @{
  jpg = @( "FF", "D8" );
  bmp = @( "42", "4D" );
  gif = @( "47", "49", "46" );
  tif = @( "49", "49", "2A" );
  pdf = @( "25", "50", "44", "46" );
  png = @( "89", "50", "4E", "47", "0D", "0A", "1A", "0A" );
}

# Also taken from https://devblogs.microsoft.com/scripting/psimaging-part-1-test-image/
function Get-ImageType($img) {
  # reads first 8 bytes of an image (in case it is png -- longest)
  $bytes = Get-Content $img -AsByteStream -ReadCount 1 -TotalCount 8;
  # ToString("X2") formats hexadecimal, using png since it's the longest
  $fileHeader = ($bytes | Select-Object -first $imgHeaders['png'].Length | ForEach-Object { $_.ToString("X2") });
  $keys = $imgHeaders.Keys | ForEach-Object { $_.ToString() };
  for ($i = 0; $i -lt $imgHeaders.Count; $i++) {
    $extension = $keys[$i];
    $header = $imgHeaders[$extension];
    $isMatch = $true;
    for ($j = 0; $j -lt $header.Count; $j++) {
      if ($header[$j] -ne $fileHeader[$j]) {
        $isMatch = $false;
      }

      if ($isMatch) {
        return $extension;
      }
    }
  }

  return $null;
}