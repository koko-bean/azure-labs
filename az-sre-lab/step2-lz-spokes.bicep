
targetScope = 'resourceGroup'

@description('Azure region for all resources.')
param location string = 'centralus'

@description('Org / prefix token (e.g., lab).')
param org string = 'lab'

@description('Environment token (e.g., dev, test, prd).')
param env string = 'dev'

@description('Region code token (e.g., cus).')
param regionCode string = 'cus'

@description('Instance number for repeatable deployments.')
param instance string = '01'

@description('Resource ID of the existing Virtual Hub created in Step 1 (portal).')
param virtualHubId string

@description('Address space for App spoke VNet.')
param appSpokeCidr string = '10.0.16.0/22'

@description('Address space for Shared Services spoke VNet.')
param svcSpokeCidr string = '10.0.20.0/22'

@description('Optional tags.')
param tags object = {
  workload: 'sre-lab'
  environment: env
  region: regionCode
}

var base = '${org}-${env}-${regionCode}'

// Existing Virtual Hub reference
resource vhub 'Microsoft.Network/virtualHubs@2024-01-01' existing = {
  id: virtualHubId
}

// -----------------------------
// APP SPOKE (VNet + Subnets + NSG)
// -----------------------------
var appVnetName = '${base}-spk-app-vnet-${instance}'
var appNsgName  = '${base}-spk-app-nsg-${instance}'
var appConnName = '${base}-spk-app-vhubconn-${instance}'

resource appNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: appNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH-From-MyIP'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet' // replace with your public IP/CIDR later
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

resource appVnet 'Microsoft.Network/virtualNetworks@2025-01-01' = {
  name: appVnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        appSpokeCidr
      ]
    }
  }
}

// Subnets (child resources)
resource appSubnetWeb 'Microsoft.Network/virtualNetworks/subnets@2025-01-01' = {
  name: 'app-web'
  parent: appVnet
  properties: {
    addressPrefix: '10.0.16.0/25'
    networkSecurityGroup: {
      id: appNsg.id
    }
  }
}

resource appSubnetApi 'Microsoft.Network/virtualNetworks/subnets@2025-01-01' = {
  name: 'app-api'
  parent: appVnet
  properties: {
    addressPrefix: '10.0.16.128/25'
    networkSecurityGroup: {
      id: appNsg.id
    }
  }
}

resource appSubnetPe 'Microsoft.Network/virtualNetworks/subnets@2025-01-01' = {
  name: 'private-endpoints'
  parent: appVnet
  properties: {
    addressPrefix: '10.0.17.0/26'
    privateEndpointNetworkPolicies: 'Disabled'
    networkSecurityGroup: {
      id: appNsg.id
    }
  }
}

// -----------------------------
// SVC SPOKE (VNet + Subnets + NSG)
// -----------------------------
var svcVnetName = '${base}-spk-svc-vnet-${instance}'
var svcNsgName  = '${base}-spk-svc-nsg-${instance}'
var svcConnName = '${base}-spk-svc-vhubconn-${instance}'

resource svcNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: svcNsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'Allow-DNS-From-AppSpoke'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Udp'
          sourceAddressPrefix: appSpokeCidr
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '53'
        }
      }
      {
        name: 'Deny-All-Inbound'
        properties: {
          priority: 4096
          direction: 'Inbound'
          access: 'Deny'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

resource svcVnet 'Microsoft.Network/virtualNetworks@2025-01-01' = {
  name: svcVnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        svcSpokeCidr
      ]
    }
  }
}

resource svcSubnetShared 'Microsoft.Network/virtualNetworks/subnets@2025-01-01' = {
  name: 'shared-services'
  parent: svcVnet
  properties: {
    addressPrefix: '10.0.20.0/24'
    networkSecurityGroup: {
      id: svcNsg.id
    }
  }
}

resource svcSubnetMgmt 'Microsoft.Network/virtualNetworks/subnets@2025-01-01' = {
  name: 'management'
  parent: svcVnet
  properties: {
    addressPrefix: '10.0.21.0/24'
    networkSecurityGroup: {
      id: svcNsg.id
    }
  }
}

// -----------------------------
// vHub Connections (spokes -> vHub)
// -----------------------------
// Microsoft.Network/virtualHubs/hubVirtualNetworkConnections per Microsoft Learn [1](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/virtualhubs/hubvirtualnetworkconnections)
resource appHubConn 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: appConnName
  parent: vhub
  properties: {
    remoteVirtualNetwork: {
      id: appVnet.id
    }
    enableInternetSecurity: false
  }
}

resource svcHubConn 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2024-01-01' = {
  name: svcConnName
  parent: vhub
  properties: {
    remoteVirtualNetwork: {
      id: svcVnet.id
    }
    enableInternetSecurity: false
  }
}

// Outputs
output appVnetId string = appVnet.id
output svcVnetId string = svcVnet.id
output appHubConnectionId string = appHubConn.id
output svcHubConnectionId string = svcHubConn.id
output appNsgId string = appNsg.id
output svcNsgId string = svcNsg.id
