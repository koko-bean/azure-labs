
targetScope = 'resourceGroup'

param location string = 'centralus'
param org string = 'lab'
param env string = 'dev'
param regionCode string = 'cus'
param instance string = '01'

@description('Resource group where the Virtual Hub exists (platform/vWAN RG).')
param vhubResourceGroup string = 'rg-lab-dev-cus-plat-vwan'

@description('Virtual Hub name created in Step 1.')
param vhubName string = 'lab-dev-cus-plat-vhub-01'

@description('Resource IDs of spoke VNets to enable diagnostics on.')
param spokeVnetIds array

param lawRetentionDays int = 30

param tags object = {
  workload: 'sre-lab'
  environment: env
  region: regionCode
  owner: 'kohen'
}

var base = '${org}-${env}-${regionCode}'
var lawName = '${base}-ops-law-${instance}'
var saName = toLower('st${uniqueString(resourceGroup().id, base, instance)}')

// Log Analytics Workspace (in THIS RG)
resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: lawName
  location: location
  tags: tags
  properties: {
    retentionInDays: lawRetentionDays
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    sku: { name: 'PerGB2018' }
  }
}

// Storage Account for flow logs (in THIS RG)
resource flowStorage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: saName
  location: location
  tags: tags
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
  }
}

// ✅ vHub diagnostics deployed via a MODULE scoped to the vHub RG
module vhubDiagnostics 'modules/diag.vhub.bicep' = {
  name: 'diag-vhub'
  scope: resourceGroup(vhubResourceGroup) // <- key fix (module scope)
  params: {
    vhubName: vhubName
    lawId: law.id
    diagName: '${base}-diag-vhub-${instance}'
  }
}





// Deploy VNet diagnostics in the *target VNet RG* using a scoped module. [3](https://microsoft.sharepoint.com/teams/ASDIPRelease/_layouts/15/Doc.aspx?sourcedoc=%7B7D8023CB-36CE-4F06-93A1-C231E3C31893%7D&file=Module%2005%20-%20bicep%20-%20Modules.pptx&action=edit&mobileredirect=true&DefaultItemOpen=1)[1](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/diagnostics/bcp139)
module vnetDiagnostics 'modules/diag.vnet.bicep' = [for (vnetId, i) in spokeVnetIds: {
  name: 'diag-vnet-${i + 1}'
  scope: resourceGroup(
    split(vnetId, '/')[2], // subscriptionId
    split(vnetId, '/')[4]  // resourceGroupName
  )
  params: {
    vnetName: last(split(vnetId, '/'))
    lawId: law.id
    diagName: '${base}-diag-vnet-${i + 1}-${instance}'
  }
}]

output logAnalyticsWorkspaceId string = law.id
output flowStorageAccountId string = flowStorage.id
output vhubDiagnosticSettingId string = vhubDiagnostics.outputs.vhubDiagnosticSettingId
