param storageAccountType string
param storageAccountName string
param location string
param resourceTags object
param deployStorageAccount bool
param containerNames array

var synapseResourceAccessrules = [for subscriptionId in array(subscription().subscriptionId): {
  tenantId: subscription().tenantId
  resourceId: '/subscriptions/${subscriptionId}/resourceGroups/*/providers/Microsoft.Synapse/workspaces/*'
}]

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = if (deployStorageAccount) {
  name:  storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind:'StorageV2'
  properties: {
    azureFilesIdentityBasedAuthentication: {
      directoryServiceOptions: 'None'
    }
    encryption: {
    services: {
      file: {
        keyType: 'Account'
        enabled: true
      }
      blob: {
        keyType: 'Account'
        enabled: true
      }
      table: {
        enabled: true
        keyType: 'Account'
      }
      queue: {
        enabled: true
        keyType: 'Account'
      }
    }
    keySource: 'Microsoft.Storage'
  }
  networkAcls: {
    bypass: 'AzureServices'
    virtualNetworkRules: [
    ]
    ipRules: [
    ]
    defaultAction: 'Deny'
    resourceAccessRules: synapseResourceAccessrules //Use union to add more access rules.
  }
  accessTier: 'Hot'
  minimumTlsVersion: 'TLS1_2'
  allowBlobPublicAccess: false
  isHnsEnabled: true
  supportsHttpsTrafficOnly: true
  allowSharedKeyAccess: true
}
  tags: resourceTags
}

//adding management policies to storage account
resource storageManagementPolicies 'Microsoft.Storage/storageAccounts/managementPolicies@2021-08-01' =  if (deployStorageAccount) {
  parent: storageAccount
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          enabled: true
          name: 'default'
          type: 'Lifecycle'
          definition: {
            actions: {
              baseBlob: {
                // enableAutoTierToHotFromCool: true  // Not available for HNS storage yet
                tierToCool: {
                  // daysAfterLastAccessTimeGreaterThan: 90  // Not available for HNS storage yet
                  daysAfterModificationGreaterThan: 90
                }
              }
              snapshot: {
                tierToCool: {
                  daysAfterCreationGreaterThan: 90
                }
              }
              version: {
                tierToCool: {
                  daysAfterCreationGreaterThan: 90
                }
              }
            }
            filters: {
              blobTypes: [
                'blockBlob'
              ]
              prefixMatch: []
            }
          }
        }
      ]
    }
  }
}

resource storageBlobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-02-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    cors: {
      corsRules: []
    }
  }
}

resource storageAccountContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = [for containerName in containerNames: if (deployStorageAccount) {
  //parent: storageBlobServices
  name: '${storageAccount.name}/default/${containerName}'
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}]

output accountURL string = deployStorageAccount ? storageAccount.properties.primaryEndpoints.dfs : ''
output storageFileSystemIds array = [for containerName in containerNames: {
  storageFileSystemId: resourceId('Microsoft.Storage/storageAccounts/blobServices/containers', storageAccountName, 'default', containerName)
}]
