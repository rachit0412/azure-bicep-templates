// Author: Rachit Gupta
// This data landing zone deploy script supports deployment of various modules mentioned in Section: Deployment list.
// Pre-requisite: 
// 1) First deploy data management zone.
// 2) then data landing zone should be deployed.
// 3) Check and update parameters as necessary. Some parameters are dependent on the names given in management zones. Check carefully.

@description('Section: Deployment list. Choose and set resource list to deploy. ')
param deployNetworkSecurityGroup bool
//param deployRouteTable bool
param deployVirtualNetwork bool
param deployPrivateEndPoint bool 
//param deployPrivateDnsZone bool 
param deployPrivateDnsZoneGroups bool
param deployStorageAccount bool
param deployDataFactory bool
param deployKeyVault bool
param deployKeyVaultSecret bool 
param deployAzureSynapseAnalyticsWorkspace bool
param deployVirtualNetworkPeerings bool
param deployAzureSqlServer bool
param deployAzureSqlDb bool
//param deployDiagnosticSettings bool


// Location will be used in each module
param location string = resourceGroup().location

// Validate generic parameters against a set of values
@allowed([
  'TD'
  'P'
  'MNG'
])
@description('Provide a valid environment type for data landing zone.')
param environmentType string

@minLength(3)
@maxLength(15)
@description('Provide a functional name for the resources. The name must be unique across Azure.')
param functionalName string

@minLength(3)
@maxLength(15)
@description('Provide a functional name for the manage resources group. The name must be unique across Azure.')
param functionalNameManage string

@allowed([
  'weu'
  'neu'
  'WEU'
  'NEU'
])
@description('Provide a valid short location name. Current list support weu and neu.')
param locationShortName string

// Parameter list for Resource Tags
@description('Contains organisation name.')
param organisationName string 
@description('Contains project name.')
param projectName string 
@description('Contains cost center name.')
param costCentre string 
@description('Contains backup name.')
param backUp string 
@description('Contains disaster recovery.')
param disasterRecovery string 
@description('Contains environment name.')
param environment string 
@description('Contains ip secondary policy name.')
param ipSecPolicy string 
@description('Contains owner name.')
param owner string 
@description('Contains display name.')
param displayName string 
@description('Contains logical project name.')
param logicalName string 
@description('Contains provider name.')
param provider string 

@description('Provide valid resource group name used for data management zone.')
param resourceGroupNameManage string

@description('Provide valid subscription ID used for data management zone.')
param subscriptionIdManage string

/*
"subscriptionIdManage": {
  "value": "1e360853-xxxx-xxxx-xxxx-853be58e56c6"
},  
@description('Provide valid subscription ID used in data management zone.')
param subscriptionIdManage string

@description('Provide valid workspace name used in log analytics deployed on data management zone.')
param logAnalyticsWorkspaceNameManage string
*/

// param synapseAnalyticsSqlAdministratorLogin string

/*
// param list for route table
param routeTableAddressPrefix string
param firewallPrivateIp string
param nextHopType string
param enableRouteTableDeleteLock bool
*/

// Resource tags will be used in each module
param resourceTags object = {
  backUp: backUp
  costCentre: costCentre
  disasterRecovery: disasterRecovery
  environment: environment
  IPsecPolicy: ipSecPolicy
  owner: owner
  displayName: displayName
  projectName: projectName
  logicalName: logicalName
  provider: provider
}

// variables to store a standard name
var standardName = '${toLower(environmentType)}${toLower(locationShortName)}${toLower(organisationName)}${toLower(functionalName)}'
var standardName_withHyphen = '${toLower(environmentType)}-${toLower(locationShortName)}-${toLower(organisationName)}-${toLower(functionalName)}'

/*
// parameter list for NSG
param nsgSecurityRuleName string
param nsgSecurityRuleDesc string
param nsgSecurityProtocol string
param nsgSecuritySourcePortRange string
param nsgSecurityDestinationPortRange string
param nsgSecuritySourceAddressPrefix string
param nsgSecurityDestinationAddressPrefix string
param nsgSecurityAccess string
param nsgSecurityPriority int
param nsgSecurityDirection string
*/  

