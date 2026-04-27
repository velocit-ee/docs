# VNE configuration reference

The VNE block in `velocitee.yml` is parsed by Pydantic models in
`vne/config.py`. Schema violations fail with a human-readable error at
parse time, before VNE talks to any API.

## Top-level

```yaml
velocitee:
  provisioner: "velocitee-native"   # required
vne:
  …
```

`velocitee.provisioner` must be a name registered in the renderer registry —
see [provisioner backends](provisioners.md).

## `vne` block

| Field                  | Type    | Required | Notes |
|------------------------|---------|----------|-------|
| `wan_interface`        | string  | yes      | Interface name *inside* the OPNsense VM (e.g. `ens18`). |
| `lan_interface`        | string  | yes      | Same — `ens19` for the second vNIC. |
| `opnsense_version`     | string  | no       | Defaults to `24.7`. Templates have been validated for the 24.x series. |
| `opnsense_iso_url`     | string  | yes      | HTTPS URL the renderer downloads via Proxmox `download-url`. |
| `opnsense_iso_checksum`| string  | yes      | `sha256:<hex>` or `sha512:<hex>`. Verified by Proxmox at download time. |
| `vlans`                | list    | no       | See [VLANs](#vlans). |
| `dns`                  | object  | yes      | See [DNS](#dns). |
| `firewall`             | object  | no       | See [Firewall](#firewall). Defaults to `default_policy: block` with no rules. |
| `opnsense_vm`          | object  | yes      | See [OPNsense VM](#opnsense-vm). |

## VLANs

```yaml
vne:
  vlans:
    - id: 10
      name: "servers"
      cidr: "10.10.10.0/24"
      dhcp_start: "10.10.10.100"   # optional — omit to disable DHCP for this VLAN
      dhcp_end:   "10.10.10.200"
      dhcp_lease_time: 86400        # optional, seconds; default 86400 (1 day)
```

Constraints VNE enforces:

- `id` is `1`–`4094`.
- `name` is unique across the list.
- `cidr` is a valid IPv4 subnet.
- `dhcp_start` and `dhcp_end` are both inside `cidr` and `start <= end`.
- Both DHCP fields together — you can't set just one.

The gateway address is **convention**: VNE uses the first usable host of
each VLAN's CIDR (so `10.10.10.0/24` → `10.10.10.1`).

## DNS

```yaml
vne:
  dns:
    upstream: ["1.1.1.1", "9.9.9.9"]
    domain: "lab.local"
```

Unbound is configured to forward all queries to `upstream`. Local clients
get DNS from OPNsense itself; OPNsense queries upstream resolvers.

## Firewall

```yaml
vne:
  firewall:
    default_policy: "block"     # or "allow"
    allow_rules:
      - description: "LAN to internet"
        src_vlan: 20            # or "any"
        dst_vlan: "any"         # or a VLAN ID
        dst: "any"              # or a CIDR / address
        proto: "any"            # any | tcp | udp | icmp
        port: 443               # optional
        action: "allow"         # allow | block | reject
```

Stable rule descriptions matter — the renderer matches on description when
deciding whether to update or create. Two rules with the same description
collide.

The default-block rule is added *last* so it doesn't strand the renderer
mid-deployment.

## OPNsense VM

```yaml
vne:
  opnsense_vm:
    vmid: 100              # required, >= 100, unique on the Proxmox cluster
    cores: 2
    memory_mb: 2048
    disk_gb: 20
    storage_pool: "local-lvm"
```

The VM is created with `bios=ovmf`, `machine=q35`, `cpu=host`, virtio
networking, qemu-guest-agent enabled. Defaults are tuned for OPNsense 24.x
on a small homelab cluster — bump `cores` / `memory_mb` for production.

## Environment variables (not in `velocitee.yml`)

Credentials never go in YAML files. VNE pre-flight reports all missing
variables in one error.

| Backend            | Required env vars |
|--------------------|--------------------|
| `velocitee-native` | `PROXMOX_VE_ENDPOINT`, `PROXMOX_VE_API_TOKEN`, `OPNSENSE_ROOT_PASSWORD` |
| `opentofu`         | `PROXMOX_VE_ENDPOINT`, `PROXMOX_VE_API_TOKEN` |
| `ansible`          | `OPNSENSE_API_KEY`, `OPNSENSE_API_SECRET` |
| `opentofu+ansible` | All of the above |

Optional toggles:

- `PROXMOX_VE_INSECURE=1` — skip TLS verification on Proxmox (self-signed certs).
- `OPNSENSE_INSECURE=1` — skip TLS verification on OPNsense (self-signed certs).
- `PROXMOX_VE_NODE=<name>` — pin a specific node when the cluster has more
  than one. Defaults to "first node returned by API."

## Proxmox API token permissions

For least-privilege, create a dedicated `vne@pve` user with these roles:

- `Datastore.AllocateSpace` (on the storage pool used)
- `Datastore.Audit`
- `VM.Allocate`, `VM.Audit`, `VM.Config.*`, `VM.PowerMgmt`, `VM.Console`,
  `VM.Migrate` (recommended for cluster setups)
- `Sys.Audit`, `Sys.Modify` (for bridge/network reload)

Issue a token for that user with **Privilege Separation off** (so the token
inherits user roles).

## State file format

`vne/state/vne.state.json`:

```json
{
  "schema_version": "1",
  "started_at": "2026-04-27T10:30:00+00:00",
  "steps": {
    "ensure_bridges": { "status": "completed", "data": { "bridges": ["vmbr0", "vmbr1"] } },
    "iso_present":    { "status": "completed", "data": { "volid": "local:iso/opnsense.iso" } },
    "create_vm":      { "status": "completed", "data": { "vmid": 100 } }
  },
  "shared": {
    "proxmox_node": "pve",
    "opnsense_ip": "10.10.10.1",
    "opnsense_api_key": "…",
    "opnsense_api_secret_plain": "…"
  }
}
```

Don't edit by hand. Delete and re-run if it goes wrong — every step is
idempotent and live-probed, so re-creation is safe.
