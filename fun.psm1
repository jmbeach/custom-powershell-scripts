Import-Module ~/.nuget/packages/htmlagilitypack/1.11.46/lib/netstandard2.0/HtmlAgilityPack.dll
Import-Module ~/.nuget/packages/fizzler/1.2.0/lib/netstandard2.0/Fizzler.dll
Import-Module ~/.nuget/packages/fizzler.systems.htmlagilitypack/1.2.1/lib/netstandard2.0/Fizzler.Systems.HtmlAgilityPack.dll

function Get-RandomWikisForRace() {
  $url = 'https://en.wikipedia.org/wiki/Wikipedia:Top_5000_pages'
  if (-not [System.IO.File]::Exists('wikis.txt') -or ([System.DateTime]::Now - [System.IO.File]::GetLastWriteTime('wikis.txt')) -gt [System.TimeSpan]::FromDays(1)) {
    $htmlText = (Invoke-WebRequest $url).Content
    $doc = [HtmlAgilityPack.HtmlDocument]::new()
    $doc.LoadHtml($htmlText)
    $names = [Fizzler.Systems.HtmlAgilityPack.HtmlNodeSelection]::QuerySelectorAll($doc.DocumentNode, '.wikitable td:nth-child(2) a')
    $names.InnerText | Out-File wikis.txt
  }

  $names = Get-Content wikis.txt

  $random = [Random]::new()
  $index1 = $random.Next(($names | Measure-Object).Count)
  $index2 = $random.Next(($names | Measure-Object).Count)
  Write-Host "$($names[$index1]) - $($names[$index2])"
}