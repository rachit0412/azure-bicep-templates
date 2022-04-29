// Author: Rachit Gupta
// This data management zone deploy script supports deployment of various modules mentioned in Section: Deployment list.
// Note: NSG, Vnet and peerings are already supplied from BDR group so no need to re-deploy those resources. 
// Note: BDR prefers to keep everything Uppercase hence Upper has been added when a module is called. 

@description('Section: Deployment list. Choose and set resource list to deploy. ')
param deployNetworkSecurityGroup bool
param deployVirtualNetwork bool
param deployPrivateEndPoint bool 
param deployPrivateDnsZone bool 
param deployPrivateDnsZoneGroups bool
param deployKeyVault bool
param deployLogAnalyticsWorkspace bool

// Location will be used in each module
param location string = resourceGroup().location

// Validate generic parameters against a set of values
@allowed([
  'P'
])
@description('Provide a valid environment type')
param environmentType string

@minLength(3)
@maxLength(15)
@description('Provide a functional name for the resources. Use only lower case letters with max 10 length. The name must be unique across Azure.')
param functionalName string

@allowed([
  'weu'
  'neu'
  'WEU'
  'NEU'
])
@description('Provide a valid short location name. Current list support weu and neu')
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

//  module to deploy - network security group
module nsg '../modules/services/azurenetworksecuritygroup.bicep' = if (deployNetworkSecurityGroup) { 
  name: 'networkSecurityGroupDeploy'
  params: {
    location: location
    resourceTags: resourceTags 
    nsgName: 'nsg-snet-${standardName_withHyphen}'
    deployNetworkSecurityGroup: deployNetworkSecurityGroup
  }
}

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

// parameters for kv
param deleteRetentionInDays int

// Key Vault name 
var fullKeyVaultName = 'kv-${standardName}'

// module to deploy - key vault
module kv '../modules/services/azurekeyvault.bicep' = if (deployKeyVault) {
  name: 'keyVaultDeploy'
  params: {
    keyVaultName: fullKeyVaultName
    location: location
    resourceTags: resourceTags
    deleteRetentionInDays: deleteRetentionInDays
    deployKeyVault: deployKeyVault
  }  
}


//resource kvref 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = if (deployKeyVault) {     
//  name: toUpper(fullKeyVaultName)
//}


// variable to hold short name of data lake storage. This would be used further in multiple variables and parameters.
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

// param to hold private dns zones names
param privateDnsZoneNames array

// Variable to hold private dns zones name
var fullVirtualNetworkLinkName = 'vnet-lnm-${standardName_withHyphen}'

// module to deploy - create private dns zone as given in the array parameter & integrate with virtual networks
module pdnsz '../modules/services/azureprivatednszones.bicep' =  if (deployPrivateDnsZone) {
  name: 'privateDnszonesDeploy-${privateKvEndpointObject}'
  dependsOn: [
    vn
  ]
  params: {
    vnetId: vn.outputs.vnetId
    vnetLinkName: fullVirtualNetworkLinkName
    privateDnsZoneNames: privateDnsZoneNames
    resourceTags: resourceTags
    deployPrivateDnsZone: deployPrivateDnsZone
  }  
}

// module to deploy - create configuration between private end point and dns zone
module kvpdnszg '../modules/services/azureprivatednszonegroups.bicep' = if(deployKeyVault) {
  name: 'privateDnsZoneGroupsDeploy-${privateKvEndpointObject}'
  dependsOn: [
    kvpe
    pdnsz
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

// Variable to hold private dns zones name
var logAnalyticsWorkspaceName = 'log-${standardName_withHyphen}'

// module to deploy - log analytics service
module log '../modules/services/azureloganalyticsworkspace.bicep' =  if (deployLogAnalyticsWorkspace) {
  name: 'logAnanalyticsDeploy-01'
  dependsOn: [
    vn
  ]
  params: {
    logAnalyticsWorkspaceName: toUpper(logAnalyticsWorkspaceName)
    location: location
    resourceTags: resourceTags
    deployLogAnalyticsWorkspace: deployLogAnalyticsWorkspace
  }  
}
