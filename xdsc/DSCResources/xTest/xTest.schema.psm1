Configuration xTest
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
    Import-DscResource -ModuleName ActiveDirectoryCSDsc

    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)

    # Install the Hyper-V role
    Node localhost
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

        WindowsFeature ADCS-Enroll-Web-Pol
        {
            Ensure = 'Present'
            Name   = 'ADCS-Enroll-Web-Pol'
            DependsOn        = '[PendingReboot]Domain'
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