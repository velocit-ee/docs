# Getting started with VNE

VNE configures the network on top of a Proxmox host that VME provisioned. A
first run takes 5–15 minutes — most of it waiting for the OPNsense VM to
finish first-boot.

## Prerequisites

You need:

- A successful VME run, with the handoff manifest at
  `~/vme/vme/manifests/output/<hostname>-<timestamp>.json`.
- Network reachability from the seed machine to the Proxmox host (port 8006/tcp).
- A Proxmox API token. See [creating a token](#creating-a-proxmox-api-token).
- An OPNsense ISO URL with a SHA-256 checksum.

## 1. Install VNE

```bash
curl -fsSL https://raw.githubusercontent.com/velocit-ee/core/main/vne/install.sh | bash
```

## 2. Set credentials (never put these in `velocitee.yml`)

VNE pre-flight reports every missing variable in one error, so set them all
at once:

```bash
export PROXMOX_VE_ENDPOINT="https://proxmox.lab:8006"
export PROXMOX_VE_API_TOKEN="root@pam!vne=11111111-2222-3333-4444-555555555555"
export OPNSENSE_ROOT_PASSWORD="…"
```

Optional, only if your Proxmox cert is self-signed:

```bash
export PROXMOX_VE_INSECURE=1
```

## 3. Write a `velocitee.yml`

```yaml
velocitee:
  provisioner: "velocitee-native"   # or: opentofu+ansible

vne:
  wan_interface: "ens18"
  lan_interface: "ens19"
  opnsense_version: "24.7"
  opnsense_iso_url: "https://mirror.example/opnsense-24.7-dvd.iso"
  opnsense_iso_checksum: "sha256:abcdef…"
  vlans:
    - id: 10
      name: "servers"
      cidr: "10.10.10.0/24"
      dhcp_start: "10.10.10.100"
      dhcp_end:   "10.10.10.200"
    - id: 20
      name: "clients"
      cidr: "10.10.20.0/24"
      dhcp_start: "10.10.20.100"
      dhcp_end:   "10.10.20.200"
  dns:
    upstream: ["1.1.1.1", "9.9.9.9"]
    domain: "lab.local"
  firewall:
    default_policy: "block"
    allow_rules:
      - description: "LAN to internet"
        src_vlan: 20
        dst: "any"
        proto: "any"
        action: "allow"
  opnsense_vm:
    vmid: 100
    cores: 2
    memory_mb: 2048
    disk_gb: 20
    storage_pool: "local-lvm"
```

The schema is enforced by Pydantic — typos and out-of-range values fail with
a human-readable error before VNE touches any API.

## 4. Deploy

```bash
vne deploy \
  --config velocitee.yml \
  --manifest ~/vme/vme/manifests/output/<hostname>-<timestamp>.json
```

VNE walks through seven phases:

```
[1/7] Pre-flight: environment variables …
[2/7] Validating VME handoff manifest …
[3/7] Validating velocitee.yml VNE block …
[4/7] Building renderer pipeline for provisioner 'velocitee-native' …
[5/7] Running pipeline …
      proxmox: creating VM 100 on node pve
      proxmox: starting VM 100
      proxmox: waiting for guest agent IP …
      opnsense: creating VLAN 10 on lan
      opnsense: configuring DHCP subnet 10.10.10.0/24
      opnsense: configuring Unbound (domain=lab.local, …)
      opnsense: applying firewall …
[6/7] Verification …
  [PASS] api_reachable          https://10.10.10.1/api/core/system/status → 200
  [PASS] dns_resolving          resolved one.one.one.one via 10.10.10.1
  [PASS] internet_egress        TCP 1.1.1.1:443 reached in 12 ms
  [PASS] vlans_up               all 2 expected VLAN(s) present: [10, 20]
[7/7] Writing VNE output manifest …
      wrote vne/output/proxmox-01-20260427T103500Z.json

VNE complete. Hand off to VSE with:
  vse deploy --manifest vne/output/proxmox-01-20260427T103500Z.json
```

## If something goes wrong

VNE never writes its manifest unless every verification check passes — so
you cannot accidentally hand a half-broken state to VSE. The system stays
where it is; no auto-rollback.

- Read the error VNE printed.
- Fix the underlying cause (credentials, reachability, OPNsense quirk).
- Re-run. State at `vne/state/vne.state.json` resumes from the last
  successful step. Idempotent live probes reconcile if a resource went
  missing between runs.

## Creating a Proxmox API token

In the Proxmox web UI:

1. **Datacenter → Permissions → API Tokens → Add.**
2. User: `root@pam` (or a dedicated `vne@pve` user — recommended for
   production).
3. Token ID: `vne`.
4. Privilege Separation: **off** (so the token inherits user permissions).
5. Save the secret value Proxmox shows you — it is *not* recoverable later.

Then:

```bash
export PROXMOX_VE_API_TOKEN="root@pam!vne=<the-secret-uuid>"
```

For least-privilege production setups, see the
[configuration reference](configuration.md#proxmox-api-token-permissions).

## What's next

- Try the [`opentofu+ansible` backend](provisioners.md#opentofuansible) if
  you prefer a Terraform-managed infra layer.
- Read the full [configuration reference](configuration.md) — VLAN tagging,
  firewall rule semantics, OPNsense version targeting, the `velocitee-native`
  state file format.
