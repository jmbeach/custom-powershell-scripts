function Get-Man() {
    wsl.exe man $args
}

function gitkraken() {
  open "gitkraken://repo/$($PWD.Path)";
}