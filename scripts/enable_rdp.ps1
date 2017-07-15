# Set the following Keys for enabling RDP
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0 -Force
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1  -Force

Get-NetFirewallRule -DisplayGroup 'Remote Desktop' | Enable-NetFirewallRule  