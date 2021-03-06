﻿param
(
    [String]$resourceGroup = 'admin',
    [String]$storageName = 'shared',
    [string]$rootPathForFiles = '.\dsc'
)

Get-ChildItem -Path $rootPathForFiles -Filter '*.ps1' | ForEach-Object {
    $ps1 = "$($_.FullName)"
    $psd = "$($_.DirectoryName)\$($_.BaseName).psd1"
    if (Test-Path $psd) {
        "Found $psd and include it in DSC configuration"
        # Publish-AzVMDscConfiguration -ConfigurationPath $ps1 -ResourceGroupName $resourceGroup -StorageAccountName $storageName -force -ConfigurationDataPath $psd
        Publish-AzVMDscConfiguration -ConfigurationPath $ps1 -force -ConfigurationDataPath $psd -OutputArchivePath "$($_.DirectoryName)\$($_.BaseName).zip"
    } else {
        "No matching configuration data found"
        # Publish-AzVMDscConfiguration -ConfigurationPath $ps1 -ResourceGroupName $resourceGroup -StorageAccountName $storageName -force
        Publish-AzVMDscConfiguration -ConfigurationPath $ps1 -force -OutputArchivePath "$($_.DirectoryName)\$($_.BaseName).zip"
    }
}

# Set-AzVMDscExtension -Version '2.76' -ResourceGroupName $resourceGroup -VMName $vmName -ArchiveStorageAccountName $storageName -ArchiveBlobName "newforest.ps1" -AutoUpdate -ConfigurationName 'NewForest'