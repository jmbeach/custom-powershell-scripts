function Get-XmlFromSvg($xmlPath)
{
    [xml]$xml = Get-Content $xmlPath
    $xmlns = [System.Xml.XmlNamespaceManager]::new($xml.NameTable)
    $xmlns.AddNamespace('svg', 'http://www.w3.org/2000/svg')
    return @{ doc = $xml; xmlns = $xmlns }
}