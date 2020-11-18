function Start-CodeClimate() {
  $path = $PWD.Path.Replace('\', '/').Replace('C:', '');
  docker run --interactive --tty --rm --env CODECLIMATE_CODE="$path" --volume "$($path):/code" --volume /var/run/docker.sock:/var/run/docker.sock --volume /tmp/cc:/tmp/cc codeclimate/codeclimate $args
}

Set-Alias -Name 'codeclimate' -Value 'Start-CodeClimate'