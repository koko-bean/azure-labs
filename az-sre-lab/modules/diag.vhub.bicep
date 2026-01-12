
targetScope = 'resourceGroup'

@description('Virtual Hub name (must exist in this RG scope).')
param vhubName string

@description('Log Analytics Workspace resource ID (destination).')
param lawId string

@description('Diagnostic setting name.')
param diagName string

resource vhub 'Microsoft.Network/virtualHubs@2024-01-01' existing = {
  name: vhubName
}

resource vhubDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagName
  scope: vhub
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

output vhubDiagnosticSettingId string = vhubDiag.id
