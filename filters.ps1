# can easily pass these to Where-Object to not get node_modules and things
$FilterWebProject = [ScriptBlock]{ $_.Directory -NotLike "*node_modules*" -and $_.Directory -NotLike "*lib*" };
$FilterDotNet = [ScriptBlock]{ $_.Directory -NotLike "*packages*" };