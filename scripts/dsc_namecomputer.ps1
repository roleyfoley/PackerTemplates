Configuration OrgBaseComputerName { 
    param
   (
        [ValidateNotNullOrEmpty()]
        [string] $CurrentName,

        [ValidateNotNullOrEmpty()]
        [String] $RegisteredOwner = 'SpazNet',
   )

   Import-DscResource -ModuleName PsDesiredStateConfiguration, xComputerManagement

    LocalConfigurationManager
    {
        # This is false by default
        RebootNodeIfNeeded = 'false'
    }
    
    # Set To a Default WorkGroup
    if ( $CurrentName -notlike "$(($RegisteredOwner.PadLeft(7,[char]65)).Substring(0,7) )-*" ) {
        xComputer DefaultDetails { 
            Name = "$( ($RegisteredOwner.PadLeft(7,[char]65)).Substring(0,7) )-$(-join ((65..90) | Get-Random -Count 7 | ForEach-Object {[char]$_}))"
            WorkGroupName = "$( ($RegisteredOwner.PadLeft(7,[char]65)).Substring(0,7) )WG"
        }
    }
}

# Make the Envelope Size bigger for local DSC Config 
Set-Item WSMan:\localhost\MaxEnvelopeSizekb 10000

# Build DSC Config and apply to local host
OrgBaseComputerName -OutputPath C:\DSC\OrgBaseComputerName -CurrentName $ENV:COMPUTERNAME
Start-DscConfiguration -Path C:\DSC\OrgBaseComputerName -Wait -Force -Verbose 