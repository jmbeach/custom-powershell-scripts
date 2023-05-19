function Parse-ResourceArn([string]$arn) {
  $parts = $arn.Split(':')
  $resourceParts = $parts[5].Split('/')
  return [PSCustomObject]@{
    Service = $parts[2];
    Region = $parts[3];
    ResourceType = $resourceParts[0]
    ResourceId = $resourceParts[$resourceParts.Length - 1]
  }
}
function Get-AwsFreeResources() {
  return @(
    [PSCustomObject]@{ Service = 'ec2'; ResourceType = 'dhcp-options' },
    [PSCustomObject]@{ Service = 'ec2'; ResourceType = 'internet-gateway' },
    [PSCustomObject]@{ Service = 'ec2'; ResourceType = 'network-acl' },
    [PSCustomObject]@{ Service = 'ec2'; ResourceType = 'network-interface' },
    [PSCustomObject]@{ Service = 'ec2'; ResourceType = 'route-table' },
    [PSCustomObject]@{ Service = 'ec2'; ResourceType = 'security-group' },
    [PSCustomObject]@{ Service = 'ec2'; ResourceType = 'subnet' },
    [PSCustomObject]@{ Service = 'ec2'; ResourceType = 'vpc' },
    [PSCustomObject]@{ Service = 'elasticloadbalancing'; ResourceType = 'targetgroup' },
    [PSCustomObject]@{ Service = 'iam'; ResourceType = 'instance-profile' },
    [PSCustomObject]@{ Service = 'iam'; ResourceType = 'policy' }
  )
}
function awsall() {
  $regions = @(
    'ap-south-1',
    'eu-north-1',
    'eu-west-3',
    'eu-west-2',
    'eu-west-1',
    'ap-northeast-3',
    'ap-northeast-2',
    'ap-northeast-1',
    'ca-central-1',
    'sa-east-1',
    'ap-southeast-1',
    'ap-southeast-2',
    'eu-central-1',
    'us-east-1',
    'us-east-2',
    'us-west-1',
    'us-west-2'
  )
  $result = [System.Collections.Generic.List[Object]]::new()
  for ($i = 0; $i -lt $regions.Length; $i = $i + 1) {
    $region = $regions[$i]
    Write-Host "aws $args --region $region ($($i + 1)/$($regions.Length))"
    $commandResult = aws @Args --region $region | ConvertFrom-Json
    $result.Add($commandResult)
  }
  return $result
}

function Get-AwsAllTaggedResources() {
  awsall resourcegroupstaggingapi get-resources
}

function Get-AwsAllPaidResources($resources) {
  $free = Get-AwsFreeResources
  if ($null -eq $resources) {
    $resources = Get-AwsAllTaggedResources
  }
  return $resources.ResourceTagMappingList | Where-Object {
    $parsed = Parse-ResourceArn $_.ResourceArn
    $match = $free | Where-Object { $_.Service -eq $parsed.Service -and $_.ResourceType -eq $parsed.ResourceType }
    return $null -eq $match
  }
}