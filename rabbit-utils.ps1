function Configure-RabbitMq() {
    $rabbitHome = "C:\Program Files\RabbitMQ Server\rabbitmq_server-3.7.5\"
    $rabbitBase = "$env:APPDATA\RabbitMQ"
    $mnesiaBase = "$rabbitBase\db"
    $hostName = hostname
    $nodeName = "rabbit@" +$hostName
    return @{
        "CleanBootFile"="start_clean";
        "DistPort"=25672;
        "MinPort"=35672;
        "MaxPort"=35682;
        "RabbitBase"=$rabbitBase;
        "MnesiaBase"=$mnesiaBase;
        "NodeName"=$nodeName;
        "MnesiaDir"=$("$mnesiaBase\" + $nodeName + "-mnesia");
        "Home"=$rabbitHome
    }
}

function Start-RabbitMqCtl() {
    $config = Configure-RabbitMq
    $scriptDir = $config.Home + "\escript\rabbitmqctl"
    $formattedMnesia = $config.MnesiaDir.Replace('\', '/')
    $outDir = $rabbitBase + "\tmp"
    if (!$(Test-Path $outDir)) {
        mkdir $outDir
    }

    $outFile = "$outDir\log.txt"
    & "$env:ERLANG_HOME\bin\erl.exe" +B `
        -boot $config.CleanBootFile `
        -noinput `
        -noshell `
        -hidden `
        -smp enable `
        -kernel inet_dist_listen_min $config.MinPort `
        -kernel inet_dist_listen_max $config.MaxPort `
        -sasl errlog_type error `
        -mnesia dir "$formattedMnesia" `
        -run escript start `
        -escript main rabbitmqctl_escript `
        -extra "$scriptDir" $args 2> $outFile
    return Get-Content $outFile
}