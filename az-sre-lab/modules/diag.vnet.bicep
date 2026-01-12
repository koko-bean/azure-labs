
targetScope = 'resourceGroup'

@description('Name of the existing VNet in this resource group.')
param vnetName string

@description('Log Analytics Workspace resource ID.')
param lawId string

@description('Diagnostic setting name.')
param diagName string

resource vnet 'Microsoft.Network/virtualNetworks@2025-01-01' existing = {
  name: vnetName
}

resource vnetDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagName
  scope: vnet
  properties: {
    workspaceId: lawId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output vnetDiagnosticSettingId string = vnetDiag.id