//  module to deploy - network security group
module nsg '../modules/services/azurenetworksecuritygroup.bicep' = if (deployNetworkSecurityGroup) { 
  name: 'networkSecurityGroupDeploy'
  params: {
    location: location
    resourceTags: resourceTags 
    nsgName: 'nsg-snet-${standardName_withHyphen}'
    /*nsgSecurityRuleName: nsgSecurityRuleName
    nsgSecurityRuleDesc: nsgSecurityRuleDesc
    nsgSecurityProtocol: nsgSecurityProtocol
    nsgSecuritySourcePortRange: nsgSecuritySourcePortRange
    nsgSecurityDestinationPortRange: nsgSecurityDestinationPortRange
    nsgSecuritySourceAddressPrefix: nsgSecuritySourceAddressPrefix
    nsgSecurityDestinationAddressPrefix: nsgSecurityDestinationAddressPrefix
    nsgSecurityAccess: nsgSecurityAccess
    nsgSecurityPriority: nsgSecurityPriority
    nsgSecurityDirection: nsgSecurityDirection*/
    deployNetworkSecurityGroup: deployNetworkSecurityGroup
  }
}



/*
    "logAnalyticsWorkspaceNameManage": {
      "value": "LOG-P-WEU-mycompany-DATAHUBMGMT"
    },
    "defaultMetricsCategory": {
      "value": "AllMetrics"
    },
    "defaultLogCategoryGroup": {
      "value": [
        "allLogs"
      ]}

// Parameter list 
@description('Storage account resource id. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountId string = ''

@description('Log analytics workspace resource id. Only required if enableDiagnostics is set to true.')
param logAnalyticsWorkspaceId string = '/subscriptions/${subscriptionIdManage}/resourcegroups/${resourceGroupNameManage}/providers/microsoft.operationalinsights/workspaces/${logAnalyticsWorkspaceNameManage}'

@description('Name of a Diagnostic Log category group for a resource type this setting is applied to.')
param defaultLogCategoryGroup array

@description('Name of a Diagnostic Metric category for a resource type this setting is applied to')
param defaultMetricsCategory string

var resourceType = 'nsg'
// module to deploy - diagnostic setting for vnet
module dgsnsg '../modules/auxiliary/azurediagnosticsettings.bicep' = if (deployNetworkSecurityGroup) {
  name: 'diagnosticSettingsDeploy_NSG'
  dependsOn: [
    nsg
  ]
  params: {
    resourceType: resourceType
    diagnosticStorageAccountId: diagnosticStorageAccountId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    diagnosticSettingsName: nsg.outputs.nsgName //represent service delivering diagnostic logs
    logCategoryGroup: defaultLogCategoryGroup
    metricsCategory: ''
    deployDiagnosticSettings: deployDiagnosticSettings
    //deployNetworkSecurityGroup: deployNetworkSecurityGroup
  }  
}
*/


/*
// variable to create standard route table name
var fullRouteTableName = 'rt-${standardName_withHyphen}'
//  module to deploy - route table
module rt 'modules/services/azureroutetable.bicep' = { 
  name: 'routeTableDeploy'
  params: {
    location: location
    resourceTags: resourceTags 
    routeTableName: fullRouteTableName
    routeTableAddressPrefix: routeTableAddressPrefix
    firewallPrivateIp: firewallPrivateIp
    nextHopType: nextHopType
    deployRouteTable: deployRouteTable
    enableRouteTableDeleteLock: enableRouteTableDeleteLock
  }
}
*/

// Parameters for Vnet and Snet.
param virtualNetworkPrefix string
param subnetPrefix string

// variables to store Vnet and Subnet name 
var fullVirtualNetworkName = 'vnet-${standardName_withHyphen}'
var fullSubnetName = 'snet-${standardName_withHyphen}'

