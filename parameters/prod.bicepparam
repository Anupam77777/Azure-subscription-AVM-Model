// =============================================================================
// parameters/prod.bicepparam
// Same template, production values. Uses the hub gateway (VPN/ExpressRoute).
// =============================================================================

using '../main.bicep'

// ---------- Subscription ----------
param subscriptionAliasName = 'sub-spoke-prod-eastus'
param subscriptionDisplayName = 'Spoke Prod (East US)'
param subscriptionBillingScope = '/providers/Microsoft.Billing/billingAccounts/1234567/enrollmentAccounts/987654'
param subscriptionWorkload = 'Production'
param subscriptionManagementGroupId = 'mg-landingzones-corp'
param subscriptionTags = {
  environment: 'prod'
  workload: 'spoke-network'
  managedBy: 'bicep-avm'
}

// ---------- Spoke VNet ----------
param virtualNetworkName = 'vnet-spoke-prod-eastus'
param virtualNetworkLocation = 'eastus'
param virtualNetworkResourceGroupName = 'rg-spoke-prod-eastus'
param virtualNetworkAddressSpace = [
  '10.30.0.0/16'
]
param virtualNetworkSubnets = [
  {
    name: 'snet-workload'
    addressPrefix: '10.30.1.0/24'
  }
  {
    name: 'snet-private-endpoints'
    addressPrefix: '10.30.2.0/24'
  }
  {
    name: 'snet-appgw'
    addressPrefix: '10.30.3.0/24'
  }
]

// ---------- Hub peering ----------
param hubNetworkResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-prod-eastus/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod-eastus'
// Spoke routes on-prem traffic via the hub gateway. Requires a gateway in the hub.
param useHubGateway = true

param resourceProviders = {
  'Microsoft.Network': []
}
