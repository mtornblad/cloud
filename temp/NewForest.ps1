﻿<#PSScriptInfo
.VERSION 1.0
.GUID 86c0280c-6b48-4689-815d-5bc0692845a4
.AUTHOR Microsoft Corporation
.COMPANYNAME Microsoft Corporation
.COPYRIGHT (c) Microsoft Corporation. All rights reserved.
.TAGS DSCConfiguration
.LICENSEURI https://github.com/PowerShell/ActiveDirectoryDsc/blob/master/LICENSE
.PROJECTURI https://github.com/PowerShell/ActiveDirectoryDsc
.ICONURI
.EXTERNALMODULEDEPENDENCIES
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
.PRIVATEDATA
#>

#Requires -module ActiveDirectoryDsc

<#
    .DESCRIPTION
        This configuration will create a new domain with a new forest and a forest
        functional level of Server 2016.
#>
Configuration NewForest
{
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]$Admincreds
    )

    Import-DscResource -ModuleName PSDscResources
    Import-DscResource -ModuleName ActiveDirectoryDsc
    Import-DscResource -Module ComputerManagementDsc

    node 'T1-DC01'
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        WindowsFeature 'ADDS' {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        WindowsFeature 'RSAT' {
            Name   = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
        }

        ADDomain NewForest
        {
            DomainName                    = $DomainName
            Credential                    = $Admincreds
            SafemodeAdministratorPassword = $Admincreds
            ForestMode                    = 'WinThreshold'
        }
       
    }

    Node 'T1-VM01'
    {
        WaitForAll DC
        {
            ResourceName      = '[ADDomain]NewForest'
            NodeName          = 'T1-DC01'
            RetryIntervalSec  = 15
            RetryCount        = 30
        }

        Computer JoinDomain
        {
            Name             = 'T1-VM01'
            DomainName       = $DomainName
            Credential       = $Admincreds
            DependsOn        ='[WaitForAll]DC'
        }
    }
}
