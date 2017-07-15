# Install Windows Update PS module
Write-Host "Installing Updates"
if ( (Get-Module -ListAvailable -Name PSWindowsUpdate) ) { 
    Write-host "Module found starting updates"
    import-module PSWindowsUpdate
    Get-WUInstall -AcceptAll -IgnoreUserInput -IgnoreReboot
}
else {
    Write-Error "Module not found - No Updates have been applied" -ErrorAction Stop
}
