targetScope = 'resourceGroup'

param location string = 'centralus'
param org string = 'lab'
param env string = 'dev'
param regionCode string = 'cus'
param instance string = '01'

@description('vHub resource group (where Step 1 deployed vHub)')
param vhubResourceGroup string = 'rg-lab-dev-cus-plat-vwan'

@description('vHub name (created in Step 1)')
param vhubName string = 'lab-dev-cus-plat-vhub-01'

@description('Optional tags')
param tags object = {
  workload: 'sre-lab'
  environment: env
  region: regionCode
  owner: 'kohen'
}

var base = '${org}-${env}-${regionCode}'
var appVnetName = '${base}-spk-app-vnet-${instance}'
var svcVnetName = '${base}-spk-svc-vnet-${instance}'

// --- Spoke VNets (in this RG) ---
resource appVnet 'Microsoft.Network/virtualNetworks@2025-01-01' = {
  name: appVnetName
  location: location
  tags: tags
  properties: {
    addressSpace: { addressPrefixes: [ '10.0.16.0/22' ] }
  }
}

resource svcVnet 'Microsoft.Network/virtualNetworks@2025-01-01' = {
  name: svcVnetName
  location: location
  tags: tags
  properties: {
    addressSpace: { addressPrefixes: [ '10.0.20.0/22' ] }
  }
}

// (Optional) add your subnet + NSG resources here as you already have them.

// --- vHub Connections (deploy in vHub RG via module scope) ---
module vhubConnections 'modules/vhubConnections.bicep' = {
  name: 'vhubConnections'
  scope: resourceGroup(vhubResourceGroup)
  params: {
    vhubName: vhubName
    appVnetId: appVnet.id
    svcVnetId: svcVnet.id
    base: base
    instance: instance
    tags: tags
  }
}

output appVnetId string = appVnet.id
output svcVnetId string = svcVnet.id
output appHubConnectionId string = vhubConnections.outputs.appHubConnectionId
output svcHubConnectionId string = vhubConnections.outputs.svcHubConnectionId
