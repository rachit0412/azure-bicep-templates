 //Author: Rachit Gupta
// This template is used to call the module that will create a Synapse workspace.

targetScope = 'resourceGroup'

@description('Name of the key vault in the existing resource group')
param keyVaultName string

@description('Specifies the Azure location where the key vault should be created.')
param location string

@description('Tags to be assigned to the KeyVault.')
param resourceTags object

@description('Tags to be assigned to the KeyVault.')
param synapseAnalyticsWorkspaceName string

@description('Account URL')
param synapseWorkspaceAccountUrl string

@description('Specify whether synapse workspace should be deployed.')
param deployAzureSynapseAnalyticsWorkspace bool

// username and password for sql
@description('The username of the SQL Administrator.')
param synapseAnalyticsSqlAdministratorLogin string

@description('Datalake storage Id.')
param synapseFileSystemId string 

param synapseSqlAdminGroupName string 
param synapseSqlAdminGroupObjectID string 

// Reference to already existing key vault in the current resource group
resource kvref 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = if (deployAzureSynapseAnalyticsWorkspace) {     
  name: keyVaultName
}

// module to deploy - synapse analytics workspace
module synw '../modules/services/azuresynapseanalyticsworkspace.bicep' = if(deployAzureSynapseAnalyticsWorkspace) {
  name: 'synapseAnalyticsWorkspaceDeploy'
  dependsOn: [
    kvref
  ]
  params: {
    location: location
    resourceTags: resourceTags
    synapseAnalyticsWorkspaceName: synapseAnalyticsWorkspaceName
    synapseWorkspaceAccountUrl: synapseWorkspaceAccountUrl
    deployAzureSynapseAnalyticsWorkspace: deployAzureSynapseAnalyticsWorkspace
    synapseAnalyticsSqlAdministratorLogin: synapseAnalyticsSqlAdministratorLogin//last(synwsecret.outputs.secretName,'/') //
    synapseAnalyticsSqlAdministratorLoginPassword: kvref.getSecret(synapseAnalyticsSqlAdministratorLogin)//'${fullKeyVaultName}.getSecret(${synapseAnalyticsSqlAdministratorLogin})'//synwsecret.name //synapseAnalyticsSqlAdministratorLoginPassword
    synapseSqlAdminGroupName: synapseSqlAdminGroupName
    synapseSqlAdminGroupObjectID: synapseSqlAdminGroupObjectID
    synapseFileSystemId: synapseFileSystemId
  }  
}

output synapseId string = deployAzureSynapseAnalyticsWorkspace ? synw.outputs.synapseId : ''
