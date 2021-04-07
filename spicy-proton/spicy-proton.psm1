function Get-AdjectiveNoun {
    <#
      .SYNOPSIS
        Gets an adjective noun string. Mimics spicy-proton https://github.com/schmich/spicy-proton/tree/master/corpus
    #>
    $rand = [System.Random]::new()
    $scriptPath = $PSScriptRoot
    $adjectives = Get-Content "$scriptPath/adjectives.txt"
    $nouns = Get-Content "$scriptPath/nouns.txt"
    $adjectiveIndex = $rand.Next(0, $adjectives.Length)
    $nounIndex = $rand.Next(0, $nouns.Length)
    return @($adjectives[$adjectiveIndex], $nouns[$nounIndex])
}