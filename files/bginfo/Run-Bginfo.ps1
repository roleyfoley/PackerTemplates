### Hosting Environment Details

# Determine the Hosting Environment - Only do this on first run as it takes a while
if ( !$ENV:HostEnv ) {
    
    #AWS
    Try {
         if ( invoke-restmethod -Uri "http://169.254.169.254/latest/meta-data/instance-id" -TimeoutSec 1 ) {
            $HostingEnv = 'AWS'
        }
    }
    Catch { 
    }

    # Azure 
    Try { 
        if ( !$HostingEnv ) { 
            if ( Invoke-RestMethod -Headers @{"Metadata"= "true"} -Uri "http://169.254.169.254/metadata/instance/compute/vmId?api-version=2017-08-01&format=text" -TimeoutSec 1 ) { 
                $hostingEnv = "Azure"
             }
        }
    }
    Catch { 
    }

    #Hyper-V
    Try { 
        if ( !$HostingEnv ) {
            if ( Test-Path "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters" ) {
                $HostingEnv = 'Hyper-V'
            }

        }
    }
    Catch { 
    }
    
    
    # Physical/SomethingElse 
    if ( !$HostingEnv ) {
        $HostingEnv = 'Physical'
    }
   

    [Environment]::SetEnvironmentVariable("HostEnv", $HostingEnv, "Machine")
}    

$HostingEnv = [Environment]::GetEnvironmentVariable("HostEnv", "Machine") 

$InstanceId = ""
$NetworkId = ""
$InstanceLocation = ""
$InstanceSize = ""
$AccountId = ""

# Get Hosting Environment Specifics
switch ( $HostingEnv ) {

    'AWS' { 
        # Get Info from metadata
        $InstanceId = invoke-restmethod "http://169.254.169.254/latest/meta-data/instance-id" 
        $Nics = @( invoke-restmethod "http://169.254.169.254/latest/meta-data/network/interfaces/macs" )
        $NetworkId =  Invoke-RestMethod "http://169.254.169.254/latest/meta-data/network/interfaces/macs/$($Nics[0])vpc-id"
        $InstanceLocation = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/placement/availability-zone"
        $InstanceSize = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-type"


     }

     'Azure' { 
        $InstanceId = Invoke-RestMethod -Headers @{"Metadata"= "true"} -Uri "http://169.254.169.254/metadata/instance/compute/vmId?api-version=2017-08-01&format=text"
        $InstanceLocation = Invoke-RestMethod -Headers @{"Metadata"= "true"} -Uri "http://169.254.169.254/metadata/instance/compute/location?api-version=2017-08-01&format=text" 
        $InstanceSize = Invoke-RestMethod -Headers @{"Metadata"= "true"} -Uri "http://169.254.169.254/metadata/instance/compute/vmSize?api-version=2017-08-01&format=text" 
        $AccountId = Invoke-RestMethod -Headers @{"Metadata"= "true"} -Uri "http://169.254.169.254/metadata/instance/compute/subscriptionId?api-version=2017-08-01&format=text"
    }

    'Virtual' { 
        $InstanceLocation = (get-item "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters").GetValue("HostName")
        
    }

    'Physical' { 
        $InstanceId = (Get-WmiObject -Class Win32_Bios).SerialNumber
    }

}

# Set the Environment Variables
[Environment]::SetEnvironmentVariable("HostEnv_InstanceId", "$($InstanceId)", "Machine")
[Environment]::SetEnvironmentVariable("HostEnv_NetworkId", "$($NetworkId)", "Machine")
[Environment]::SetEnvironmentVariable("HostEnv_Loction", "$($InstanceLocation)", "Machine")
[Environment]::SetEnvironmentVariable("HostEnv_Size", "$($InstanceSize)", "Machine")
[Environment]::SetEnvironmentVariable("HostEnv_Account", "$($AccountId)", "Machine")

$InstallLocation = "$($Env:Programfiles)\bginfo"
$BGInfoFile = 'Bginfo64.exe'
$Arguments = @( 
    "$InstallLocation/DefaultBGInfo.bgi"
    '/accepteula'
    '/silent'
    '/timer 0'
    '/allusers'
)

& "$InstallLocation\$BGInfoFile" $Arguments