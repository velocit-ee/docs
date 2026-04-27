# Handoff manifest

The handoff manifest is the only contract between engines. Each engine reads
the previous one's manifest and appends its own record. The schema is
versioned and lives at
[`shared/schema.json`](https://github.com/velocit-ee/core/blob/main/shared/schema.json).

## Shape

```json
{
  "schema_version": "1.0",
  "target": {
    "hostname": "proxmox-01",
    "ip":       "192.168.1.10",
    "prefix":   24,
    "gateway":  "192.168.1.1",
    "dns":      "1.1.1.1",
    "disk":     "/dev/sda",
    "os":       "proxmox-ve",
    "mac":      "aa:bb:cc:dd:ee:ff"
  },
  "access": {
    "username":       "root",
    "ssh_public_key": "ssh-ed25519 AAAA…",
    "ssh_port":       22
  },
  "engines": {
    "vme": {
      "status":           "success",
      "version":          "0.1.0",
      "started_at":       "2026-04-27T10:00:00Z",
      "completed_at":     "2026-04-27T10:30:00Z",
      "duration_seconds": 1800.0,
      "iso":              "proxmox-ve-8.4.iso"
    },
    "vne": {
      "status":           "success",
      "version":          "0.1.0",
      "started_at":       "2026-04-27T10:30:00Z",
      "completed_at":     "2026-04-27T10:35:00Z",
      "provisioner":      "velocitee-native",
      "opnsense":         { "vm_ip": "10.10.10.1", "vmid": 100, "api_endpoint": "https://10.10.10.1", "version": "24.7" },
      "vlans":            [ … ],
      "dns":              { "server": "10.10.10.1", "domain": "lab.local", "upstream": ["1.1.1.1", "9.9.9.9"] },
      "verification":     { "passed": true, "checks": { … } },
      "proxmox_host":     { "ip": "192.168.1.10", "hostname": "proxmox-01" }
    }
  }
}
```

## Rules

- `schema_version` is **required** and **constant** for any single major
  version. Changes here are breaking changes.
- `target` and `access` are written **once** by VME. Later engines do not
  modify them.
- `engines.<name>` is added by each engine as it completes. Required keys:
  `status`, `started_at`. Optional but conventional: `completed_at`,
  `duration_seconds`, `version`. Any number of engine-specific extra keys
  are allowed.
- The whole manifest validates on every write. A failed validation is fatal
  — better to refuse than write a corrupt handoff.

## Where it lives

| Engine | Default output path |
|--------|---------------------|
| VME    | `~/vme/vme/manifests/output/<hostname>-<timestamp>.json` |
| VNE    | `vne/output/<hostname>-<timestamp>.json` |

Filenames are timestamped, never overwritten — every run produces a new file.
The `--manifest` flag of every downstream engine takes the previous engine's
output path.

## VNE-specific fields

VNE refuses to write the manifest unless every verification check passed —
so `verification.passed` is always `true` in any manifest VNE actually
wrote. Failed runs do not produce a file; the operator must resolve and
re-run.

See the
[VNE output schema](https://github.com/velocit-ee/core/blob/main/vne/schema/vne-manifest.schema.json)
for the full per-engine record format.
