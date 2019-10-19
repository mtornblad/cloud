$resourceGroup = 'admin'
$storageName = 'shared'
$configurationPath = '.\dsc\newforest.ps1'
#Publish the configuration script to user storage

Publish-AzVMDscConfiguration -ConfigurationPath $configurationPath -ResourceGroupName $resourceGroup -StorageAccountName $storageName -force 
#-ConfigurationDataPath '.\dsc\newforest.psd1'
#Set the VM to run the DSC configuration
# Set-AzVMDscExtension -Version '2.76' -ResourceGroupName $resourceGroup -VMName $vmName -ArchiveStorageAccountName $storageName -ArchiveBlobName "newforest.ps1" -AutoUpdate -ConfigurationName 'NewForest'