// =============================================================================
// main.bicep  (MANAGEMENT GROUP SCOPE)
// A thin wrapper around the official AVM "subscription vending" pattern module.
// One module call creates the subscription under a management group AND builds
// the RG + spoke VNet + bidirectional hub peering.
//
// Deploy with:  az deployment mg create --management-group-id <mg> ...
//
// >>> PIN THE VERSION <<<
// The AVM module is versioned. The tag below is a known-good baseline; bump it
// to the latest before you deploy. In VS Code, type the ':' after the module
// path and the Bicep extension will list available versions. See the README.
// =============================================================================

targetScope = 'managementGroup'

// ---------- Subscription ----------
@description('Alias name for the subscription (unique in tenant).')
param subscriptionAliasName string

@description('Display name shown in the portal.')
param subscriptionDisplayName string

@description('''Billing scope resource ID.
EA:  /providers/Microsoft.Billing/billingAccounts/{ba}/enrollmentAccounts/{ea}
MCA: /providers/Microsoft.Billing/billingAccounts/{ba}/billingProfiles/{bp}/invoiceSections/{is}''')
param subscriptionBillingScope string

@allowed([ 'Production', 'DevTest' ])
param subscriptionWorkload string = 'Production'

@description('Short ID of the management group the subscription is placed under.')
param subscriptionManagementGroupId string

@description('Tags applied to the subscription.')
param subscriptionTags object = {}

// ---------- Spoke VNet ----------
param virtualNetworkName string
param virtualNetworkLocation string
param virtualNetworkResourceGroupName string
param virtualNetworkAddressSpace array

@description('Subnets: [ { name: ..., addressPrefix: ..., delegation: ... (optional) } ].')
param virtualNetworkSubnets array = []

// ---------- Hub peering ----------
@description('Full resource ID of the existing hub VNet to peer with.')
param hubNetworkResourceId string

@description('True only if the spoke should use the hub gateway (VPN/ExpressRoute).')
param useHubGateway bool = false

// ---------- Resource provider registration (optional) ----------
@description('Resource providers/features to register in the new subscription.')
param resourceProviders object = {}

// =============================================================================
// AVM subscription-vending pattern module
// =============================================================================
module subVending 'br/public:avm/ptn/lz/sub-vending:0.3.0' = {
  name: 'lz-${subscriptionAliasName}'
  params: {
    // Subscription + MG placement
    subscriptionAliasEnabled: true
    subscriptionAliasName: subscriptionAliasName
    subscriptionDisplayName: subscriptionDisplayName
    subscriptionBillingScope: subscriptionBillingScope
    subscriptionWorkload: subscriptionWorkload
    subscriptionManagementGroupAssociationEnabled: true
    subscriptionManagementGroupId: subscriptionManagementGroupId
    subscriptionTags: subscriptionTags

    // Spoke VNet (RG is created by the module)
    virtualNetworkEnabled: true
    virtualNetworkName: virtualNetworkName
    virtualNetworkLocation: virtualNetworkLocation
    virtualNetworkResourceGroupName: virtualNetworkResourceGroupName
    virtualNetworkAddressSpace: virtualNetworkAddressSpace
    virtualNetworkSubnets: virtualNetworkSubnets

    // Bidirectional hub peering (module handles both sides)
    virtualNetworkPeeringEnabled: true
    hubNetworkResourceId: hubNetworkResourceId
    virtualNetworkUseRemoteGateways: useHubGateway

    // Provider registration
    resourceProviders: resourceProviders
  }
}

output subscriptionId string = subVending.outputs.subscriptionId