// module to deploy - Vnet and Subnet
module vn '../modules/services/azurevirtualnetwork.bicep' = if (deployVirtualNetwork) {
  name: 'virtualNetworkDeploy'
  dependsOn: [
    nsg
  ]
  params: {
    virtualNetworkName: fullVirtualNetworkName
    subnetName: fullSubnetName
    virtualNetworkPrefix: virtualNetworkPrefix
    subnetPrefix: subnetPrefix
    nsgId: nsg.outputs.nsgId
    location: location
    resourceTags: resourceTags
    deployVirtualNetwork: deployVirtualNetwork
  }  
}

/*
// module to deploy - diagnostic setting for vnet
module dgsvnet '../modules/auxiliary/azurediagnosticsettings.bicep' = if (deployVirtualNetwork) {
  name: 'diagnosticSettingsDeploy_Vnet'
  dependsOn: [
    vn
  ]
  params: {
    diagnosticStorageAccountId: diagnosticStorageAccountId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    diagnosticSettingsName: vn.outputs.vnetName //represent service delivering diagnostic logs
    logCategoryGroup: defaultLogCategoryGroup
    metricsCategory: defaultMetricsCategory
    deployDiagnosticSettings: deployDiagnosticSettings
  }  
}
*/

// Parameter list specific for storage account/ Data lake storage
@description('below parameter contain the list of container names that would be created as part of deployment')
param containerNames array

// allowed storage account types
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
  'Premium_LRS'
])
@description('Provide a valid storage account type')
param storageAccountType string

// Storage Account name 
var fullStorageAccountName = 'dls${standardName}'

// module to deploy - storage account - data lake
module dls '../modules/services/azurestorageaccount.bicep' = if (deployStorageAccount) {
  name: 'storageAccountDeploy'
  dependsOn: [
    vn
  ]
  params: {
    storageAccountName: fullStorageAccountName
    storageAccountType: storageAccountType
    location: location
    resourceTags: resourceTags
    deployStorageAccount: deployStorageAccount
    containerNames: containerNames
  }  
}

// variable to hold short name of data lake storage. This would be used further in multiple variables and parameters.
var privateDlsEndpointObject = 'dls'

// Special Parameter list required for multiple end points and dns creation of storage account i.e. bloc, dfs, file etc...
@description('below parameter contain the list of groupIDs that would create private end points and DNS as part of deployment')
param groupIdSaArray array

// module to deploy - Private end point for storage account
module dlspe '../modules/auxiliary/azureprivateendpoint.bicep' = [for groupID in groupIdSaArray:  if(deployStorageAccount) {
  name: 'privateEndPointDeploy-${privateDlsEndpointObject}-${groupID}'
  dependsOn: [
    dls
  ]
  params: {
    standardName: standardName_withHyphen
    location: location
    resourceTags: resourceTags
    resourceName: fullStorageAccountName
    privateEndpointObject: privateDlsEndpointObject
    vnetName: fullVirtualNetworkName
    subnetName: fullSubnetName
    deployPrivateEndPoint: deployPrivateEndPoint
    groupId: groupID
  }  
}]


// module to deploy - private dns zone group to link private end points with DNS.
module dlspdnszg '../modules/services/azureprivatednszonegroups.bicep' = [for groupID in groupIdSaArray:  if(deployStorageAccount) {
  name: 'privateDnsZoneGroupsDeploy-${privateDlsEndpointObject}-${groupID}'
  dependsOn: [
    dlspe
  ]
  params: {
    privateDnsNameShortId: groupID
    resourceGroupNameManage: resourceGroupNameManage
    subscriptionIdManage: subscriptionIdManage
    standardName: standardName_withHyphen
    privateEndpointObject: privateDlsEndpointObject
    deployPrivateDnsZoneGroups: deployPrivateDnsZoneGroups
  }  
}]

// Data Factory name 
var fullDataFactoryName = 'adf-${standardName_withHyphen}'

