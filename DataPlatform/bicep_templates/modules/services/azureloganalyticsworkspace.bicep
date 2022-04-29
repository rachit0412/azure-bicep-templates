// Author: Rachit Gupta
// This template is used to create a Log Analytics workspace.

// Parameters
param location string
param resourceTags object
param logAnalyticsWorkspaceName string
param deployLogAnalyticsWorkspace bool

// Variables

// Resources
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = if (deployLogAnalyticsWorkspace) {
  name: logAnalyticsWorkspaceName
  location: location
  tags: resourceTags
  properties: {
    features: {}
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 120
    sku: {
      name: 'PerGB2018'
    }
  }
}

// Outputs
output logAnalyticsWorkspaceId string = deployLogAnalyticsWorkspace ? logAnalyticsWorkspace.id : ''
