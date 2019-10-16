$resourceGroup = 'Tenant1'
$storageName = 'shared'
$configurationPath = '.\dsc\newforest.ps1'
#Publish the configuration script to user storage
Publish-AzVMDscConfiguration -ConfigurationPath $configurationPath -ResourceGroupName $resourceGroup -StorageAccountName $storageName -force
#Set the VM to run the DSC configuration
# Set-AzVMDscExtension -Version '2.76' -ResourceGroupName $resourceGroup -VMName $vmName -ArchiveStorageAccountName $storageName -ArchiveBlobName 'iisInstall.ps1.zip' -AutoUpdate -ConfigurationName 'IISInstall'