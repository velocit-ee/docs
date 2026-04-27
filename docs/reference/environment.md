# Environment variables

Credentials never go in `velocitee.yml` or any committed file. Each engine's
pre-flight checks every required variable and reports all misses in one
error before doing anything else.

## VME

VME currently reads its config exclusively from `vme-config.yml`. No
environment variables required.

## VNE — by backend

| Variable                  | Required by                              | Why |
|---------------------------|------------------------------------------|-----|
| `PROXMOX_VE_ENDPOINT`     | `velocitee-native`, `opentofu+ansible`   | e.g. `https://proxmox.lab:8006`. |
| `PROXMOX_VE_API_TOKEN`    | `velocitee-native`, `opentofu+ansible`   | Form: `user@realm!tokenid=secret`. |
| `OPNSENSE_ROOT_PASSWORD`  | `velocitee-native`                       | Used once at first boot via `config.xml`. |
| `OPNSENSE_API_KEY`        | `opentofu+ansible`                       | Used by Ansible. |
| `OPNSENSE_API_SECRET`     | `opentofu+ansible`                       | Used by Ansible. |

Optional toggles:

| Variable                | Default | Effect |
|-------------------------|---------|--------|
| `PROXMOX_VE_INSECURE`   | unset   | `1` skips TLS verification for Proxmox. |
| `OPNSENSE_INSECURE`     | unset   | `1` skips TLS verification for OPNsense. |
| `PROXMOX_VE_NODE`       | first node returned by API | Pin the Proxmox node when the cluster has more than one. |

## Storing credentials

Two patterns work well:

**1. Direnv** — project-local, auto-loaded:

```bash
# .envrc (gitignored!)
export PROXMOX_VE_ENDPOINT="https://proxmox.lab:8006"
export PROXMOX_VE_API_TOKEN="root@pam!vne=…"
export OPNSENSE_ROOT_PASSWORD="…"
```

```bash
direnv allow
```

**2. systemd unit `EnvironmentFile`** — for production, no shell required:

```ini
# /etc/velocitee/vne.env (mode 0600, root-only)
PROXMOX_VE_ENDPOINT=https://proxmox.lab:8006
PROXMOX_VE_API_TOKEN=root@pam!vne=…
OPNSENSE_ROOT_PASSWORD=…
```

Reference it from the systemd unit running VNE.

Avoid putting credentials in your shell history or anywhere that ends up in
git. The pre-flight check exists to catch missing values early — don't
work around it by hardcoding.
