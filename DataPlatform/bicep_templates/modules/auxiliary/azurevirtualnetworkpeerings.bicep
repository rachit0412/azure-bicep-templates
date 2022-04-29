// Author: Rachit Gupta
// The module contains a template to create a vnet peering connection.

targetScope = 'resourceGroup'

// Parameters
param dataLandingZoneVnetId string
param resourceGroupNameManage string
param dataManagementZoneVnetName string
param vnetPeeringName string
param deployVirtualNetworkPeerings bool

// Resources
@description('To refer an existing manage virtual network')
resource refManageVnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = if(deployVirtualNetworkPeerings) {
  name:toUpper(dataManagementZoneVnetName)
  scope: resourceGroup(resourceGroupNameManage)
}

resource dataManagementZoneDataLandingZoneVnetPeerings 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = if (deployVirtualNetworkPeerings) {
  //name: '${dataManagementZoneVnetName}/peer-${dataLandingZoneVnetName}'
  name: vnetPeeringName
  dependsOn: [
    refManageVnet
  ]
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    useRemoteGateways: false
    peeringState: 'Connected'
    remoteVirtualNetwork: {
      id: dataLandingZoneVnetId != '' ? dataLandingZoneVnetId : refManageVnet.id
    }
  }
}
/*
resource dataLandingZoneDataManagementZoneVnetPeerings 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-05-01' = if (deployVirtualNetworkPeerings) {
  //parent: checkManageVnetExists
  //name: '${dataManagementZoneVnetName}/peer-${dataLandingZoneVnetName}'
  name: '${dataLandingZoneVnetName}/peer-${dataManagementZoneVnetName}'
  dependsOn: [
    dataManagementZoneDataLandingZoneVnetPeerings
  ]
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    useRemoteGateways: false
    peeringState: 'Connected'
    remoteVirtualNetwork: {
      id: checkManageVnetExists.id
    }
  }
}
*/
// Outputs
