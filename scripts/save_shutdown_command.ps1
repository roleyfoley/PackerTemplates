$packerWindowsDir = 'C:\Windows\packer'
if ( !(Test-Path $packerWindowsDir ) { 
    New-Item -Path $packerWindowsDir -ItemType Directory -Force
}

# final shutdown command
$shutdownCmd = @"
netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block

C:/windows/system32/sysprep/sysprep.exe /generalize /oobe /unattend:C:/Windows/packer/unattended.xml /quiet /shutdown
"@

Set-Content -Path "$($packerWindowsDir)\PackerShutdown.bat" -Value $shutdownCmd

# will run on first boot
# https://technet.microsoft.com/en-us/library/cc766314(v=ws.10).aspx
$setupComplete = @"
netsh advfirewall firewall set rule name="WinRM-HTTP" new action=allow
"@

New-Item -Path 'C:\Windows\Setup\Scripts' -ItemType Directory -Force
Set-Content -path "C:\Windows\Setup\Scripts\SetupComplete.cmd" -Value $setupComplete
