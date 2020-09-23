function ConvertTo-JsonBetter ([parameter(ValueFromPipeline = $true)]$inputObject, $sortProperties) {
	$json = [System.Text.StringBuilder]::new()
	$json.AppendLine('{') | Out-Null;
	function writeJson($obj, $key, $level, $lastProperty) {
		function writeTab() {
			for ($i = 0; $i -lt $level; $i++) {
				$json.Append('  ') | Out-Null;
			}
		}
		
		writeTab

		$value = $obj.PSObject.Properties[$key].Value;
		

		$json.Append('"') | Out-Null;
		$json.Append($key) | Out-Null;
		function writeJsonObject ($level, $value, $inList, $lastProperty) {
			if ($value.GetType().Name -eq 'HashTable') {
				$value = ConvertFrom-HashTable $value;
			}

			if ($value.GetType().Name -eq 'List`1' -or $value.GetType().Name -eq 'Object[]') {
				$json.AppendLine('": [') | Out-Null;
				for ($i = 0; $i -lt $value.Count; $i++) {
					writeJsonObject -level ($level + 1) -value $value[$i] -inList $true -lastProperty ($i -eq $value.Count - 1)
				}

				writeTab;
				if (-not $lastProperty) {
					$json.AppendLine('],') | Out-Null;
				}
				else {
					$json.AppendLine(']') | Out-Null;
				}
			}
			elseif ($value.GetType().Name -eq 'PSCustomObject') {
				if ($inList) {
					writeTab
					$json.AppendLine('{') | Out-Null;
				} else {
					$json.AppendLine('": {') | Out-Null;
				}

				$properties = [System.Linq.Enumerable]::ToList($value.PSObject.Properties);
				if ($sortProperties) {
					$properties = $properties | Sort-Object Name
				}

				for ($i = 0; $i -lt $properties.Count; $i++) {
					$property = $properties[$i];
					writeJson -obj $value -key $property.Name -level ($level + 1) -lastProperty ($i -eq $properties.Count - 1);
				}

				writeTab
				if (-not $lastProperty) {
					$json.AppendLine('},') | Out-Null;
				}
				else {
					$json.AppendLine('}') | Out-Null;
				}
			}
			else {
				if ($inList) {
					writeTab
					$json.Append('"') | Out-Null;
				} else {
					$json.Append('": "') | Out-Null;
				}

				$json.Append($value) | Out-Null;
				$json.Append('"') | Out-Null;
				if (-not $lastProperty) {
					$json.AppendLine(',') | Out-Null;
				}
				else {
					$json.AppendLine() | Out-Null;
				}
			}
		}

		writeJsonObject -level $level -value $value -inList $false -lastProperty $lastProperty
	}

	if ($inputObject.GetType().Name -eq 'HashTable') {
		$inputObject = ConvertFrom-HashTable $inputObject
	}

	$properties = [System.Linq.Enumerable]::ToList($inputObject.PSObject.Properties);
	if ($sortProperties) {
		$properties = $properties | Sort-Object Name;
	}

	for ($i = 0; $i -lt $properties.Count; $i++) {
		$property = $properties[$i];
		writeJson -obj $inputObject -key $property.Name -level 1 -lastProperty ($i -eq $properties.Count - 1);
	}

	$json.Append('}') | Out-Null;

	return $json.ToString();
}