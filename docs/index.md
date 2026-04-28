---
title: velocit.ee docs
hide:
  - toc
---

# velocit.ee — documentation

**Open-core infrastructure deployment platform.** Take hardware from bare metal
to a fully documented, running infrastructure stack — engine by engine — without
ever touching raw playbooks, HCL, or provisioner syntax.

```text
bare metal ──► VME ──► VNE ──► VSE ──► VLE ──► documented, running stack
              provision  network  services   lifecycle
```

---

## Start here

<div class="grid cards" markdown>

-   :material-rocket-launch:{ .lg .middle } **What is velocitee?**

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

    Phase 2. OPNsense VM, VLANs, DHCP, DNS, firewall — declarative, idempotent,
    provisioner-agnostic.

    [:octicons-arrow-right-24: VNE getting started](vne/getting-started.md)

-   :material-book-open-variant:{ .lg .middle } **Reference**

    ---

    The full `velocitee.yml` schema, every required environment variable, the
    handoff manifest format.

    [:octicons-arrow-right-24: Reference](reference/velocitee-yml.md)

</div>

---

## Project status

| Engine | Phase | Status            | What it does |
|--------|-------|-------------------|--------------|
| VME    | 1     | Active            | Bare-metal provisioning. PXE + unattended OS install. |
| VNE    | 2     | Active (initial)  | Network configuration. OPNsense, VLANs, DHCP, DNS, firewall. |
| VSE    | 3     | Planned           | Services. Containerised stack deployment. |
| VLE    | 4     | Planned           | Lifecycle. Drift detection, auto-docs, single-command repair. |

---

## Project values

1.  **Correctness and reliability above all.**
2.  **Lightweight** — reject complexity that doesn't serve the user.
3.  **Provisioner-agnostic** — the user picks the provisioner; the engine
    doesn't care which one runs.
4.  **Idempotency** — every operation safe to re-run.
