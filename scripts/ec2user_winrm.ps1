<powershell>
    # Set the network connection Profile to Private
  foreach ( $Adapter in $(Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -ne 'Domain'}) ) {
      Get-NetAdapter -InterfaceIndex $Adapter.InterfaceIndex | Set-NetConnectionProfile -NetworkCategory Private 
  }

  #Add a known Local Admin Account
  $SecurePass = ConvertTo-SecureString -String 'Something@123' -AsPlainText -Force 
  New-LocalUser -Name "vagrant" -Password $SecurePass -FullName "Fixed Admin" -AccountExpires $((Get-Date).AddDays(30)) | Add-localGroupMember -Group "Administrators"
  
  Enable-PSRemoting -Force
  winrm quickconfig -q
  
  winrm set winrm/config/client/auth '@{Basic="true"}'
  winrm set winrm/config/service/auth '@{Basic="true"}'
  winrm set winrm/config/service '@{AllowUnencrypted="true"}'
  winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'
  Restart-Service -Name WinRM
  netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow
</powershell>  