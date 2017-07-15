write-Host "Setting up PSRepository"
if ( (Get-PSRepository | Where-Object { $_.Name -eq 'PSGallery'}) ) { 
    Write-HOst "Installing Package Provider"
    Install-PackageProvider -Name Nuget -Force
}
else { 
    Write-Host "Could not find PSRepo"
}