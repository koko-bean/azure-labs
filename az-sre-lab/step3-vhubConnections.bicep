targetScope = 'resourceGroup'

@description('Name of the existing Virtual Hub in THIS resource group scope.')
param vhubName string

@description('Remote VNet resource IDs (spokes).')
param appVnetId string
param svcVnetId string

@description('Naming tokens for connection objects.')
param base string
param instance string = '01'

param tags object = {}

resource vhub 'Microsoft.Network/virtualHubs@2024-01-01' existing = {
  name: vhubName
}

// Child resources are created under the parent hub in this same RG scope. [3](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/child-resource-name-type)
resource appHubConn 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: '${base}-spk-app-vhubconn-${instance}'
  parent: vhub
  properties: {
    remoteVirtualNetwork: { id: appVnetId }
    enableInternetSecurity: false
  }
}

resource svcHubConn 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: '${base}-spk-svc-vhubconn-${instance}'
  parent: vhub
  properties: {
    remoteVirtualNetwork: { id: svcVnetId }
    enableInternetSecurity: false
  }
}

output appHubConnectionId string = appHubConn.id
output svcHubConnectionId string = svcHubConn.id
