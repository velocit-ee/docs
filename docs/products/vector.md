# Velocitee Vector

**Velocitee Vector** is an appliance-grade bare-metal server deployment engine designed for zero-touch edge operations.

## Overview

Vector turns unconfigured bare-metal hardware into production-ready, sovereign private cloud servers with zero manual sysadmin intervention.

Unlike hyperscaler public clouds that centralize data and incur unpredictable egress fees, Vector allows organizations to own and operate their physical infrastructure while retaining modern automated provisioning workflows.

### Core Capabilities

- **Zero-Touch Discovery:** Machines plugged into an edge network are automatically placed into an isolated quarantine VLAN until cryptographically authenticated.
- **Cryptographic Claim Workflow:** Administrators claim and approve hardware using short-lived HMAC-SHA256 tokens before boot chains are released.
- **The 4-Engine Pipeline:** Orchestrates VME (Metal), VNE (Network), VSE (Services), and VLE (Lifecycle).
- **Automated Data Protection:** Every provisioned node enforces LUKS2 full-disk encryption with TPM 2.0 key attestation on first boot (GDPR Article 32 and NIS2 compliant).
- **Micro-Footprint (< 30 MB RAM):** Micro-agent architecture requiring under 30 MB of RAM, allowing Vector to run natively on broadband customer-premises equipment (CPE).

### Editions

1. **Vector Core:** The open-source standalone engine CLI for on-premises clusters, private data centers, and field kits.
2. **Vector Gateway (Carrier Edition):** Co-branded edge firmware appliance tailored for carrier router fleets (e.g., Telia X2 / Technicolor DGA4330 / GL.iNet).
3. **Velocitee Prism:** The Sovereign AI Clean Room payload deployed onto provisioned nodes via the Vector Services Engine (VSE).
