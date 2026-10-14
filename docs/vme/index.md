# VME — metal provisioning engine

<!-- ENGINE-STATUS:BEGIN region=engine-pill-vme -->
**Phase 1 · Alpha**
<!-- ENGINE-STATUS:END region=engine-pill-vme -->

Bare-metal provisioning. PXE boot any x86_64 hardware, install Proxmox VE
or Ubuntu Server fully unattended, write a handoff manifest, tear down
the seed stack.

VME is the foundation everything else builds on. It is also independently
useful — many users only ever need VME.

## Pages

- [Getting started](getting-started.md) — full walkthrough.
- [Compatibility](compatibility.md) — supported hardware and OS combinations.

## Architecture in one diagram

```mermaid
sequenceDiagram
    autonumber
    actor Tech as Operator
    participant Seed as Seed Machine / Gateway
    participant Target as Target Machine

    Tech->>Seed: vme deploy (start dnsmasq + nginx + iPXE stack)
    Tech->>Target: Power On (Bare Metal)
    Target->>Seed: 1. DHCP Discover / PXE Request
    Seed-->>Target: 2. DHCP Lease + iPXE Chainload URL
    Target->>Seed: 3. HTTP GET /boot.ipxe & netboot ISO
    Seed-->>Target: 4. Kernel, initrd & Subiquity autoinstall
    Note over Target: 5. Unattended OS Install & LUKS2 Encryption
    Target->>Seed: 6. Provisioning Complete (Shutdown / Reboot)
    Note over Seed: 7. Writes validated handoff manifest.json
```

The seed stack is fully containerised (Docker Compose). Re-running VME
against an already-provisioned machine is safe — VME is stateless.

## Source

- Repository: [velocit-ee/core](https://github.com/velocit-ee/core), `vme/`
- License: Apache 2.0
