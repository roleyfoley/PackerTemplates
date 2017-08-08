Configuration OrgBaseComputerName { 
    param
   (
        [ValidateNotNullOrEmpty()]
        [String] $RegisteredOwner
   )

   Import-DscResource -ModuleName PsDesiredStateConfiguration, xComputerManagement

    LocalConfigurationManager
    {
        # This is false by default
        RebootNodeIfNeeded = $false
    }
    
    # Set To a Default WorkGroup
    
    xComputer DefaultDetails { 
        Name = "$( ($RegisteredOwner.PadLeft(7,[char]65)).Substring(0,7) )-$(-join ((65..90) | Get-Random -Count 7 | ForEach-Object {[char]$_}))"
        WorkGroupName = "$( ($RegisteredOwner.PadLeft(7,[char]65)).Substring(0,7) )WG"
    }
    
}

# Make the Envelope Size bigger for local DSC Config 
Set-Item WSMan:\localhost\MaxEnvelopeSizekb 10000

$RegisteredOwner = 'SpazNet'

if ( $ENV:COMPUTERNAME -notlike "$(($RegisteredOwner.PadLeft(7,[char]65)).Substring(0,7) )-*" ) { 
    # Build DSC Config and apply to local host
    OrgBaseComputerName -OutputPath C:\DSC\OrgBaseComputerName -RegisteredOwner $RegisteredOwner
    Start-DscConfiguration -Path C:\DSC\OrgBaseComputerName -Wait -Force -Verbose 
}
else { 
    Write-Verbose "No need to change name"
}