 //Author: Rachit Gupta
//This secret create script will create the secrets inside the given key vault.

@description('Specifies the name of the key vault.')
param keyVaultName string

@description('Condition to run the module or not.')
param deployKeyVaultSecret bool

@description('Tags to be assigned to the KeyVault.')
param resourceTags object

@description('Specifies the name of the secret that you want to create.')
param secretName string

@description('Specifies the value of the secret that you want to create.')
@secure() //Prevents it from being logged, but also removes it from output
param secretValue string = newGuid() //Can only be used as the default value for a param

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = if(deployKeyVaultSecret) {
  name: '${toUpper(keyVaultName)}/${secretName}'
  tags: resourceTags
  properties: {
    contentType: 'text/plain'
    attributes: {
      enabled: true
    }
    value: '!SEC#${secretValue}%URED!'
  }
}

output secretValueSecretUri string = deployKeyVaultSecret ? secret.properties.secretUri : ''
output secretName string = deployKeyVaultSecret ? secret.name : ''
