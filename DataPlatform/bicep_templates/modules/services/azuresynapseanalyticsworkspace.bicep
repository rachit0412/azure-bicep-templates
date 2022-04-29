 //Author: Rachit Gupta
// This template is used to create a Synapse workspace.

targetScope = 'resourceGroup'


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

@description('The password for the SQL Administrator.')
@secure()
param synapseAnalyticsSqlAdministratorLoginPassword string 

param synapseSqlAdminGroupName string = ''
param synapseSqlAdminGroupObjectID string = ''
//@description('Specify whether managed private end point is needed.')
//param createManagedPrivateEndpoint bool = true

// synapse filesystem name
@description('Filesystem name')
param synapseFileSystemId string
//var synapseFileSystem = 'synws'
var synapseFileSystem = length(split(synapseFileSystemId, '/')) >= 13 ? last(split(synapseFileSystemId, '/')) : 'incorrectSegmentLength'

// managed resource group name
@description('Workspace managed resource group. The resource group name uniquely identifies the resource group within the user subscriptionId.')
var managedResourceGroupName = 'mrg-${synapseAnalyticsWorkspaceName}'

resource synapseAnalyticsWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' = if (deployAzureSynapseAnalyticsWorkspace) {
  name: synapseAnalyticsWorkspaceName
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'  
  }
  properties: {
    azureADOnlyAuthentication: false
    defaultDataLakeStorage: {
      //resourceId: storageAccounts_dlsprweugdwh_externalid
      //createManagedPrivateEndpoint: createManagedPrivateEndpoint
      accountUrl: synapseWorkspaceAccountUrl
      filesystem: synapseFileSystem
    }
    sqlAdministratorLogin: synapseAnalyticsSqlAdministratorLogin
    sqlAdministratorLoginPassword: synapseAnalyticsSqlAdministratorLoginPassword
    managedResourceGroupName: toUpper(managedResourceGroupName)
    managedVirtualNetwork: 'default'
    managedVirtualNetworkSettings: {
      preventDataExfiltration: true
      linkedAccessCheckOnTargetResource: true
      allowedAadTenantIdsForLinking: [
      ]
    }
    publicNetworkAccess: 'Disabled'
    trustedServiceBypassEnabled: false
    encryption: {
    }
  }
}

resource synapseManagedIdentitySqlControlSettings 'Microsoft.Synapse/workspaces/managedIdentitySqlControlSettings@2021-06-01' =  if (deployAzureSynapseAnalyticsWorkspace) {
  parent: synapseAnalyticsWorkspace
  name: 'default'
  properties: {
    grantSqlControlToManagedIdentity: {
      desiredState: 'Enabled'
    }
  }
}

resource synapseAadAdministrators 'Microsoft.Synapse/workspaces/administrators@2021-06-01' = if ((deployAzureSynapseAnalyticsWorkspace) && !empty(synapseSqlAdminGroupName) && !empty(synapseSqlAdminGroupObjectID)) {
  parent: synapseAnalyticsWorkspace
  name: 'activeDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: synapseSqlAdminGroupName
    sid: synapseSqlAdminGroupObjectID
    tenantId: subscription().tenantId
  }
}

output synapseId string = deployAzureSynapseAnalyticsWorkspace ? synapseAnalyticsWorkspace.id : ''
