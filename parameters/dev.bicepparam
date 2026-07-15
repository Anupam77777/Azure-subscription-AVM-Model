// =============================================================================
// parameters/dev.bicepparam
// One file per landing zone. Copy, change values, deploy. No template edits.
// =============================================================================

using '../main.bicep'

// ---------- Subscription ----------
param subscriptionAliasName = 'sub-spoke-dev-eastus'
param subscriptionDisplayName = 'Spoke Dev (East US)'
// EA example. For MCA use the billingProfiles/invoiceSections form.
param subscriptionBillingScope = '/providers/Microsoft.Billing/billingAccounts/1234567/enrollmentAccounts/987654'
param subscriptionWorkload = 'DevTest'
param subscriptionManagementGroupId = 'mg-landingzones-corp'
param subscriptionTags = {
  environment: 'dev'
  workload: 'spoke-network'
  managedBy: 'bicep-avm'
}

// ---------- Spoke VNet ----------
param virtualNetworkName = 'vnet-spoke-dev-eastus'
param virtualNetworkLocation = 'eastus'
param virtualNetworkResourceGroupName = 'rg-spoke-dev-eastus'
param virtualNetworkAddressSpace = [
  '10.20.0.0/16'
]
param virtualNetworkSubnets = [
  {
    name: 'snet-workload'
    addressPrefix: '10.20.1.0/24'
  }
  {
    name: 'snet-private-endpoints'
    addressPrefix: '10.20.2.0/24'
  }
]

// ---------- Hub peering ----------
param hubNetworkResourceId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-hub-prod-eastus/providers/Microsoft.Network/virtualNetworks/vnet-hub-prod-eastus'
param useHubGateway = false

// ---------- Optional: register resource providers in the new sub ----------
param resourceProviders = {
  'Microsoft.Network': []
  'Microsoft.Storage': []
}
