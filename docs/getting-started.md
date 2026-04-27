# Getting started

A first end-to-end run takes about 30 minutes — most of which is waiting for
hardware to boot. The flow is the same every time:

1. **VME** PXE-boots the hardware and installs Proxmox VE or Ubuntu Server.
2. **VNE** creates an OPNsense VM and configures the network on top.
3. (Future) VSE deploys services. VLE keeps everything in shape.

You can stop at any phase — every engine writes a manifest and is independently
useful.

## Prerequisites

- A laptop or Pi as the **seed machine** (Ubuntu 22.04+ / Debian 12+, Docker).
- One x86_64 target machine with a PXE-capable NIC.
- The seed machine and target on the same provisioning switch.

## 1. Install VME

```bash
curl -fsSL https://raw.githubusercontent.com/velocit-ee/core/main/vme/install.sh | bash
cd ~/vme/vme
```

## 2. Configure VME

```bash
vme setup       # guided wizard — detects interfaces, writes vme-config.yml
vme preflight   # verify the seed machine is ready
```

## 3. Provision the target

```bash
vme deploy
# Power on the target. Walk away.
```

VME PXE-boots the target, runs an unattended install, and writes a handoff
manifest at `~/vme/vme/manifests/output/`. See the
[VME getting-started](vme/getting-started.md) for the full walkthrough.

## 4. Install VNE

```bash
curl -fsSL https://raw.githubusercontent.com/velocit-ee/core/main/vne/install.sh | bash
```

## 5. Configure the network

Set the credentials VNE needs (never put these in `velocitee.yml`):

```bash
export PROXMOX_VE_ENDPOINT="https://proxmox.lab:8006"
export PROXMOX_VE_API_TOKEN="root@pam!vne=…"
export OPNSENSE_ROOT_PASSWORD="…"
```

Write a `velocitee.yml` describing your network — see the
[VNE getting-started](vne/getting-started.md) for a worked example.

## 6. Deploy

```bash
vne deploy --manifest ~/vme/vme/manifests/output/<latest>.json
```

VNE creates the OPNsense VM, configures VLANs, DHCP, DNS, and firewall, then
runs four verification checks. On success, it writes a manifest the next
engine will read.

## What's next

- [VME getting started](vme/getting-started.md) — full walkthrough with images
  and troubleshooting.
- [VNE getting started](vne/getting-started.md) — full configuration tour.
- [Architecture overview](architecture/pipeline.md) — how the engines fit
  together.
