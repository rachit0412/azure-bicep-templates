 //Author: Rachit Gupta
//This key vault create script will create the service.

//@description('enable or disable purge protection.')
//param enablePurgeProtection bool = false

@description('Specifies the name of the key vault.')
param keyVaultName string

@description('Specifies the Azure location where the key vault should be created.')
param location string

@description('Tags to be assigned to the KeyVault.')
param resourceTags object

@description('softDelete data retention days, only used if enableSoftDelete is true. It accepts >=7 and <=90.')
param deleteRetentionInDays int

@description('Condition to run the module or not.')
param deployKeyVault bool

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

/*
@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
param objectId string

@description('Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keysPermissions array

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array
*/

/*
@description('Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keysPermissions array = [
  'list'
]

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array = [
  'list'
]
*/

@description('Specifies whether the key vault is a standard vault or a premium vault.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = if (deployKeyVault) {
  name: toUpper(keyVaultName)
  location: location
  tags: resourceTags
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: skuName
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [

      ]
      virtualNetworkRules: [

      ]
    }
    accessPolicies: [
      /*{
        objectId: toUpper(objectId)
        tenantId: tenantId
        permissions: {
          keys: keysPermissions
          secrets: secretsPermissions
        }
      }*/
    ]
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableRbacAuthorization: false
    enableSoftDelete: true
    //enablePurgeProtection: enablePurgeProtection
    enabledForDeployment: false
    softDeleteRetentionInDays: deleteRetentionInDays
    
  }
}

output keyVaultName string = deployKeyVault ? keyVault.name : ''
output keyVaultId string = deployKeyVault ? keyVault.id : ''
output keyVaultUri string = deployKeyVault ? keyVault.properties.vaultUri : ''
