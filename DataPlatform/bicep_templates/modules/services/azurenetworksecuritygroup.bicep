
 //Author: Rachit Gupta
//This template applies a newly created NSG to an existing subnet.

@description('Condition to run the module or not.')
param deployNetworkSecurityGroup bool

@description('Azure region of the deployment')
param location string

@description('Tags to be assigned to the KeyVault.')
param resourceTags object

@description('Name of the network security group')
param nsgName string
/*
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
resource networkSecurityGroupName 'Microsoft.Network/networkSecurityGroups@2021-05-01' = if(deployNetworkSecurityGroup) {
  name: toUpper(nsgName)
  location: location
  tags: resourceTags
  properties: {
    securityRules: [
      //{
        //name: nsgSecurityRuleName
        //properties: {
          //description: nsgSecurityRuleDesc
          //protocol: nsgSecurityProtocol
          //sourcePortRange: nsgSecuritySourcePortRange
          //destinationPortRange: nsgSecurityDestinationPortRange
          //sourceAddressPrefix: nsgSecuritySourceAddressPrefix
          //destinationAddressPrefix: nsgSecurityDestinationAddressPrefix
          //access: nsgSecurityAccess
          //priority: nsgSecurityPriority
          //direction: nsgSecurityDirection
        //}
      //}
    ]
  }
}

output nsgId string = deployNetworkSecurityGroup ? networkSecurityGroupName.id : ''
output nsgName string = deployNetworkSecurityGroup ? networkSecurityGroupName.name : ''
