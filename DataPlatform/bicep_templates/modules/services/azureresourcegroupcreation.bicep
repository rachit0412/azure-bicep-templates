targetScope = 'subscription'

param resourceGroupName string
param location string
param deployResourceGroup bool
param resourceTags object

resource newResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = if(deployResourceGroup) {
  name: resourceGroupName
  location: location
  tags: resourceTags
}
