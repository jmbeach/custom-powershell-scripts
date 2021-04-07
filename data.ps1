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

function ConvertTo-Yaml {
  <#
    .SYNOPSIS
      Converts objects in pipeline to yaml
  
    .DESCRIPTION
      Uses YamlDotNet behind the scenes
  
    .INPUTS
      A powershell object to convert to yaml
  
    .OUTPUTS
      A yaml string
  
    .EXAMPLE
      $myObject | ConvertTo-Yaml
  #>
  [CmdletBinding()]
  param (
    [Parameter(ValueFromPipeline)]$Object
  )
  Import-Module "$home\.nuget\YamlDotNet.11.0.1\lib\netstandard2.1\YamlDotNet.dll"
  $serializer = [YamlDotNet.Serialization.SerializerBuilder]::new().Build()
  return $serializer.Serialize($Object)
}