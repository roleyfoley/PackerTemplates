Configuration BaseUserConfig { 
    param
   (
        [string]$UserRegHive

   )

   Import-DscResource -ModuleName PsDesiredStateConfiguration

    Registry UserKey_HiddenFiles { 
        Key = "$UserRegHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        ValueName = 'Hidden'
        ValueData =  '1'
        Ensure = 'Present'
        Force = $True
        ValueType = 'Dword'
        
    }

    Registry UserKey_ShowExtensions { 
        Key = "$UserRegHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        ValueName = 'HideFileExt'
        ValueData =  '0'
        Ensure = 'Present'
        Force = $True
        ValueType = 'Dword'
        
    }

    Registry UserKey_ShowEmptyDrives { 
        Key = "$UserRegHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        ValueName = 'HideDrivesWithNoMedia'
        ValueData =  '0'
        Ensure = 'Present'
        Force = $True
        ValueType = 'Dword'
        
    }

    Registry UserKey_DisableSharingWizard { 
        Key = "$UserRegHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        ValueName = 'SharingWizardOn'
        ValueData =  '0'
        Ensure = 'Present'
        Force = $True
        ValueType = 'Dword'
        
    }


    Registry UserKey_NoFrequentFiles { 
        Key = "$UserRegHive\Software\Microsoft\Windows\CurrentVersion\Explorer"
        ValueName = 'ShowFrequent'
        ValueData =  '0'
        Ensure = 'Present'
        Force = $True
        ValueType = 'Dword'
        
    }

    Registry UserKey_NoRecentFiles { 
        Key = "$UserRegHive\Software\Microsoft\Windows\CurrentVersion\Explorer"
        ValueName = 'ShowRecent'
        ValueData =  '0'
        Ensure = 'Present'
        Force = $True
        ValueType = 'Dword'
        
    }

    Registry UserKey_ShowFullFilePath { 
        Key = "$UserRegHive\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState"
        ValueName = 'FullPath'
        ValueData =  '1'
        Ensure = 'Present'
        Force = $True
        ValueType = 'Dword'
        
    }

    Registry UserKey_SearchFileNamesOnly { 
        Key = "$UserRegHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Search\PrimaryProperties"
        ValueName = 'UnindexedLocations'
        ValueData =  '1'
        Ensure = 'Present'
        Force = $True
        ValueType = 'Dword'
        
    }

    Registry UserKey_SearchSubFolders { 
        Key = "$UserRegHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Search\Preferences"
        ValueName = 'SearchSubFolders'
        ValueData =  '1'
        Ensure = 'Present'
        Force = $True
        ValueType = 'Dword'
        
    }

    Registry UserKey_SearchAutoWildCard { 
        Key = "$UserRegHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Search\Preferences"
        ValueName = 'AutoWildCard'
        ValueData =  '1'
        Ensure = 'Present'
        Force = $True
        ValueType = 'Dword'
        
    }

    Registry UserKey_SearchSystemFolders { 
        Key = "$UserRegHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Search\Preferences"
        ValueName = 'SystemFolders'
        ValueData =  '1'
        Ensure = 'Present'
        Force = $True
        ValueType = 'Dword'
        
    }

    Registry UserKey_SearchArchivedFolders { 
        Key = "$UserRegHive\Software\Microsoft\Windows\CurrentVersion\Explorer\Search\Preferences"
        ValueName = 'ArchivedFiles'
        ValueData =  '1'
        Ensure = 'Present'
        Force = $True
        ValueType = 'Dword'
        
    }
}

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
       [String] $ImageName = 'Win2016Std_1.0.0',

       [ValidateNotNullOrEmpty()]
       [String] $DefaultUserMountPoint = 'HKLM:\DEFAULTUSER'
   )

    Import-DscResource -ModuleName PsDesiredStateConfiguration,xTimeZone,SystemLocaleDsc,xNetworking,xSystemSecurity,xRemoteDesktopAdmin,SecurityPolicyDsc

    Node $ComputerName {

        LocalConfigurationManager
        {
            # This is false by default
            RebootNodeIfNeeded = 'false'
        }

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

        # Default User Hive update
        Script mountDefaultUserHive { 
            GetScript = {
                Return @{
                    Result = Get-ChildItem $using:DefaultUserMountPoint
                } 
            }

            TestScript = {
                if ( Test-Path $using:DefaultUserMountPoint ) {
                    Write-Verbose "Default User Reg mounted"
                    return $True
                }
                Else { 
                    Write-Verbose "Default User Reg unmounted"
                    return $False
                }   
            }

            SetScript = { 
                Write-Verbose "Mounting Default User Hive"
                & REG LOAD $( $using:DefaultUserMountPoint -replace ':','' ) C:\Users\Default\NTUSER.DAT
            }
        }

        BaseUserConfig DefaultUserConfig { 
            UserRegHive = $DefaultUserMountPoint
            DependsOn = "[Script]mountDefaultUserHive"
        }


        # Default User Hive update
        Script unmountDefaultUserHive { 
            GetScript = {
                Return @{
                    Result = Get-ChildItem $using:DefaultUserMountPoint
                } 
            }

            TestScript = {
                if ( Test-Path $using:DefaultUserMountPoint ) {
                    Write-Verbose "Default User Reg needs to be unmounted"
                    return $False
                }
                Else { 
                    Write-Verbose "Default User Reg unmount"
                    return $True
                }   
            }

            SetScript = { 
                Write-Verbose "unmounting Default User Hive"
                [gc]::Collect() # necessary call to be able to unload registry hive
                & REG UNLOAD $( $using:DefaultUserMountPoint -replace ':','' )
            }
            DependsOn =  "[BaseUserConfig]DefaultUserConfig"
        }
        
    }
}



# Make the Envelope Size bigger for local DSC Config 
Set-Item WSMan:\localhost\MaxEnvelopeSizekb 10000

# Build DSC Config and apply to local host
BaseOSConfig -OutputPath C:\DSC\BaseOSConfig 
Start-DscConfiguration -Path C:\DSC\BaseOSConfig -Wait -Force -Verbose 