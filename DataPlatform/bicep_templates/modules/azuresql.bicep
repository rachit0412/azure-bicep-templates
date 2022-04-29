// Author: Rachit Gupta
// This template is used to call the module that will deploy SQL Server and Database.

targetScope = 'resourceGroup'

// Parameters
@description('Name of the key vault in the existing resource group')
param keyVaultName string

@description('Location for all resources.')
param location string

@description('The name of the SQL logical server.')
param sqlserverName string

@description('The dictionary of tag names and values.')
param resourceTags object

@description('The username for the SQL Server.')
param administratorUsernameSqlServer string

@description('The name of the SQL Database.')
param sqlserverMetastoreDbName string 

@description('deploy SQL server or not')
param deployAzureSqlServer bool

@description('deploy SQL Database or not')
param deployAzureSqlDb bool

// Reference to already existing key vault in the current resource group
resource kvref 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = if (deployAzureSqlServer || deployAzureSqlDb) {     
  name: keyVaultName
}

// module to deploy - Sql Server and a database

module sqlServer001 '../modules/services/azuresqlsrvanddb.bicep' = if(deployAzureSqlServer || deployAzureSqlDb) {
  name: 'sqlserveranddbDeploy_Adf'
  scope: resourceGroup()
  dependsOn: [
    kvref
  ]
  params: {
    location: location
    resourceTags: resourceTags
    administratorUsername: administratorUsernameSqlServer
    administratorPassword: kvref.getSecret(administratorUsernameSqlServer)
    sqlserverName: sqlserverName
    sqlserverMetastoreDbName: sqlserverMetastoreDbName
    deployAzureSqlServer: deployAzureSqlServer
    deployAzureSqlDb: deployAzureSqlDb
  }
}

// Outputs
output sqlServerId string = deployAzureSqlServer ? sqlServer001.outputs.sqlServerId : ''
output sqlServerDatabaseName string = deployAzureSqlDb ? sqlServer001.outputs.sqlServerDatabaseName : ''
