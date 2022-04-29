param standardName string
//param privateEndpointConnectionName string
param location string
param resourceTags object
param privateEndpointObject string
param resourceName string
param vnetName string
param subnetName string
param deployPrivateEndPoint bool
param groupId string

var privateEndpointName = groupId != privateEndpointObject ? 'pe-${toLower(privateEndpointObject)}-${standardName}-${toLower(groupId)}' : 'pe-${toLower(privateEndpointObject)}-${standardName}' 
var privateEndpointConnectionName = groupId != privateEndpointObject ? 'pe-cnm-${toLower(privateEndpointObject)}-${standardName}-${toLower(groupId)}' : 'pe-cnm-${toLower(privateEndpointObject)}-${standardName}'


// generated variable based on asset
var createPeConditional = {
  dls: {
    resourceType: 'Microsoft.Storage/storageAccounts'
    //resourceName: fullStorageAccountName
  }
  dataFactory: {
    resourceType: 'Microsoft.DataFactory/factories'
    //resourceName: fullDataFactoryName
  }
  synw: {
    resourceType: 'Microsoft.Synapse/workspaces'
    //resourceName: fullSynapseAnalyticsWorkspaceName
  }
  vault: {
    resourceType: 'Microsoft.keyVault/vaults'
    //resourceName: fullKeyVaultName
  }
  sqlServer: {
    resourceType: 'Microsoft.Sql/servers'
    //resourceName: fullKeyVaultName
  }
}

var resourceType = createPeConditional[privateEndpointObject].resourceType
//var resourceName = createPepConditional[deployingAsset].resourceName

resource privateEndpointName_resource 'Microsoft.Network/privateEndpoints@2021-05-01' = if(deployPrivateEndPoint) {
  name: toUpper(privateEndpointName)
  location: location
  tags: resourceTags
  properties: {
    privateLinkServiceConnections: [
      {
        name: toUpper(privateEndpointConnectionName)
        properties: {
          privateLinkServiceId: resourceId(resourceType, toUpper(resourceName))
          groupIds: [
            groupId
          ]
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', toUpper(vnetName), toUpper(subnetName))
    }
  }
}

output outprivateendpointname string = deployPrivateEndPoint ?  privateEndpointName_resource.name : ''
