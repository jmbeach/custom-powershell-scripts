# can easily pass these to Where-Object to not get node_modules and things
$FilterWebProject = [ScriptBlock]{ $_.FullName -NotLike "*node_modules*" -and $_.FullName -NotLike "*\lib\*" -and $_.FullName -NotLike "*\packages\*" -and $_.FullName -notlike "*\bin\*" -and $_.FullName -NotLike "*\obj\*" };
$FilterDotNet = [ScriptBlock]{ $_.Directory -NotLike "*packages*" };