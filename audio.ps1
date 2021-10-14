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

class PactlSource {
  [string]$Name;
  [string]$OwnerModule;
  [string]$ChannelMap;
}

class PactlSourceParser {
  [System.IO.TextReader]$reader;
  PactlSourceParser([System.IO.TextReader]$reader) {
    $this.reader = $reader;
  }

  [boolean]isSource([string]$line) {
    # If the line doesn't start with space, it's a Card heading
    return $line.StartsWith('Source');
  }

  [PactlSource]parse() {
    $result = [PactlSource]::new();
    while ($null -ne ($line = $this.reader.ReadLine()) -and $line.Trim() -ne '') {
      if ($line.Trim().StartsWith('Name')) {
        $result.Name = $line.Split('Name:')[1].Trim();
      } elseif ($line.Trim().StartsWith('Owner Module')) {
        $result.OwnerModule = $line.Split('Owner Module:')[1].Trim();
      } elseif ($line.Trim().StartsWith('Channel Map')) {
        $result.ChannelMap = $line.split('Channel Map:')[1].Trim();
      }
    }
    return $result;
  }
}

function Get-PactlSources() {
  $list = pactl list sources;
  $text = [string]::join("`n", $list);
  $bytes = [System.Text.Encoding]::ASCII.GetBytes($text);
  $stream = [System.IO.MemoryStream]::new($bytes);
  $reader = [System.IO.StreamReader]::new($stream);
  $sourceParser = [PactlSourceParser]::new($reader);
  $result = [System.Collections.Generic.List[PactlSource]]::new();
  while ($null -ne ($line = $reader.ReadLine())) {
    $isSource = $sourceParser.isSource($line)
    if ($isSource) {
      $result.Add($sourceParser.parse());
    }
  }
  return $result;
}

function Kill-MonoOutputs() {
  $sources = Get-PactlSources;
  $sources | Where-Object { $_.ChannelMap -eq 'mono' } | ForEach-Object {
    pactl unload-module $_.OwnerModule;
  }
}