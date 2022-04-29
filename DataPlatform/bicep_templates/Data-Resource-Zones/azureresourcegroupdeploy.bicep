// Author: Rachit Gupta

targetScope = 'subscription'

// Choose and set resource list to deploy. 
param deployResourceGroup bool = true

// Validate parameters against a set of values
@allowed([
  'TD'
  'P'
  'A'
])
@description('Provide a valid environment type')
param environmentType string

@allowed([
  'weu'
  'neu'
  'WEU'
  'NEU'
])
@description('Provide a valid short location name. Current list support weu and neu')
param locationShortName string

@minLength(3)
@maxLength(15)
@description('Provide a functional name for the resources. Use only lower case letters with max 10 length. The name must be unique across Azure.')
param functionalName string

// Parameter list
param subscriptionID string

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

// Location will be used in each module
param location string


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

//  Resource group name
var fullResourceGroupName =  'RG-${toUpper(environmentType)}-${toUpper(locationShortName)}-${toUpper(organisationName)}-${toUpper(functionalName)}'

// module to deploy - resource group
module rg '../modules/services/azureresourcegroupcreation.bicep' = {
  name: 'resourceGroupDeploy'
  scope: subscription(subscriptionID)
  params: {
    resourceGroupName: fullResourceGroupName
    location: location
    resourceTags: resourceTags
    deployResourceGroup: deployResourceGroup
  }  
}
