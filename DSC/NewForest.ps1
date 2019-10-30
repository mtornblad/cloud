﻿Configuration NewForest
{
    param
    (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,


        [string[]]$roles
    )

    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module ActiveDirectoryDsc
    Import-DscResource -Module ComputerManagementDsc
    Import-DscResource -Module ActiveDirectoryCSDsc
    Import-DscResource -ModuleName CertificateDsc


    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)

    node 'localhost'
    {
        LocalConfigurationManager
        {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        WindowsFeature TelnetClient {
            Name = 'Telnet-Client'
            Ensure = 'Present'
        }
    }

    If ($roles -contains "DC") {

        node 'localhost'
        {
            WindowsFeature 'ADDS'
            {
                Name   = 'AD-Domain-Services'
                Ensure = 'Present'
            }
      
            ADDomain NewForest
            {
                DomainName                    = $DomainName
                Credential                    = $DomainCreds
                SafemodeAdministratorPassword = $DomainCreds
                ForestMode                    = 'WinThreshold'
            }

            PendingReboot Domain
            {
                Name      = 'Domain'
                SkipCcmClientSDK = $false
                DependsOn = '[ADDomain]NewForest'
            }


        }   
    }    
    
    If ($roles -contains "RSAT") {

        node 'localhost'
        {
            WindowsFeature 'RSAT'
            {
                Name   = 'RSAT-AD-PowerShell'
                Ensure = 'Present'
                DependsOn = "[WindowsFeature]ADDS"
            }

            WindowsFeature RSAT-ADDS
            {
                Ensure = "Present"
                Name = "RSAT-ADDS"
                DependsOn = "[WindowsFeature]RSAT"
            }

            WindowsFeature RSAT-ADDS-Tools
            {
                Name = 'RSAT-ADDS-Tools'
                Ensure = 'Present'
                DependsOn = "[WindowsFeature]RSAT-ADDS"
            }

            WindowsFeature RSAT-AD-AdminCenter
            {
                Name = 'RSAT-AD-AdminCenter'
                Ensure = 'Present'
                DependsOn = "[WindowsFeature]RSAT-ADDS-Tools"
            }      

            WindowsFeature RSAT-ADCS
            {
                Ensure = "Present"
                Name = "RSAT-ADCS"
                DependsOn = "[WindowsFeature]RSAT"
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

            PendingReboot Domain
            {
                Name      = 'Domain'
                SkipCcmClientSDK = $false
                DependsOn = '[Computer]JoinDomain'
            }
        }
    }
    
    If ($roles -contains "CA") {
        Node 'localhost'
        {
            WindowsFeature ADCS-Cert-Authority
            {
                Ensure = 'Present'
                Name   = 'ADCS-Cert-Authority'
                DependsOn        = '[PendingReboot]Domain'
            }
    
            AdcsCertificationAuthority CertificateAuthority
            {
                IsSingleInstance = 'Yes'
                Ensure           = 'Present'
                Credential       = $DomainCreds
                CAType           = 'EnterpriseRootCA'
                DependsOn        = '[WindowsFeature]ADCS-Cert-Authority'
                CACommonName     = 'MyCACN'
            }
    
            AdcsCertificationAuthoritySettings CertificateAuthoritySettings
            {
                IsSingleInstance = 'Yes'
                CACertPublicationURLs = @(
                    '1:C:\Windows\system32\CertSrv\CertEnroll\%1_%3%4.crt'
                    '2:ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11'
                    '2:http://pki.contoso.com/CertEnroll/%1_%3%4.crt'
                )
                CRLPublicationURLs =  @(
                    '65:C:\Windows\system32\CertSrv\CertEnroll\%3%8%9.crl'
                    '79:ldap:///CN=%7%8,CN=%2,CN=CDP,CN=Public Key Services,CN=Services,%6%10'
                    '6:http://pki.contoso.com/CertEnroll/%3%8%9.crl'
                )
                CRLOverlapUnits = 8
                CRLOverlapPeriod = 'Hours'
                CRLPeriodUnits = 1
                CRLPeriod = 'Months'
                ValidityPeriodUnits = 10
                ValidityPeriod = 'Years'
                DSConfigDN = 'CN=Configuration,DC=CONTOSO,DC=COM'
                DSDomainDN = 'DC=CONTOSO,DC=COM'
                AuditFilter = @(
                    'StartAndStopADCS'
                    'BackupAndRestoreCADatabase'
                    'IssueAndManageCertificateRequests'
                    'RevokeCertificatesAndPublishCRLs'
                    'ChangeCASecuritySettings'
                    'StoreAndRetrieveArchivedKeys'
                    'ChangeCAConfiguration'
                )
                DependsOn        = '[AdcsCertificationAuthority]CertificateAuthority'
            }

            <#C1-DC01.contoso.com\contoso-C1-DC01-CA#>
            CertReq SSLCert
            {
                CARootName          = 'contoso-C1-DC01-CA'
                CAServerFQDN        = 'C1-DC01.contoso.com'
                Subject             = 'web.contoso.com'
                KeyLength           = '2048'
                Exportable          = $true
                ProviderName        = 'Microsoft RSA SChannel Cryptographic Provider'
                OID                 = '1.3.6.1.5.5.7.3.1'
                KeyUsage            = '0xa0'
                CertificateTemplate = 'WebServer'
                AutoRenew           = $true
                FriendlyName        = 'SSL Cert for Web Server'
                Credential          = $Credential
                KeyType             = 'RSA'
                RequestType         = 'CMC'
                DependsOn           = '[AdcsCertificationAuthoritySettings]CertificateAuthoritySettings'
            }
    
 <#      
 
            WindowsFeature ADCS-Enroll-Web-Pol
            {
                Ensure = 'Present'
                Name   = 'ADCS-Enroll-Web-Pol'
                DependsOn        = '[CertReq]SSLCert'
            }
            AdcsEnrollmentPolicyWebService EnrollmentPolicyWebService
            {
                AuthenticationType = 'Kerberos'
                SslCertThumbprint  = 'f0262dcf287f3e250d1760508c4ca87946006e1e'
                Credential         = $DomainCreds
                KeyBasedRenewal    = $false
                Ensure             = 'Present'
                DependsOn          = '[WindowsFeature]ADCS-Enroll-Web-Pol'
            }
            WindowsFeature ADCS-Web-Enrollment
            {
                Ensure = 'Present'
                Name   = 'ADCS-Web-Enrollment'
                DependsOn        = '[PendingReboot]Domain'
            }
    
            AdcsWebEnrollment WebEnrollment
            {
                Ensure           = 'Present'
                IsSingleInstance = 'Yes'
                Credential       = $DomainCreds
                DependsOn        = '[WindowsFeature]ADCS-Web-Enrollment'
            }

#>    

    
            WindowsFeature ADCS-Online-Cert
            {
                Ensure = 'Present'
                Name   = 'ADCS-Online-Cert'
                DependsOn        = '[PendingReboot]Domain'
            }
    
            AdcsOnlineResponder OnlineResponder
            {
                Ensure           = 'Present'
                IsSingleInstance = 'Yes'
                Credential       = $DomainCreds
                DependsOn        = '[WindowsFeature]ADCS-Online-Cert'
            }
    
            AdcsTemplate KerberosAuthentication
            {
                Name   = 'KerberosAuthentication'
                Ensure = 'Present'
                DependsOn        = '[AdcsCertificationAuthority]CertificateAuthority'
           }
        
        }   
    }

    If ($roles -contains "ADFS") {
        Node 'localhost'
        {
            WindowsFeature installADFS  #install ADFS
            {
                Ensure = "Present"
                Name   = "ADFS-Federation"
                DependsOn = "[Computer]JoinDomain"
            }
    
        }
    }
}
