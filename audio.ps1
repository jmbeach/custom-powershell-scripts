function ConvertTo-FlacFromWav(
  [Parameter(ValueFromPipeline=$true)]$wavFile,
  [switch]$overwrite) {
  ffmpeg $($overwrite ? '-y' : '') -i $wavFile.FullName -af aformat=s16:44100 $wavFile.FullName.Replace(".wav", ".flac");
}

function Get-AudioFilesWithoutMetadata() {
  Get-ChildItem . -Recurse -File | ForEach-Object {
    if (-not @('.mp3', '.flac', '.m4a', '.aac', '.wav').Contains($_.Extension)) {
      return;
    }

    $artist = ffprobe "$($_.FullName)" 2>&1 | Select-String artist;
    if ($null -eq $artist) {
      return $_;
    }
  }
}