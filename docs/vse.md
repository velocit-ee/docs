# VSE — services engine

<!-- ENGINE-STATUS:BEGIN region=engine-pill-vse -->
**Phase 3 · Planned**
<!-- ENGINE-STATUS:END region=engine-pill-vse -->

VSE will deploy a containerised service stack on top of the network VNE
configures. Out-of-box targets: PostgreSQL, MariaDB, NGINX, Caddy, Vaultwarden,
Nextcloud, Mealie, monitoring (Prometheus/Grafana). Idempotent like the
engines before it; reads the VNE handoff manifest for context.

The `velocitee.yml` block for VSE is not yet defined.

This page will fill out as VSE moves from planned → stable.
