# What is velocitee?

velocitee turns a pile of unconfigured hardware into a documented, running
infrastructure stack — without making the operator learn the entire stack of
provisioner tools that normally hide under "infrastructure as code."

The user describes their hardware and what they want in a single
`velocitee.yml` file. velocitee runs a guided pipeline, one engine at a time,
and each engine writes a structured handoff manifest the next engine reads.
Pick up wherever your hardware already is.

## The pipeline

```
bare metal ──► VME ──► VNE ──► VSE ──► VLE ──► documented, running stack
```

<!-- ENGINE-STATUS:BEGIN region=engine-table -->
| Engine  | Phase | Status  | Description |
|---------|:-----:|---------|-------------|
| **VME** | 1     | Alpha   | Bare-metal provisioning — PXE boot + unattended OS install (Proxmox VE, Ubuntu Server). Two backends: `builtin` seed stack or `maas` (optional). |
| **VNE** | 2     | Alpha   | Network configuration — OPNsense VM, VLANs, DHCP, DNS, firewall. Two working backends via the renderer registry. Discovery + Path B (`vne join`) for existing networks. |
| VSE     | 3     | Planned | Services — containerised stack deployment, idempotent configuration |
| VLE     | 4     | Planned | Lifecycle — monitoring, drift detection, auto-docs, single-command repair |
<!-- ENGINE-STATUS:END region=engine-table -->

Each engine is independently useful. You don't need the full pipeline to get
value from VME.

## Open core

The four engines are open source under [**Apache 2.0**](https://www.apache.org/licenses/LICENSE-2.0).
Self-host, fork, modify, redistribute, embed in a commercial product — go
ahead. We'd rather grow the community than build a copyleft moat.

A hosted layer above the engines is intended eventually — config generation, a
config registry, drift alerts. **None of it exists.** There is no hosted
service, no account system, and nothing to buy. The engines are the product, and
they are complete on their own.

"Open core" here describes the intended shape of the project, not a product line
you are missing out on today.

## Provisioner-agnostic by design

`velocitee.yml` expresses **intent** — "create a VLAN with this CIDR", "open
this port" — never provisioner syntax. Each engine ships a small set of
*renderers*, one per provisioner backend. You pick yours in `velocitee.yml`:

```yaml
velocitee:
  provisioner: "velocitee-native"   # or: opentofu+ansible
```

Adding a new provisioner means writing one Renderer subclass. Nothing in the
engine logic changes. See the [renderer model](architecture/renderers.md).

## Who it's for

Small nonprofits, low-budget orgs, school labs, homelabs — anywhere with real
infrastructure but no full-time platform team. Operators with limited
technical depth get a guided pipeline; experienced operators get a thin,
auditable wrapper over their existing tools.

## What's next

- Run [VME's getting-started](vme/getting-started.md) to see the metal phase
  in action.
- Skim the [architecture overview](architecture/pipeline.md) for how the
  engines compose.
- The [`velocitee.yml` reference](reference/velocitee-yml.md) is the source of
  truth for every config option.
