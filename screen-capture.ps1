# Download https://github.com/rdp/screen-capture-recorder-to-video-windows-free/releases
function Capture-Screen($outPath, $timeLimitSeconds) {
    if ($timeLimitSeconds -gt 0) {
        ffmpeg -f dshow  -i video="screen-capture-recorder" -r 20 -t $timeLimitSeconds $outPath
        return
    }

    ffmpeg -f dshow  -i video="screen-capture-recorder" -r 20 $outPath
}

function Capture-ScreenLoop($outPath, $frequency) {
    while(1) {
        $date = [datetime]::Now.ToString("dd-hh-mm-ss");
        $stamped = $outPath + $date + '.mp4';
        Capture-Screen $stamped $frequency
    }
}