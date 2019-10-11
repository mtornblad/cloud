# cloud
Various scripts and template used for cloud deployments


https://github.com/mtornblad/cloud/blob/master/Azure/networks.json

https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmtornblad%2Fcloud%2Fmaster%2FAzure%2Fnetworks.json

%2Fmtornblad%2Fcloud%2Fmaster%2FAzure%2Fnetworks.json


,
        {
            "type": "Microsoft.Network/networkSecurityGroups",
            "name": "new-nsg",
            "location": "[resourceGroup().location]",
            "apiVersion": "2019-07-01",
            "properties": {
                "securityRules": [
                    {
                        "name": "AllowVnetInBound",
                        "properties": {
                            "access": "Allow",
                            "description": "Allow inbound traffic from all VMs in VNET",
                            "destinationAddressPrefix": "VirtualNetwork",
                            "destinationPortRange": "*",
                            "direction": "Inbound",
                            "name": "AllowVnetInBound",
                            "priority": 65000,
                            "protocol": "*",
                            "sourceAddressPrefix": "VirtualNetwork",
                            "sourcePortRange": "*"
                        }
                    }
                ]
            }
        }