function Open-GitKraken() {
    $cwd = (get-item .).FullName
    &"$HOME\AppData\Local\gitkraken\update.exe" --processStart=gitkraken.exe --process-start-args="-p `"$cwd`""
}