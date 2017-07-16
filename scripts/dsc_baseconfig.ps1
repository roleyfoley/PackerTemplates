Configuration BaseOSConfig { 
   param
   (
        [string[]]$ComputerName="localhost",

       [ValidateNotNullorEmpty()]
       [String] $SystemLocale = 'en-AU',

       [ValidateNotNullorEmpty()]
       [String] $TimeZone = 'AUS Eastern Standard Time',

       [ValidateNotNullOrEmpty()]
       [String] $RegisteredOwner = 'SpazNet',

       [ValidateNotNullOrEmpty()]
       [String] $OEMSupportNumber = '000',

       [ValidateNotNullOrEmpty()]
       [String] $ImageName = 'Win2016Std_1.0.0'
   )

    Import-DscResource -ModuleName PsDesiredStateConfiguration,xTimeZone,SystemLocaleDsc,xNetworking,xSystemSecurity,xComputerManagement,xRemoteDesktopAdmin,SecurityPolicyDsc

    Node $ComputerName {

        # Standard Management Services 
        WindowsFeature TelnetClient { 
            Name = "Telnet-Client"
            Ensure = "Present"
        }
        WindowsFeature DotNet35 { 
            Name = "WAS-NET-Environment"
            Ensure = "Present"
        }
        WindowsFeature SNMP { 
            Name = 'SNMP-Service'
            Ensure = 'Present'
            IncludeAllSubFeature = $True
        }
        WindowsFeature SNMPTools { 
            Name = 'RSAT-SNMP'
            Ensure = 'Present'
        }
        WindowsFeature WinBackup { 
            Name = 'Windows-Server-Backup'
            Ensure = 'Present'
        }

        # Timezone and Locale
        xTimeZone LocalTimeZone { 
            TimeZone = $TimeZone 
            IsSingleInstance = 'Yes'
        }
        SystemLocale LocalLocale { 
            SystemLocale = $SystemLocale
            IsSingleInstance =  'Yes'
        }

        #Local Groups 
        Group LogOnAsABatch { 
            GroupName = 'Logon_as_a_batch'
            Description =  'Allows services to logon as a batch process'
            Ensure = 'Present'
        }
        Group LogOnAsAService { 
            GroupName = 'Logon_as_a_service'
            Description =  'Allows services to logon as a service'
            Ensure = 'Present'
        }

        # User Rights Assignments
        UserRightsAssignment RightsAssignmentService
        {            
            Policy = "Log_on_as_a_service"
            Identity = @('Logon_as_a_service')
        }
        UserRightsAssignment RightsAssignmentBatch
        {            
            Policy = "Log_on_as_a_batch_job"
            Identity = @('BUILTIN\Administrators','BUILTIN\Performance Log Users','BUILTIN\Backup Operators','Logon_as_a_batch')
        }

        # Enable RDP
        xRemoteDesktopAdmin RemoteDesktopSettings
        {
           Ensure = 'Present'
           UserAuthentication = 'Secure'
        }
        xFirewall FirewallRDPInTCP { 
            Name = 'RemoteDesktop-UserMode-In-TCP'
            Enabled = $True
            Ensure = 'Present'
        }
        xFirewall FirewallRDPInUDP { 
            Name = 'RemoteDesktop-UserMode-In-UDP'
            Enabled = $True
            Ensure = 'Present'
        }

        # Single Label Domain Support 
        Registry DNSUpdateTopLevel { 
            Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient'
            ValueName = 'UpdateTopLevelDomainZones'
            ValueData = '1'
            Ensure = 'Present'
            Force = $True
            ValueType = 'Dword'
        }
        Registry AllowSingleLabelDomain { 
            Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
            ValueName = 'AllowSingleLabelDNSDomain'
            ValueData = '1'
            Ensure = 'Present'
            Force = $True
            ValueType = 'Dword'
        }

        # Disable Windows Error Reporting
        Registry DisableWER { 
            Key = 'HKLM:\Software\Microsoft\Windows\Windows Error Reporting'
            ValueName =  'Disabled'
            ValueData = '1'
            Ensure = 'Present'
            Force = $True
            ValueType =  'Dword'
        }
        Registry DisableWERLogging { 
            Key = 'HKLM:\Software\Microsoft\Windows\Windows Error Reporting'
            ValueName =  'LoggingDisabled'
            ValueData = '1'
            Ensure = 'Present'
            Force = $True
            ValueType =  'Dword'
        }

        # Disabled Enhanced IE Security
        xIEESC DisableIEESCAdmins { 
            UserRole = 'Administrators'
            isEnabled = $false
        }

        # High performance Power plane
        xPowerPlan SetPlanHighPerformance
        {
          IsSingleInstance = 'Yes'
          Name = 'High performance'
        }

        # Disable Server Manager from Opening
        xScheduledTask DisableServerManager { 
            TaskName = 'ServerManager'
            TaskPath = '\Microsoft\Windows\Server Manager\'
            Enable = $false
            ActionExecutable = '%windir%\system32\ServerManagerLauncher.exe'
            ScheduleType = 'AtLogOn'
        }

        # Registered Organisation 
        Registry RegisteredOwner { 
            Key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
            ValueName =  'RegisteredOwner'
            ValueData = $RegisteredOwner
            Ensure = 'Present'
            Force = $True
            ValueType =  'String'
        }
        Registry RegisteredOrganization { 
            Key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
            ValueName =  'RegisteredOrganization'
            ValueData = $RegisteredOwner
            Ensure = 'Present'
            Force = $True
            ValueType =  'String'
        }

        # OEM info
        Registry OEMManufacturer { 
            Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation'
            ValueName = 'Manufacturer'
            ValueData =  $RegisteredOwner
            Ensure = 'Present'
            Force = $True
            ValueType = 'String'
        }
        Registry OEMSupportPhone { 
            Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation'
            ValueName = 'SupportPhone'
            ValueData =  $OEMSupportNumber
            Ensure = 'Present'
            Force = $True
            ValueType = 'String'
        }
        Registry OEMModel { 
            Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation'
            ValueName = 'Model'
            ValueData =  $ImageName
            Ensure = 'Present'
            Force = $True
            ValueType = 'String'
        }

        # Set To a Default WorkGroup
        xComputer DefaultDetails { 
            Name = "$( ($RegisteredOwner.PadLeft(7,[char]65)).Substring(0,7) )-$(-join ((65..90) | Get-Random -Count 7 | ForEach-Object {[char]$_}))"
            WorkGroupName = "$( ($RegisteredOwner.PadLeft(7,[char]65)).Substring(0,7) )WG"
        }
    }
}

# Make the Envelope Size bigger for local DSC Config 
Set-Item WSMan:\localhost\MaxEnvelopeSizekb 10000

# Build DSC Config and apply to local host
BaseOSConfig -OutputPath C:\DSC\BaseOSConfig 
Start-DscConfiguration -Path C:\DSC\BaseOSConfig -Wait -Force -Verbose 