// module to deploy - data factory
module adf '../modules/services/azuredatafactory.bicep' = if (deployDataFactory) {
  name: 'dataFactoryDeploy'
  dependsOn: [
    vn
  ]
  params: {
    dataFactoryName: fullDataFactoryName
    location: location
    resourceTags: resourceTags
    deployDataFactory: deployDataFactory
  }  
}


// variable to hold short name of data lake storage. This would be used further in multiple variables and parameters.
var privateAdfEndpointObject = 'dataFactory'

// module to deploy - Private end point for storage account
module adfpe '../modules/auxiliary/azureprivateendpoint.bicep' = if(deployDataFactory) {
  name: 'privateEndPointDeploy-${privateAdfEndpointObject}'
  dependsOn: [
    adf
  ]
  params: {
    standardName: standardName_withHyphen
    location: location
    resourceTags: resourceTags
    resourceName: fullDataFactoryName
    privateEndpointObject: privateAdfEndpointObject
    vnetName: fullVirtualNetworkName
    subnetName: fullSubnetName
    deployPrivateEndPoint: deployPrivateEndPoint
    groupId: privateAdfEndpointObject
  }  
}

module adfpdnszg '../modules/services/azureprivatednszonegroups.bicep' = if(deployDataFactory) {
  name: 'privateDnsZoneGroupsDeploy-${privateAdfEndpointObject}'
  dependsOn: [
    adfpe
  ]
  params: {
    privateDnsNameShortId: privateAdfEndpointObject
    resourceGroupNameManage: resourceGroupNameManage
    subscriptionIdManage: subscriptionIdManage
    standardName: standardName_withHyphen
    privateEndpointObject: privateAdfEndpointObject
    deployPrivateDnsZoneGroups: deployPrivateDnsZoneGroups
  }  
}

// parameters for kv
param deleteRetentionInDays int

// Key Vault name 
var fullKeyVaultName = 'kv-${standardName}'

// module to deploy - key vault
module kv '../modules/services/azurekeyvault.bicep' = if (deployKeyVault) {
  name: 'keyVaultDeploy'
  dependsOn: [
    vn
  ]
  params: {
    keyVaultName: fullKeyVaultName
    location: location
    resourceTags: resourceTags
    deleteRetentionInDays: deleteRetentionInDays
    deployKeyVault: deployKeyVault
  }  
}

// variable to hold short name for key vault. 
var privateKvEndpointObject = 'vault'

// module to deploy - Private end point for Key Vault
module kvpe '../modules/auxiliary/azureprivateendpoint.bicep' = if (deployKeyVault) {
  name: 'privateEndPointDeploy-${privateKvEndpointObject}'
  dependsOn: [
    kv
  ]
  params: {
    standardName: standardName_withHyphen
    location: location
    resourceTags: resourceTags
    resourceName: fullKeyVaultName
    privateEndpointObject: privateKvEndpointObject
    vnetName: fullVirtualNetworkName
    subnetName: fullSubnetName
    deployPrivateEndPoint: deployPrivateEndPoint
    groupId: privateKvEndpointObject
  }  
}

module kvpdnszg '../modules/services/azureprivatednszonegroups.bicep' = if(deployKeyVault) {
  name: 'privateDnsZoneGroupsDeploy-${privateKvEndpointObject}'
  dependsOn: [
    kvpe
  ]
  params: {
    privateDnsNameShortId: privateKvEndpointObject
    resourceGroupNameManage: resourceGroupNameManage
    subscriptionIdManage: subscriptionIdManage
    standardName: standardName_withHyphen
    privateEndpointObject: privateKvEndpointObject
    deployPrivateDnsZoneGroups: deployPrivateDnsZoneGroups
  }  
}

/*
// Parameter list for key vault secrets
param keyVaultSecretNames array

// module to deploy - key vault secrets
module kvsecrets '../modules/services/azurekeyvaultsecret.bicep' = [for secretName in keyVaultSecretNames:  {
  name: 'keyVaultSecretDeploy-${secretName}'
  dependsOn: [
    kv
  ]
  params: {
    keyVaultName: fullKeyVaultName
    secretName: secretName
    resourceTags: resourceTags
    deployKeyVaultSecret: deployKeyVaultSecret
  }  
}]
*/

