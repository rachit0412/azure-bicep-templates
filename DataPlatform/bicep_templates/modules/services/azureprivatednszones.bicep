// Author: Rachit Gupta
// This template is used to create Private DNS Zones.

param vnetId string
param vnetLinkName string
param resourceTags object
param deployPrivateDnsZone bool 
param privateDnsZoneNames array


@description('To create a private DnsZone')
resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' =  [for item in privateDnsZoneNames: if(deployPrivateDnsZone) {
  name: item
  location: 'global'
  tags: resourceTags
  properties: {}
}]

@description('To integrate virtual network with private DnsZone')
resource privateDnsZones_virtualNetworkLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for item in privateDnsZoneNames: if(deployPrivateDnsZone) {
  name: '${item}/${toUpper(vnetLinkName)}'
  location: 'global'
  dependsOn: [
    privateDnsZones
  ]
  tags: resourceTags
  properties: {
    virtualNetwork: {
      id: vnetId //resourceId('Microsoft.Network/virtualNetworks', vnetId)
    }
    registrationEnabled: false
  }
}]

// Outputs
output privateDnsZoneIdDataFactory string = deployPrivateDnsZone ? '${resourceGroup().id}/providers/Microsoft.Network/privateDnsZones/privatelink.datafactory.azure.net' : ''
output privateDnsZoneIdDfs string = deployPrivateDnsZone ? '${resourceGroup().id}/providers/Microsoft.Network/privateDnsZones/privatelink.dfs.${environment().suffixes.storage}' : ''
output privateDnsZoneIdBlob string = deployPrivateDnsZone ? '${resourceGroup().id}/providers/Microsoft.Network/privateDnsZones/privatelink.blob.${environment().suffixes.storage}' : ''
output privateDnsZoneIdKeyVault string = deployPrivateDnsZone ? '${resourceGroup().id}/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net' : ''
output privateDnsZoneIdSynapse string = deployPrivateDnsZone ? '${resourceGroup().id}/providers/Microsoft.Network/privateDnsZones/privatelink.azuresynapse.net' : ''
output privateDnsZoneIdSynapseDev string = deployPrivateDnsZone ? '${resourceGroup().id}/providers/Microsoft.Network/privateDnsZones/privatelink.dev.azuresynapse.net' : ''
output privateDnsZoneIdSynapseSql string = deployPrivateDnsZone ? '${resourceGroup().id}/providers/Microsoft.Network/privateDnsZones/privatelink.sql.azuresynapse.net' : ''
output privateDnsZoneIdSqlServer string = deployPrivateDnsZone ? '${resourceGroup().id}/providers/Microsoft.Network/privateDnsZones/privatelink.${environment().suffixes.sqlServerHostname}' : ''
