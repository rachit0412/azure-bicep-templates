// Author: Rachit Gupta
// This template is used to create a SQL Server and Database.

targetScope = 'resourceGroup'

// Parameters
@description('Location for all resources.')
param location string
@description('The name of the SQL logical server.')
param sqlserverName string
@description('The dictionary of tag names and values.')
param resourceTags object
@description('The username for the SQL Server.')
param administratorUsername string

@description('The password for the SQL Server.')
@secure()
param administratorPassword string

@description('The name of the SQL Database.')
param sqlserverMetastoreDbName string 
//param sqlserverAdminGroupName string
//param sqlserverAdminGroupObjectID string
@description('deploy SQL server or not')
param deployAzureSqlServer bool
@description('deploy SQL Database or not')
param deployAzureSqlDb bool


// Resources
resource sqlServer 'Microsoft.Sql/servers@2021-08-01-preview' = if(deployAzureSqlServer) {
  name: sqlserverName
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: administratorUsername
    administratorLoginPassword: administratorPassword
    administrators: {}
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    version: '12.0'
  }
}

/*
resource sqlserverAdministrators 'Microsoft.Sql/servers/administrators@2021-08-01-preview' = if (deployAzureSqlServer && !empty(sqlserverAdminGroupName) && !empty(sqlserverAdminGroupObjectID)) {
  parent: sqlServer
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: sqlserverAdminGroupName
    sid: sqlserverAdminGroupObjectID
    tenantId: subscription().tenantId
  }
}
*/

resource sqlserverMetastoreDb 'Microsoft.Sql/servers/databases@2021-08-01-preview' = if(deployAzureSqlDb) {
  parent: sqlServer
  name: toUpper(sqlserverMetastoreDbName)
  location: location
  tags: resourceTags
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    autoPauseDelay: -1
    catalogCollation: 'DATABASE_DEFAULT'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    createMode: 'Default'
    readScale: 'Disabled'
    highAvailabilityReplicaCount: 0
    licenseType: 'LicenseIncluded'
    maxSizeBytes: 524288000
    minCapacity: 1
    requestedBackupStorageRedundancy: 'Geo'
    zoneRedundant: false
  }
}

// Outputs
output sqlServerId string = deployAzureSqlServer ? sqlServer.id : ''
output sqlServerDatabaseName string = deployAzureSqlDb ? sqlserverMetastoreDbName : ''
