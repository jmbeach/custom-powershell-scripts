$scriptPath = $PSScriptRoot
$adjectives = Get-Content "$scriptPath/adjectives.txt"
$nouns = Get-Content "$scriptPath/nouns.txt"
$rand = [System.Random]::new()

function Get-AdjectiveNoun {
    <#
      .SYNOPSIS
        Gets an adjective noun string. Mimics spicy-proton https://github.com/schmich/spicy-proton/tree/master/corpus
    #>
    $adjectiveIndex = $rand.Next(0, $adjectives.Length)
    $nounIndex = $rand.Next(0, $nouns.Length)
    return @($adjectives[$adjectiveIndex], $nouns[$nounIndex])
}