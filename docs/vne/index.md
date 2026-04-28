# VNE — network configuration engine

**Phase 2.** Takes a provisioned Proxmox host (the output of VME) and turns it
into a fully configured network: an OPNsense VM, VLANs, DHCP, DNS, and a
firewall baseline — without the operator ever touching HCL, playbooks, or
`config.xml`.

## What VNE delivers

- An OPNsense VM created on Proxmox (provider-agnostic — pick your renderer).
- WAN and LAN interface assignments, with API access enabled before first boot.
- VLANs as declared in `velocitee.yml`, with optional DHCP scopes per VLAN.
- Unbound DNS forwarding to your chosen upstreams, with a local domain.
- A declarative firewall baseline — default-block, with allow-listed flows.
- A handoff manifest VSE will read.

## Pages

- [Getting started](getting-started.md) — first run, end to end.
- [Provisioner backends](provisioners.md) — `velocitee-native`, `opentofu+ansible`, the registry.
- [Configuration reference](configuration.md) — every field in the `vne:` block.

## Why "provisioner-agnostic"?

VNE expresses **intent** ("VLAN 10 with this CIDR exists") in a Pydantic
schema. *Renderers* translate that intent into a specific provisioner's
language. Today VNE ships:

- `velocitee-native` — pure Python, drives Proxmox + OPNsense REST directly.
- `opentofu+ansible` — OpenTofu creates the VM, Ansible configures the network.
  Hard phase gate: phase 2 never runs after phase 1 fails.

11 other backends (Pulumi, Salt, Chef, Puppet, …) are reserved as stubs.
Adding a new one is one Renderer subclass and one registry entry. See the
[renderer model](../architecture/renderers.md).

## Idempotency and resume

Every step VNE takes is idempotent. State persists in
`vne/state/vne.state.json` — interrupted runs resume from the last successful
step. State is versioned; corruption is loud, never silently overwritten.

Every renderer also performs a *live probe* before acting — if the resource
exists already (or was deleted by hand), VNE reconciles to truth, not to
state.

## Verification gate

After every backend, VNE runs four checks in order:

1. OPNsense API reachable.
2. DNS resolution working — resolves a known external hostname through
   OPNsense's Unbound.
3. Internet egress — TCP-connect to a known anycast IP. (TCP, not ICMP — many
   networks block ICMP.)
4. VLAN interfaces present and enabled.

**VNE refuses to write its handoff manifest unless all four pass.** The
system is left as-is (no auto-rollback). Resolve, re-run, succeed.

## Source

- Repository: [velocit-ee/core](https://github.com/velocit-ee/core), `vne/`
- License: Apache 2.0
