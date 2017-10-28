write-host "Installing PS Modules"

$Modules = @( 
    'PSWindowsUpdate'
    'xTimeZone'
    'SystemLocaleDsc'
    'xNetworking'
    'xSystemSecurity' 
    'xComputerManagement'
    'xRemoteDesktopAdmin'
    'SecurityPolicyDsc'
)

foreach ( $Module in $Modules ) { 
    if ( !(Get-Module -ListAvailable -Name $Module) ) { 
        Write-host "Installing module $($Module)"
        Install-Module $Module -Force
    } 
    else { 
        Write-Host "Module $($Module) already installed"
    }
}

