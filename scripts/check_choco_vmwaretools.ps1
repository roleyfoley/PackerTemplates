$VMToolsInstallerName = 'vmware-tools'

if ( get-package -ProviderName "Chocolatey" | Where-Object { $_.Name -eq $VMToolsInstallerName} ) { 
    write-Host "Package INstalled "
}
else { 
    Write-Error "Package not instsalled" -ErrorAction Stop
}