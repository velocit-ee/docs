# Provisioner backends

VNE selects a backend at runtime based on `velocitee.provisioner` in
`velocitee.yml`. Each backend is a *renderer* — a small adapter between the
provisioner-agnostic `VNEIntent` and a specific provisioner's API or DSL.

| Backend            | Status        | Phase | What it uses |
|--------------------|---------------|-------|--------------|
| `velocitee-native` | **Primary**   | both  | Proxmox REST + OPNsense REST, direct from Python |
| `opentofu+ansible` | Implemented   | infra → config | OpenTofu (`bpg/proxmox`) for VM creation, Ansible (`ansibleguy.opnsense`) for network config |
| `ansible-only`     | Stub          | —     | Reserved name |
| `pulumi`           | Stub          | —     | Reserved name |
| `salt`, `chef`, `puppet`, `cloudformation`, `bicep`, `nix`, `cloud-init`, `helm`, `packer` | Stubs | — | Reserved names |

Stubs accept config-time validation but raise a clear `NotImplementedError`
on execute. They exist so the registry doesn't break when an as-yet-unbuilt
backend is selected.

## velocitee-native

First-class Python provisioner. No external CLI tools — talks Proxmox and
OPNsense REST directly.

### What it does, step by step

1. Probes Proxmox for the target node, ensures `vmbr0` and `vmbr1` are
   VLAN-aware bridges (creates them if missing).
2. Downloads the OPNsense ISO into Proxmox storage (`download-url` API),
   verifying the SHA-256 checksum.
3. Renders an OPNsense `config.xml` (root password hashed, API key
   provisioned, WAN/LAN assigned), wraps it in a tiny ISO9660, uploads it.
4. Creates the VM on Proxmox, attaches both ISOs (OS as `ide2`, config as
   `ide3`).
5. Starts the VM, waits for the qemu-guest-agent to report a LAN IP.
6. Reaches OPNsense's REST API with the API key it provisioned in step 3,
   waits for it to be ready.
7. Creates VLANs, DHCP scopes, Unbound forwarders, and firewall rules — each
   one idempotent and live-probed.

### Required env vars

| Variable                | Why |
|-------------------------|-----|
| `PROXMOX_VE_ENDPOINT`   | e.g. `https://proxmox.lab:8006` |
| `PROXMOX_VE_API_TOKEN`  | `user@realm!tokenid=secret` |
| `OPNSENSE_ROOT_PASSWORD`| Used once at first boot via `config.xml` |

Optional: `PROXMOX_VE_INSECURE=1`, `OPNSENSE_INSECURE=1` for self-signed
certs.

### State

`vne/state/vne.state.json` — versioned, atomic, resumable. Every step's
outcome is recorded. Resume reads the file *and* probes the live API: if
state says "VM created" but the VM is gone, VNE reconciles by re-creating.

## opentofu+ansible

Two renderers run in sequence by the pipeline:

```
Phase 1 (infra):  OpenTofu       → writes infra_manifest.json
Phase 2 (config): Ansible        → reads infra_manifest.json, runs playbooks
```

**Phase 2 never starts if Phase 1 fails.** The pipeline orchestrator enforces
this; the renderers do not need to.

### What gets pinned where

- Terraform / OpenTofu version: `>= 1.6.0, < 2.0.0`
- Provider `bpg/proxmox`: pinned at **0.66.2**
- Ansible: `>= 2.15`
- Collection `ansibleguy.opnsense`: pinned at **1.30.1**

Versions are pinned in code (`shared/renderers/opentofu.py` and
`shared/renderers/ansible.py`). Bumping them is a code change, never a config
change.

### Required env vars

| Variable                | Used by  |
|-------------------------|----------|
| `PROXMOX_VE_ENDPOINT`   | OpenTofu |
| `PROXMOX_VE_API_TOKEN`  | OpenTofu |
| `OPNSENSE_API_KEY`      | Ansible  |
| `OPNSENSE_API_SECRET`   | Ansible  |

### Working directories

- HCL: generated to `vne/work/terraform/` every run (not committed).
- Inventory + group_vars: generated to `vne/work/ansible/` every run.
- Terraform state: `vne/work/terraform/terraform.tfstate` (local backend, gitignored).
- Ansible roles: shipped statically at `vne/ansible/roles/`. The renderer
  copies them to the working directory and never edits them at runtime.

## Adding a new backend

You write a `Renderer` subclass and register it. That's the whole API.

```python
# shared/renderers/my_backend.py
from typing import Any
from ..renderer import Renderer
from ..renderer_registry import register
from ..schema import ProvisioningResult

class MyRenderer(Renderer):
    name = "my-backend"
    phase = "both"   # or "infra" / "config"

    def validate(self) -> list[str]:
        # Return a list of human-readable errors. Empty = OK.
        return []

    def execute(self, *, prior_outputs: dict[str, Any] | None = None) -> ProvisioningResult:
        # Be idempotent. Probe live state before acting.
        return ProvisioningResult(
            success=True, renderer=self.name, phase=self.phase, outputs={},
        )

register("my-backend", MyRenderer)
```

The user opts in by setting `velocitee.provisioner: "my-backend"`. Nothing
in the engine changes.
