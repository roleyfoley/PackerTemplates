$TempPath = 'C:\Temp'

if ( !(Test-path -Path $TempPath) ) { 
    New-Item -ItemType Directory -Path $TempPath
}

Invoke-WebRequest -Uri https://s3.amazonaws.com/ec2-downloads-windows/EC2Launch/latest/EC2-Windows-Launch.zip -OutFile C:\Temp\EC2-Windows-Launch.zip
Invoke-WebRequest -Uri https://s3.amazonaws.com/ec2-downloads-windows/EC2Launch/latest/install.ps1 -OutFile C:\Temp\install.ps1

Invoke-Expression 'C:\Temp\install.ps1'

$ConfigFile = 'C:\ProgramData\Amazon\EC2-Windows\Launch\Config\LaunchConfig.json'
$LaunchConfig = Get-Content -Path $ConfigFile -Raw | ConvertFrom-Json

$LaunchConfig.adminPasswordType = "Random"
$LaunchConfig.extendBootVolumeSize = $True
$LaunchConfig.setWallpaper = $False

Convertto-Json -Depth 100  $LaunchConfig | Out-File $ConfigFile
 
# Check for custom unattend file - Copy from Temp 
if ( test-path 'C:\Temp\unattend.xml' ) { 
    Copy-Item 'C:\Temp\unattend.xml' 'C:\ProgramData\Amazon\EC2-Windows\Launch\Sysprep\Unattend.xml'
}

# Schedules the intial instance setup on the next boot
C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1 -Schedule

# sysprep the instance ready to go.
C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\SysprepInstance.ps1