// Author: Rachit Gupta
// This template is used to create a route table.
@description('Route table name')
param routeTableName string

param routeTableAddressPrefix string
param firewallPrivateIp string
param nextHopType string
param location string
param resourceTags object
param deployRouteTable bool

@description('Enable delete lock')
param enableRouteTableDeleteLock bool


resource routeTable 'Microsoft.Network/routeTables@2020-11-01' = if(deployRouteTable) {
  name: routeTableName
  location: location
  tags: resourceTags
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: firewallPrivateIp != '' ? 'Within-Subnet' : 'Within-Subnet-to-Firewall'
        properties: {
          addressPrefix: routeTableAddressPrefix
          nextHopType: nextHopType != '' ? nextHopType : 'None'
          nextHopIpAddress: firewallPrivateIp != '' ? firewallPrivateIp : null
        }
      }
    ]
  }
}

var lockName = 'lck-${routeTable.name}'

resource lockRouteTable 'Microsoft.Authorization/locks@2017-04-01' = if (enableRouteTableDeleteLock) {
  scope: routeTable
  name: lockName
  properties: {
    level: 'CanNotDelete'
  }
}

output routeTableId string = deployRouteTable ? routeTable.id : ''