// module to deploy - key vault secrets
module synwsecret '../modules/services/azurekeyvaultsecret.bicep' = if(deployAzureSynapseAnalyticsWorkspace) {
  name: 'keyVaultSecretDeploy-SynwSQL'
  dependsOn: [
    kv
  ]
  params: {
    keyVaultName: fullKeyVaultName
    secretName: synapseAnalyticsSqlAdministratorLogin
    resourceTags: resourceTags
    deployKeyVaultSecret: deployKeyVaultSecret
  }  
}




// Synapse work space name and URL
var fullSynapseAnalyticsWorkspaceName = 'synw-${standardName_withHyphen}'
var synapseWorkspaceAccountUrl = dls.outputs.accountURL

// Synapse sql user and password
param synapseAnalyticsSqlAdministratorLogin string

// module to deploy - synapse analytics workspace
module synw '../modules/azuresynapseanalytics.bicep' = if(deployAzureSynapseAnalyticsWorkspace) {
  name: 'synapseAnalyticsDeploy'
  dependsOn: [
    dls
    synwsecret
  ]
  params: {
    location: location
    resourceTags: resourceTags
    synapseAnalyticsWorkspaceName: fullSynapseAnalyticsWorkspaceName
    synapseWorkspaceAccountUrl: synapseWorkspaceAccountUrl
    deployAzureSynapseAnalyticsWorkspace: deployAzureSynapseAnalyticsWorkspace
    synapseAnalyticsSqlAdministratorLogin: synapseAnalyticsSqlAdministratorLogin//last(synwsecret.outputs.secretName,'/') //
    keyVaultName: kv.outputs.keyVaultName
    //synapseAnalyticsSqlAdministratorLoginPassword: kvref.getSecret(synapseAnalyticsSqlAdministratorLogin)//'${fullKeyVaultName}.getSecret(${synapseAnalyticsSqlAdministratorLogin})'//synwsecret.name //synapseAnalyticsSqlAdministratorLoginPassword
    synapseSqlAdminGroupName: ''
    synapseSqlAdminGroupObjectID: ''
    synapseFileSystemId: dls.outputs.storageFileSystemIds[0].storageFileSystemId
  }  
}

//@secure()
//param synapseAnalyticsSqlAdministratorLoginPassword string 

//var synapseAnalyticsSqlAdministratorLoginPassword = '${fullKeyVaultName}.getSecret(${synapseAnalyticsSqlAdministratorLogin})'

/*
// module to deploy - synapse analytics workspace
module synw '../modules/services/azuresynapseanalyticsworkspace.bicep' = if(deployAzureSynapseAnalyticsWorkspace) {
  name: 'synapseAnalyticsWorkspaceDeploy'
  dependsOn: [
    dls
    synwsecret
  ]
  params: {
    location: location
    resourceTags: resourceTags
    synapseAnalyticsWorkspaceName: fullSynapseAnalyticsWorkspaceName
    synapseWorkspaceAccountUrl: synapseWorkspaceAccountUrl
    deployAzureSynapseAnalyticsWorkspace: deployAzureSynapseAnalyticsWorkspace
    synapseAnalyticsSqlAdministratorLogin: synapseAnalyticsSqlAdministratorLogin//last(synwsecret.outputs.secretName,'/') //
    synapseAnalyticsSqlAdministratorLoginPassword: kvref.getSecret(synapseAnalyticsSqlAdministratorLogin)//'${fullKeyVaultName}.getSecret(${synapseAnalyticsSqlAdministratorLogin})'//synwsecret.name //synapseAnalyticsSqlAdministratorLoginPassword
    synapseSqlAdminGroupName: ''
    synapseSqlAdminGroupObjectID: ''
    synapseFileSystemId: dls.outputs.storageFileSystemIds[0].storageFileSystemId
  }  
}
*/

