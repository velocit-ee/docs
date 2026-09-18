# Velocitee Vector

**Velocitee Vector** is an appliance-grade bare-metal server deployment engine designed for zero-touch edge operations.

## Overview

Vector turns unconfigured bare-metal hardware into production-ready, sovereign private cloud servers with zero manual sysadmin intervention.

Unlike hyperscaler public clouds that centralize data and incur unpredictable egress fees, Vector allows organizations to own and operate their physical infrastructure while retaining modern automated provisioning workflows.

### Core Capabilities

- **Zero-Touch PXE Discovery:** Machines plugged into an edge network are automatically placed into an isolated quarantine VLAN until cryptographically authenticated.
- **Cryptographic Claim Workflow:** Administrators claim and approve hardware using short-lived HMAC-SHA256 tokens before boot chains are released.
- **Automated Data Protection:** Every provisioned node enforces LUKS2 full-disk encryption with TPM 2.0 key attestation on first boot (GDPR Article 32 and NIS2 compliant).
- **Lightweight Carrier Footprint:** Micro-agent architecture requiring under 40 MB of RAM, allowing Vector to run directly on standard broadband customer-premises equipment (CPE).

### Editions

1. **Vector Standalone:** For direct on-premises enterprise clusters and private data centers.
2. **Telia Vector (Carrier Edition):** Co-branded edge appliance tailored for Telia's business router fleet (e.g., Telia X2 / Technicolor DGA4330).
