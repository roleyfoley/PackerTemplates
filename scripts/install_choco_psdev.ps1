$ChocoPackages = @( 'visualstudiocode', 'vscode-powershell', 'git' ) 

if ( !(get-package -ProviderName "Chocolatey" | Where-Object { $_.Name -eq $VMToolsInstallerName}) ) {
    
    foreach ( $Package in $ChocoPackages ) {
        Write-host "Installing $($VMToolsInstallerName)"
        Install-Package -Name $Package -ProviderName "Chocolatey" -Force
    }
}