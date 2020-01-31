$FilterWebProject = [ScriptBlock]{ $_.Directory -NotLike "*node_modules*" -and $_.Directory -NotLike "*lib*" };
$FilterDotNet = [ScriptBlock]{ $_.Directory -NotLike "*packages*" };