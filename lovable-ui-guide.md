# Lovable UI Prompt & Integration Guide: Telia Private Edge

Use this guide and prompt in **Lovable** to generate a modern, pixel-perfect frontend for the **Telia Private Edge Gateway (Powered by Velocitee)**.

---

## 1. Lovable Prompt (Copy & Paste into Lovable)

```text
Create a modern, high-end enterprise B2B dashboard for "Telia Private Edge" — a managed zero-touch on-premises server provisioning platform for Nordic and Baltic SMEs, co-branded with "Powered by Velocitee" (velocit.ee).

Brand Aesthetics:
- Color Palette: Telia Purple (#990AE3), Deep Void Dark (#0D031A), Elevated Dark Cards (#150629, #1C0838), Border Purple (#2A0E4E), Success Green (#00E676), Warning Orange (#FF9100), Electric Blue (#00B0FF).
- Typography: Clean modern sans-serif (Plus Jakarta Sans or Inter), paired with JetBrains Mono for IPs, MAC addresses, and telemetry.
- Vibe: Nordic Telco Enterprise meets Vercel / Linear precision. High trust, sovereign, robust.

Layout Structure:
1. Top Navigation Bar:
   - Left: "TELIA" bold purple badge + "Private Edge Gateway" title + "Äriklient / Business" pill.
   - Right: "⚡ Powered by Velocitee" badge linking to https://velocit.ee + "VME Manifest" button opening a code viewer modal.

2. Main Content (2-Column Grid):
   - Left Column (Sidebar, 360px):
     * Card 1: CPE Router Telemetry (Model: Technicolor DGA4330 / Telia X2, RAM: 38 MB / 512 MB, Uplink: 1000/1000 Ärikiud, Static Subnet: 194.126.101.40/29).
     * Card 2: Port Allocation (LAN 1: Office VLAN 10, LAN 2: VoIP VLAN 20, LAN 4: Dedicated Server Port - VLAN 999 Quarantine).
     * Card 3: Compliance & Security Badges (Estonian Data Boundary: EE-Tallinn, EU NIS2 Directive Verified, GDPR Art. 32 LUKS2 Encrypted, Telia Tier-3 DC Backup).

   - Right Column (Main View):
     * Hero Action Card:
       - Status badge showing "● QUARANTINED IN VLAN 999" (orange glow) when unclaimed, and "● OPERATIONAL & SOVEREIGN" (green glow) when provisioned.
       - Title: "New Sovereign Server Detected on Port 4"
       - Subtitle: "Hardware MAC 52:54:00:12:34:56 · Isolated from office LAN until authenticated."
       - Profile Selector dropdown: "Sovereign Legal Advisory (16GB RAM, 512GB Encrypted NVMe)" or "Standard Proxmox VE Node".
       - Large CTA Button: "🛡️ Authenticate & Zero-Touch Deploy" (calls POST /api/v1/nodes/52:54:00:12:34:56/claim).
       - Animated progress bar showing live stage descriptions ("Claim token verified" -> "Streaming kernel" -> "Partitioning LUKS2" -> "Deploying Nextcloud" -> "Active").
       - Success Banner (revealed when 100%): "✅ Sovereign Server Successfully Provisioned!" with a button linking to http://localhost:8081 ("Open Sovereign Legal Workspace").
     
     * Bottom Card:
       - "Security & Audit Trail (RFC 5424 / Tamper-Evident)" dark console box displaying live audit events streamed from GET /api/v1/audit-log.

API Integration:
- The app should connect to the local Telia Edge Daemon running at http://localhost:8088 (CORS is enabled).
- Endpoints:
  * GET http://localhost:8088/api/v1/telemetry
  * GET http://localhost:8088/api/v1/nodes
  * POST http://localhost:8088/api/v1/nodes/{mac}/claim
  * GET http://localhost:8088/api/v1/audit-log
  * GET http://localhost:8088/api/v1/manifest
```

---

## 2. API Contract Reference

| Endpoint | Method | Purpose |
| :--- | :--- | :--- |
| `/api/v1/telemetry` | `GET` | Hardware specs for Technicolor DGA4330 (Telia X2), RAM/flash, fiber speed. |
| `/api/v1/nodes` | `GET` | Discovered hardware in Quarantine VLAN 999, claim state, deployment progress. |
| `/api/v1/nodes/{mac}/claim` | `POST` | Authenticates hardware, generates HMAC claim token, triggers deployment. |
| `/api/v1/audit-log` | `GET` | Tamper-evident audit trail for GDPR Art. 32 and NIS2 compliance. |
| `/api/v1/manifest` | `GET` | Canonical Velocitee Handoff Manifest (JSON format). |

---

## 3. How to Connect Lovable Output to the Running Agent

1. Build or export your Lovable project (it runs a Vite dev server on `http://localhost:5173`).
2. Keep `./core/vme/scripts/demo.sh` running in your terminal (which runs the backend on port 8088 and the target server on port 8081).
3. The Lovable UI will automatically fetch from `http://localhost:8088/api/v1/*` and control the live demo!
