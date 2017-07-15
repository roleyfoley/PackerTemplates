$VMToolsInstallerName = 'vmware-tools'

if ( !(get-package -ProviderName "Chocolatey" | Where-Object { $_.Name -eq $VMToolsInstallerName}) ) {
    Write-host "Installing $($VMToolsInstallerName)"
    Install-Package -Name $VMToolsInstallerName -ProviderName "Chocolatey" -Force
}