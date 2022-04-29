// Author: Rachit Gupta
// This template is used to create diagnostic setting. 

param resourceType string 

@description('Storage account resource id. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountId string = ''

@description('Log analytics workspace resource id. Only required if enableDiagnostics is set to true.')
param logAnalyticsWorkspaceId string = ''

@description('Diagnostic setting name.')
param diagnosticSettingsName string = ''

@description('set to true if diagnostic logs is required')
param deployDiagnosticSettings bool

//@description('set to true if diagnostic logs is required for nsg')
//param deployNetworkSecurityGroup bool

@description('Name of a Diagnostic Log category group for a resource type this setting is applied to.')
param logCategoryGroup array

@description('Name of a Diagnostic Metric category for a resource type this setting is applied to')
param metricsCategory string

//param deployDiagnosticSettings1 bool = false

var diagnosticsName = 'dgs-${diagnosticSettingsName}'

resource nsgref 'Microsoft.Network/networkSecurityGroups@2021-05-01' existing = if (deployDiagnosticSettings) {     
  name: diagnosticSettingsName
}

/*
resource vnetref 'Microsoft.Network/virtualNetworks@2021-05-01' existing = if (deployDiagnosticSettings) {     
  name: diagnosticSettingsName
}

resource synwref 'Microsoft.Synapse/workspaces@2021-06-01' existing = if (deployDiagnosticSettings) {     
  name: diagnosticSettingsName
}
*/

resource diagnostics_all 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (deployDiagnosticSettings && !empty(logCategoryGroup) && !empty(metricsCategory) && resourceType == 'vnet'){
  name: toUpper(diagnosticsName)
  scope: nsgref
  dependsOn:[
  ]
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    logs: [ for category in logCategoryGroup: {
        categoryGroup: category
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: false
        }
      }]
    metrics: [
      {
        category: metricsCategory
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: false
        }
      }
    ]
  }
}


resource diagnostics_nsg_logs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (deployDiagnosticSettings && !empty(logCategoryGroup) && empty(metricsCategory) && resourceType == 'nsg') {
  name: toUpper(diagnosticsName)
  scope: nsgref
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    logs: [ for category in logCategoryGroup: {
        categoryGroup: category
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: false
        }
      }]
  }
}


resource diagnostics_metrics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (deployDiagnosticSettings && empty(logCategoryGroup) && !empty(metricsCategory)  && resourceType == 'storage') {
  name: toUpper(diagnosticsName)
  scope: nsgref
  dependsOn:[
  ]
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    metrics: [
      {
        category: metricsCategory
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: false
        }
      }
    ]
  }
}