// variable to hold short name of synapse workspace. This would be used further in multiple variables and parameters.
var privateSynwEndpointObject = 'Synw'

// Special Parameter list required for multiple end points and dns creation of storage account i.e. bloc, dfs, file etc...
@description('below parameter contain the list of groupIDs that would create private end points and DNS as part of deployment')
param groupIdSynwArray array

// module to deploy - Private end points
module synwpe '../modules/auxiliary/azureprivateendpoint.bicep' = [for groupID in groupIdSynwArray:  if(deployAzureSynapseAnalyticsWorkspace) {
  name: 'privateEndPointDeploy-${privateSynwEndpointObject}-${groupID}'
  dependsOn: [
  synw
  ]
  params: {
    standardName: standardName_withHyphen
    location: location
    resourceTags: resourceTags
    resourceName: fullSynapseAnalyticsWorkspaceName
    privateEndpointObject: privateSynwEndpointObject
    vnetName: fullVirtualNetworkName
    subnetName: fullSubnetName
    deployPrivateEndPoint: deployPrivateEndPoint
    groupId: groupID
  }  
}]

// module to deploy - private dns zone group to link private end points with DNS.
@batchSize(1) //Note: keep the batch size since it involves a loop on the same resource being reference multiple times
module synwpdnszg '../modules/services/azureprivatednszonegroups.bicep' = [for groupID in groupIdSynwArray:  if(deployAzureSynapseAnalyticsWorkspace) {
  name: 'privateDnsZoneGroupsGDeploy-${privateSynwEndpointObject}-${groupID}'
  dependsOn: [
    synwpe
  ]
  params: {
    privateDnsNameShortId: groupID
    resourceGroupNameManage: resourceGroupNameManage
    subscriptionIdManage: subscriptionIdManage
    standardName: standardName_withHyphen
    privateEndpointObject: privateSynwEndpointObject
    deployPrivateDnsZoneGroups: deployPrivateDnsZoneGroups
  }  
}]

// Parameter with manage enviroment value. 
@allowed([
  'P'
])
@description('Provide a valid environment type for management landing zone.')
param environmentManageType string 

// Variable to store vnet name created using data management zone script.
var fullManagementVirtualNetworkName = 'vnet-${toLower(environmentManageType)}-${toLower(locationShortName)}-${toLower(organisationName)}-${toLower(functionalNameManage)}'
var dataLandingZoneVnetName = length(split(vn.outputs.vnetId, '/')) >= 9 ? last(split(vn.outputs.vnetId, '/')) : 'incorrectSegmentLength'
var fullMngTodDataVnetPeeringName = '${fullManagementVirtualNetworkName}/${toUpper(fullManagementVirtualNetworkName)}-to-${toUpper(dataLandingZoneVnetName)}'

// module to deploy - Vnet peering between PR/TD with MNG
module dataManagementZoneDataLandingZoneVnetPeering '../modules/auxiliary/azurevirtualnetworkpeerings.bicep' = {
  name: 'dataManagementZoneDataLandingZoneVnetPeeringDeploy-Peer'
  scope: resourceGroup(resourceGroupNameManage)
  params: {
    //resourceGroupNameManage: resourceGroupNameManage
    dataLandingZoneVnetId: vn.outputs.vnetId
    resourceGroupNameManage: resourceGroupNameManage
    vnetPeeringName: fullMngTodDataVnetPeeringName
    dataManagementZoneVnetName: fullManagementVirtualNetworkName
    deployVirtualNetworkPeerings: deployVirtualNetworkPeerings
  }
}

var fullDataToMngVnetPeeringName = '${dataLandingZoneVnetName}/${toUpper(dataLandingZoneVnetName)}-to-${toUpper(fullManagementVirtualNetworkName)}'

