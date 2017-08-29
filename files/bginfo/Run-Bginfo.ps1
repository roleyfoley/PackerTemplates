$InstallLocation = "$($Env:Programfiles)\bginfo"
$BGInfoFile = 'Bginfo64.exe'
$Arguments = @( 
    "$InstallLocation/DefaultBGInfo.bgi"
    '/accepteula'
    '/silent'
    '/timer 0'
)

& "$InstallLocation\$BGInfoFile" $Arguments