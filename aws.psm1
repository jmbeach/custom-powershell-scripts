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
    Write-Host "aws $args --region $region"
    $commandResult = aws @Args --region $region | ConvertFrom-Json
    $result.Add($commandResult)
  }
  return $result
}