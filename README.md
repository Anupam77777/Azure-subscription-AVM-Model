# Subscription Vending with AVM (Bicep + Azure DevOps)

This version uses the **official Azure Verified Module** `avm/ptn/lz/sub-vending`
instead of hand-rolled Bicep. A single module call creates the subscription under
a management group, then builds the resource group, the spoke VNet, and the
**bidirectional** peering to a central hub. Everything is driven from one
`.bicepparam` file per landing zone.

## What replaced what

| Hand-rolled (before)                | AVM (now)                                   |
|-------------------------------------|---------------------------------------------|
| `main.bicep` (tenant scope, alias)  | `main.bicep` (MG scope, calls AVM module)   |
| `modules/subscription-resources.bicep` | handled by the AVM module               |
| `modules/vnet.bicep`                | handled by the AVM module                   |
| `modules/peering.bicep` (x2)        | handled by the AVM module (`virtualNetworkPeeringEnabled`) |

The entire `modules/` folder is gone. You now consume a maintained, versioned,
Well-Architected-aligned module from the public Bicep registry.

## Structure

```
.
├── main.bicep                  # MG scope: thin wrapper over the AVM module
├── bicepconfig.json
├── parameters/
│   ├── dev.bicepparam          # <-- copy this to add a new landing zone
│   └── prod.bicepparam
└── pipelines/
    └── azure-pipelines.yml     # az deployment mg create
```

## ⚠️ Pin the module version

`main.bicep` references `br/public:avm/ptn/lz/sub-vending:0.3.0` as a working
baseline. The module is versioned and updated regularly — **bump this to the
latest before deploying.** Ways to find the current version:

- In VS Code with the Bicep extension, type the `:` after the module path — it
  lists all published versions.
- Browse the registry tags: `https://mcr.microsoft.com/v2/bicep/avm/ptn/lz/sub-vending/tags/list`
- Check the module's page: https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/lz/sub-vending

If you bump across a major/minor line, re-check the parameter names in that
version's README (schemas occasionally change, e.g. subnet fields).

## Deploy

```bash
az deployment mg create \
  --name lz-manual \
  --management-group-id mg-landingzones-corp \
  --location eastus \
  --template-file main.bicep \
  --parameters parameters/dev.bicepparam
```

Notes: management-group deployments require `--location` (metadata location) and
the CLI restores the AVM module from the registry automatically (the build agent
needs outbound internet, which hosted ADO agents have).

## Required permissions (unchanged from before)

1. **Management group:** Owner/Contributor on the deployment MG — for the MG-scope
   deployment and to place the subscription.
2. **Billing scope:** a subscription-creation role (EA enrollment-account owner, or
   MCA invoice-section owner). Authorizes subscription creation.
3. **Hub RG/subscription:** Network Contributor — the module creates the hub→spoke
   side of the peering there.

## Key parameters (passed to the AVM module)

- `subscriptionAliasName`, `subscriptionDisplayName`, `subscriptionBillingScope`,
  `subscriptionWorkload`, `subscriptionManagementGroupId` — the subscription + placement.
- `virtualNetworkName` / `virtualNetworkLocation` / `virtualNetworkResourceGroupName`
  / `virtualNetworkAddressSpace` / `virtualNetworkSubnets` — the spoke VNet.
- `hubNetworkResourceId` + `virtualNetworkPeeringEnabled` — the hub peering.
- `useHubGateway` → maps to `virtualNetworkUseRemoteGateways`. Set true only if the
  hub has a VPN/ExpressRoute gateway, else peering creation fails.
- `resourceProviders` — optionally register RPs/features in the new subscription
  (the module handles the readiness/registration wait for you).

## Adding a new landing zone

1. `cp parameters/dev.bicepparam parameters/<name>.bicepparam`
2. Change the values (subscription name, MG, VNet, address space, hub ID).
3. Add `<name>` to the `values:` list in the pipeline, run, and pick it.

## Why AVM here

You trade some transparency and control for a maintained module that already
handles subnets, both peering directions, resource-provider registration and
readiness waits, budgets, and role assignments. It also unlocks extras via
parameters you're not using yet — additional VNets, Bastion, NAT gateway, IPAM
pools, vWAN topology — without writing more Bicep.