// module to deploy - Vnet peering between PR/TD with MNG
module dataLandingZoneDataManagementZoneVnetPeering '../modules/auxiliary/azurevirtualnetworkpeerings.bicep' = {
  name: 'dataLandingZoneDataManagementZoneVnetPeeringDeploy-Peer'
  scope: resourceGroup()
  params: {
    //resourceGroupNameManage: resourceGroupNameManage
    dataLandingZoneVnetId: ''
    resourceGroupNameManage: resourceGroupNameManage
    vnetPeeringName: fullDataToMngVnetPeeringName
    dataManagementZoneVnetName: fullManagementVirtualNetworkName
    deployVirtualNetworkPeerings: deployVirtualNetworkPeerings
  }
}


// Parameters list
param administratorUsernameSqlServer string

// module to deploy - key vault secret for Azure sql
module sqldbsecret '../modules/services/azurekeyvaultsecret.bicep' = if(deployAzureSqlServer) {
  name: 'keyVaultSecretDeploy-AzureSqlDb'
  dependsOn: [
    kv
  ]
  params: {
    keyVaultName: fullKeyVaultName
    secretName: administratorUsernameSqlServer
    resourceTags: resourceTags
    deployKeyVaultSecret: deployKeyVaultSecret
  }  
}


// Parameter list
param sqlserverMetastoreDbName string
//param sqlserverAdminGroupObjectID string= ''
//param sqlserverAdminGroupName string= ''

// Variable
var fullSqlserverMetastoreDbName = 'sqldb-${sqlserverMetastoreDbName}'
var fullSqlServer001Name = 'sql-${standardName_withHyphen}'

// module to deploy - Sql Server and a database

module sql '../modules/azuresql.bicep' = if(deployAzureSqlServer || deployAzureSqlDb) {
  name: 'sqlserveranddbDeploy'
  scope: resourceGroup()
  dependsOn: [
    sqldbsecret
  ]
  params: {
    location: location
    resourceTags: resourceTags
    administratorUsernameSqlServer: administratorUsernameSqlServer
    keyVaultName: kv.outputs.keyVaultName
    //administratorPassword: kvref.getSecret(administratorUsernameSqlServer)
    //sqlserverAdminGroupName: sqlserverAdminGroupName
    //sqlserverAdminGroupObjectID: sqlserverAdminGroupObjectID
    sqlserverName: fullSqlServer001Name
    sqlserverMetastoreDbName: fullSqlserverMetastoreDbName
    deployAzureSqlServer: deployAzureSqlServer
    deployAzureSqlDb: deployAzureSqlDb
  }
}


// variable to hold short name for Sql Server. 
var privateSqlEndpointObject = 'sqlServer'

// module to deploy - Private end point for Sql Server
module sqlpe '../modules/auxiliary/azureprivateendpoint.bicep' = if (deployAzureSqlServer) {
  name: 'privateEndPointDeploy-${privateSqlEndpointObject}'
  dependsOn: [
    sql
  ]
  params: {
    standardName: standardName_withHyphen
    location: location
    resourceTags: resourceTags
    resourceName: fullSqlServer001Name
    privateEndpointObject: privateSqlEndpointObject
    groupId: privateSqlEndpointObject
    vnetName: fullVirtualNetworkName
    subnetName: fullSubnetName
    deployPrivateEndPoint: deployPrivateEndPoint
  }  
}

// module to deploy - Integrate SQL Server Private end point with DNS Names
module sqlpdnszg '../modules/services/azureprivatednszonegroups.bicep' = if(deployAzureSqlServer) {
  name: 'privateDnsZoneGroupsDeploy-${privateSqlEndpointObject}'
  dependsOn: [
    sqlpe
  ]
  params: {
    privateDnsNameShortId: privateSqlEndpointObject
    resourceGroupNameManage: resourceGroupNameManage
    subscriptionIdManage: subscriptionIdManage
    standardName: standardName_withHyphen
    privateEndpointObject: privateSqlEndpointObject
    deployPrivateDnsZoneGroups: deployPrivateDnsZoneGroups
  }  
}
