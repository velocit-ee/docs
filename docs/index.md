---
title: Velocitee docs
hide:
  - toc
---

# Velocitee documentation

**Velocitee Vector** takes hardware from bare metal to a documented, running
infrastructure stack — engine by engine — without you writing playbooks, HCL, or
provisioner syntax by hand.

!!! warning "Velocitee Vector is 0.1.0, and both implemented engines are alpha"

    Two of the four engines exist. They run, and they have been used against
    real hardware, but their primary execution paths are not yet covered by
    automated tests and their interfaces can still change in a minor release.
    VSE and VLE have no implementation at all.

    Run this against equipment you can afford to reinstall. The full breakdown
    of what is and is not covered by tests is in the
    [core README](https://github.com/velocit-ee/core#project-status--read-this-first).

```text
bare metal ──► VME ──► VNE ──► VSE ──► VLE ──► documented, running stack
              provision  network  services   lifecycle
```

---

## Start here

<div class="grid cards" markdown>

-   :material-rocket-launch:{ .lg .middle } **What is Velocitee?**

    ---

    Two-minute overview. The pipeline, what each engine does, how they hand
    off to each other, what "open-core" means here.

    [:octicons-arrow-right-24: Read the overview](what-is-velocitee.md)

-   :material-server:{ .lg .middle } **VME — metal**

    ---

    Phase 1. PXE-boot any x86_64 hardware. Unattended Proxmox VE or Ubuntu
    Server install from a single seed machine.

    [:octicons-arrow-right-24: VME getting started](vme/getting-started.md)

-   :material-network:{ .lg .middle } **VNE — network**

    ---

    Phase 2. OPNsense VM, VLANs, DHCP, DNS, firewall — declarative and
    idempotent, with two working provisioner backends.

    [:octicons-arrow-right-24: VNE getting started](vne/getting-started.md)

-   :material-book-open-variant:{ .lg .middle } **Reference**

    ---

    The full `velocitee.yml` schema, every required environment variable, the
    handoff manifest format.

    [:octicons-arrow-right-24: Reference](reference/velocitee-yml.md)

</div>

---

## Project status

<!-- ENGINE-STATUS:BEGIN region=engine-table -->
| Engine  | Phase | Status  | Description |
|---------|:-----:|---------|-------------|
| **VME** | 1     | Alpha   | Bare-metal provisioning — PXE boot + unattended OS install (Proxmox VE, Ubuntu Server). Two backends: `builtin` seed stack or `maas` (optional). |
| **VNE** | 2     | Alpha   | Network configuration — OPNsense VM, VLANs, DHCP, DNS, firewall. Two working backends via the renderer registry. Discovery + Path B (`vne join`) for existing networks. |
| VSE     | 3     | Planned | Services — containerised stack deployment, idempotent configuration |
| VLE     | 4     | Planned | Lifecycle — monitoring, drift detection, auto-docs, single-command repair |
<!-- ENGINE-STATUS:END region=engine-table -->

---

## Project values

1.  **Correctness and reliability above all.**
2.  **Lightweight** — reject complexity that doesn't serve the user.
3.  **Provisioner-agnostic** — the user picks the provisioner; the engine
    doesn't care which one runs.
4.  **Idempotency** — every operation safe to re-run.
