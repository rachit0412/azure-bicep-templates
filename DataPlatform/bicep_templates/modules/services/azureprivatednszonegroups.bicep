// Author: Rachit Gupta
// This template is used to integrate Private DNS Zones with private end points
// Note:
// 1) For Synapse integrate private end point either with Sql or SqlOnDemand but not BOTH. Both have same DNS name. 

param privateDnsNameShortId string
param resourceGroupNameManage string
param subscriptionIdManage string
param privateEndpointObject string
param standardName string
param deployPrivateDnsZoneGroups bool 


// re-valuation whether the resource should be deployed or not. Since SqlOnDemand and Sql has same dns link we only have to run it for one.
//var deployPrivateDnsZoneGroups_Conditional = privateDnsNameShortId != 'Sql' ? deployPrivateDnsZoneGroups : false


// Generate correct private link name for DNS zones
var dnsToLink = {
  blob: {
    privateDnsName: 'privatelink.blob.${environment().suffixes.storage}'
  }
  dfs: {
    privateDnsName: 'privatelink.dfs.${environment().suffixes.storage}'
  }
  dataFactory: {
    privateDnsName: 'privatelink.datafactory.azure.net'
  }
  vault: {
    privateDnsName: 'privatelink.vaultcore.azure.net'
  }
  SqlOnDemand: {
    privateDnsName: 'privatelink.sql.azuresynapse.net'
  }
  Sql: {
    privateDnsName: 'privatelink.sql.azuresynapse.net'
  }
  Dev: {
    privateDnsName: 'privatelink.dev.azuresynapse.net'
  }
  Web: {
    privateDnsName: 'privatelink.azuresynapse.net'
  }
  sqlServer: {
    privateDnsName: 'privatelink${environment().suffixes.sqlServerHostname}' //do not add a dot after privatelink 
  }
}


// Variable to hold private dns zones name
var privateDnsZoneName = toLower(dnsToLink[privateDnsNameShortId].privateDnsName)
var privateDnsZoneConfigurationName = 'cname-${replace(privateDnsZoneName,'.','-')}'
var privateDnsZoneGroupName = privateDnsNameShortId != privateEndpointObject ? 'pe-${toLower(privateEndpointObject)}-${standardName}-${toLower(privateDnsNameShortId)}/default' : 'pe-${toLower(privateEndpointObject)}-${standardName}/default'

@description('To refer an existing global private DnsZone')
resource privateDnsName 'Microsoft.Network/privateDnsZones@2020-06-01' existing = if(deployPrivateDnsZoneGroups) {
  name: privateDnsZoneName
  scope: resourceGroup(subscriptionIdManage, resourceGroupNameManage)
}

// Below resource should be executed for all the endpoints.
@description('To integrate private end points with Private DnsZone')
resource privateDnsName_privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = if(deployPrivateDnsZoneGroups) {
  name: toUpper(privateDnsZoneGroupName)
  dependsOn: [
    privateDnsName
  ]
  properties: {
    privateDnsZoneConfigs: [
      {
        name: toUpper(privateDnsZoneConfigurationName)
        properties: {
          privateDnsZoneId: privateDnsName.id //dnsToLink[privateDnsNameShortId].full 
        }
      }
    ]
  }
}

