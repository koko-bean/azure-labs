
targetScope = 'resourceGroup'

@description('Deployment location for vWAN resources.')
param location string = 'centralus'

@description('Org/prefix token (e.g., lab).')
param org string = 'lab'

@description('Environment token (e.g., dev, test, prd).')
param env string = 'dev'

@description('Region code token (e.g., cus, eus).')
param regionCode string = 'cus'

@description('Instance number for repeatable deployments.')
param instance string = '01'

@description('Virtual Hub address prefix. Must not overlap with any VNet. Example: 10.0.0.0/23')
param vHubAddressPrefix string = '10.0.0.0/23'

@description('Optional tags')
param tags object = {
  workload: 'sre-lab'
  environment: env
  region: regionCode
  primaryRegion: location
  owner: 'kohen'
}

var base = '${org}-${env}-${regionCode}'
var vwanName = '${base}-plat-vwan-${instance}'
var vhubName = '${base}-plat-vhub-${instance}'

// Virtual WAN (Standard)
resource vwan 'Microsoft.Network/virtualWans@2024-01-01' = {
  name: vwanName
  location: location
  tags: tags
  properties: {
    type: 'Standard'
    disableVpnEncryption: false
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
  }
}

// Virtual Hub
resource vhub 'Microsoft.Network/virtualHubs@2024-01-01' = {
  name: vhubName
  location: location
  tags: tags
  properties: {
    addressPrefix: vHubAddressPrefix
    virtualWan: {
      id: vwan.id
    }
    sku: 'Standard'
  }
}

output virtualWanName string = vwan.name
output virtualWanId string = vwan.id
output virtualHubName string = vhub.name
output virtualHubId string = vhub.id
output virtualHubAddressPrefix string = vHubAddressPrefix
