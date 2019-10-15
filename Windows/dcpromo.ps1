param (
    [string]$DomainName, 
    [SecureString]$Password
 )

Install-WindowsFeature -Name AD-Domain-Services
$Params = @{
    CreateDnsDelegation = $false
    DatabasePath = 'C:\Windows\NTDS'
    DomainMode = 'WinThreshold'
    DomainName = $DomainName
    DomainNetbiosName = $DomainName.Split('.')[0]
    ForestMode = 'WinThreshold'
    InstallDns = $true
    LogPath = 'C:\Windows\NTDS'
    NoRebootOnCompletion = $true
    SafeModeAdministratorPassword = $Password
    SysvolPath = 'C:\Windows\SYSVOL'
    Force = $true
}
Install-ADDSForest @Params

