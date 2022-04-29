param location string
param resourceTags object
param virtualNetworkName string
param subnetName string
param virtualNetworkPrefix string
param subnetPrefix string
param nsgId string
param deployVirtualNetwork bool

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = if (deployVirtualNetwork) {
  name: toUpper(virtualNetworkName)
  location: location
  tags: resourceTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkPrefix
      ]
    }
    enableDdosProtection: false
    enableVmProtection: false
    subnets: [
      {
        name: toUpper(subnetName)
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: nsgId == '' ? null : { 
            id: nsgId 
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

output vnetName string = deployVirtualNetwork ? virtualNetwork.name : ''
output vnetId string = deployVirtualNetwork ? virtualNetwork.id : ''
output serviceSubnet string = deployVirtualNetwork ? virtualNetwork.properties.subnets[0].id : ''
