<#
  .SYNOPSIS
    Converts xml input into a powershell object

  .DESCRIPTION
    Uses [System.Xml.XmlReader] to parse input
    from pipeline (or standard parameters) to
    a .NET XmlDocument object. It does not check 
    schemas or document types; only that the 
    text is valid XML syntax.

  .INPUTS
    Text XML document(s)

  .OUTPUTS
    .Net XmlDocument object(s)

  .EXAMPLE
    Get-Content .\myxml.xml | ConvertFrom-Xml
#>
function ConvertFrom-Xml {
  [CmdletBinding()]
  param (
    <#
     .PARAMETER InputObject
       Textual XML document(s)
    #>
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
    [object]$InputObject
  )

  End {
    # Based on https://stackoverflow.com/a/17461028/1834329
    function _processXml($xml) {
      $err = $null;
      $result = $null;
      try {
        $settings = [System.Xml.XmlReaderSettings]::new();
        $settings.DtdProcessing = [System.Xml.DtdProcessing]::Ignore;
        $settings.XmlResolver = $null;
        $stringReader = [System.IO.StringReader]::new($xml.Trim());
        $reader = [System.Xml.XmlReader]::Create($stringReader);
        $result = [System.Xml.XmlDocument]::new();
        $result.Load($reader);
      } catch {
        $err = $_;
      } finally {
        if ($null -ne $reader) {
          $reader.Dispose();
        } elseif ($null -ne $stringReader) {
          $stringReader.Dispose();
        }
      }
  
      if ($null -ne $err) {
        throw $err;
      }
  
      return $result;
    }

    $isValid = $true;
    try {
      $firstRecord = _processXml($input[0]);
      if ($null -eq $firstRecord) {
        $isValid = $false;
      }
    }
    catch {
      $isValid = $false;
    }

    # If the first record is valid, then every record is an xml object
    if ($isValid) {
      $input | ForEach-Object {
        _processXml($_);
      }
    }
    else {
      [Func[string, string, string]]$reducer = { param ($a, $b) "$a`n$b"; };
      $fullText = [System.Linq.Enumerable]::Aggregate([string[]]$input, [string]::Empty, $reducer);
      return _processXml($fullText);
    }
  }
}