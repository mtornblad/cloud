Configuration NewForest
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,


        [string[]]$roles
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc
    Import-DscResource -ModuleName ComputerManagementDsc

    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)


    If ($roles -contains "DC") {

        node 'localhost'
        {

            File ConfigFile
            {
                DestinationPath = "c:\\temp\\config.xml"
                Contents = "test"
            }

            LocalConfigurationManager 
            {
                RebootNodeIfNeeded = $true
            }

            WindowsFeature 'ADDS'
            {
                Name   = 'AD-Domain-Services'
                Ensure = 'Present'
            }

            WindowsFeature 'RSAT'
            {
                Name   = 'RSAT-AD-PowerShell'
                Ensure = 'Present'
            }
        
            ADDomain NewForest
            {
                DomainName                    = $DomainName
                Credential                    = $DomainCreds
                SafemodeAdministratorPassword = $DomainCreds
                ForestMode                    = 'WinThreshold'
            }
        }   
    }

    If ($roles -contains "DomainMember") {
        Node 'localhost'
        {
            Computer JoinDomain
            {
                Name       = 'localhost'
                DomainName = $DomainName
                Credential = $DomainCreds
            }
        }
    }
}
