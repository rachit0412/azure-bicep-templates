// Author: Rachit Gupta
// This template is used to create data factory

param dataFactoryName string
param location string
param resourceTags object
param deployDataFactory bool

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = if (deployDataFactory) {
  name: toUpper(dataFactoryName)
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    globalParameters: {}
  }
}
