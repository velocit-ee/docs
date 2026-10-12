# Velocitee Vector Gateway — OpenWrt Router Deployment Guide
**Release:** v1.0.0 "Alder"  
**Target Hardware:** GL.iNet (Flint 2, Slate AX) / Telia X2 / Any OpenWrt CPE Gateway  
**Footprint:** ~3.5 MB Flash · ~26 MB RAM · 0 External Dependencies

---

## 1. Overview

**Vector Gateway** is the carrier-grade embedded edition of the Velocitee Vector platform. It runs **natively inside OpenWrt / CPE gateways** to orchestrate zero-touch hardware provisioning:

* **Port 8088:** Clean REST API (`/api/v1/telemetry`, `/api/v1/claim`, `/api/v1/audit`).
* **The 4-Engine Pipeline:** Coordinates VME (Metal), VNE (Network), VSE (Services), and VLE (Lifecycle).
* **Native OpenWrt Service:** Managed via standard `/etc/init.d/vector-gateway` with procd automatic respawn.
* **OpenWrt Package (.ipk):** Standardized opkg distribution for single-command installation.

---

## 2. 1-Click Install from Your Workstation

Make sure your machine is connected to the router (via Wi-Fi or Ethernet):

```bash
# From the vector-gateway repository:
./scripts/install_ipk.sh 192.168.8.1 root telia
```

*What this does automatically:*
1. Compiles the `.ipk` package with modular engines and Telia tuning profile.
2. Copies the package to the router `/tmp` over SCP.
3. Installs runtime dependencies (`python3-light`, `python3-urllib`, `python3-codecs`).
4. Installs `/opt/vector-gateway` and registers `/etc/init.d/vector-gateway`.
5. Integrates with dnsmasq and restarts the service.
6. Verifies health endpoint on `http://192.168.8.1:8088/api/v1/health`.

---

## 3. Service Management on the Router (SSH)

```bash
# Check service status
ssh root@192.168.8.1 '/etc/init.d/vector-gateway status'

# Restart service
ssh root@192.168.8.1 '/etc/init.d/vector-gateway restart'

# View live daemon log
ssh root@192.168.8.1 'logread -e vector-gateway'
```
