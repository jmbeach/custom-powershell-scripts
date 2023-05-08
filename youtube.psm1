function Download-Youtube($url) {
  $urlParts = $url.Split('?')
  $urlParams = $urlParts[1].Split('&')
  $channel = ($urlParams | Where-Object { $_.StartsWith('ab_channel=') }).Replace('ab_channel=', '')
  $id = ($urlParams | Where-Object { $_.StartsWith('v=') }).Replace('v=', '')
  $urlTrimmed = "$($urlParts[0])?v=$id"
  $metaUrl = "https://www.googleapis.com/youtube/v3/videos?id=$id&key=$($env:GOOGLE_API_KEY)&part=snippet,statistics"
  $metaData = (Invoke-WebRequest $metaUrl).Content | ConvertFrom-Json
  yt-dlp $urlTrimmed
  $destination = (Get-ChildItem | Where-Object { $_.Name -like "*$id*" }).Name
  $mp3File = ("$($metaData.items.snippet.publishedAt.ToString("yyyy_MM_dd"))__$($channel)__$($metaData.items.snippet.title)" -replace '[!:]', '' -replace '[. ]', '_') + ".mp3"
  ffmpeg -i "$destination" $mp3File
  $outDir = "$home/iCloudDrive/podcasts/$channel"
  New-Item -ItemType Directory -Force $outDir
  Move-Item $mp3File $outDir
  Get-ChildItem | Where-Object { $_.Name -like "*$id*" } | Remove-Item
}