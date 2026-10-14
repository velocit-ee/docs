# Velocitee Vector — 90-Second Demo Cheat Sheet

**What It Is:** A lightweight edge orchestration system running on a carrier router that automatically provisions bare-metal servers plugged into the local network—zero manual setup, zero USB drives, zero truck rolls.

---

## The 4-Step Demo Flow

```
┌───────────────────┐       ┌───────────────────┐       ┌───────────────────┐       ┌───────────────────┐
│      STEP 1       │  ──▶  │      STEP 2       │  ──▶  │      STEP 3       │  ──▶  │      STEP 4       │
│  15-Sec Overview  │       │  Native Mac Load  │       │  Open Router UI   │       │   Deploy & SSH    │
│  "What is this?"  │       │ Activity Monitor  │       │   192.168.100.1   │       │  192.168.100.50   │
└───────────────────┘       └───────────────────┘       └───────────────────┘       └───────────────────┘
```

---

### Step 1: Quick Explanation (15 Seconds)
> *"Every branch office and facility already has an edge router. Right now, when companies want to install an on-prem server, they have to send a technician on-site with a USB drive.  
> With **Velocitee Vector**, you just plug any bare-metal server into the router. The router detects it on the network, isolates it, installs the OS over the network, and brings it live automatically."*

---

### Step 2: Show Native Resource Allocation on Mac (15 Seconds)
**Action:** Show macOS **Activity Monitor** (or run `ps` in terminal):
```bash
ps -eo pid,rss,%cpu,command | grep -E "agent|sovereign|ssh" | grep -v grep
```
**Talking Point:**
> *"Look at the router orchestrator daemon running on my Mac: it uses just **27 MB of RAM** and idles at **0.0% CPU**. That's the secret. The provisioner on the router is featherweight so it can run directly inside Telia's low-power broadband box, while the machine plugged into Port 4 is a full, powerful enterprise microserver (16 GB ECC RAM, Xeon/Ampere, 512 GB encrypted NVMe)."*

---

### Step 3: Open Router in Browser (20 Seconds)
**Action:** Open **`http://localhost:3000`** (or direct router status at **`http://192.168.100.1`**).
**Talking Point:**
> *"Here is the router gateway at `192.168.100.1`. You can see its network ports: Port 1 is the office network, Port 2 is VoIP, and on Port 4, it detected an unconfigured device.  
> Right now, **no server exists on the active network**. If you try to open `http://192.168.100.50` or SSH into it, access is completely blocked with a 403 quarantine banner. It is held on isolated VLAN 999 and cannot touch the company network or internet until we approve it."*

---

### Step 4: Deploy & Show Live Server via Browser and SSH (30 Seconds)
**Action 1 (Click Deploy):**
- Click **"Authorize & Deploy Appliance"** in the console.
- Point out the status changing: *Verifying hardware ➔ Streaming OS ➔ Sealing drive ➔ Moving to active network.*

**Action 2 (Show Server in Browser):**
- Click the server link or open **`http://192.168.100.50`**.
> *"The server is now live at its own dedicated IP: `192.168.100.50`. It's running Ubuntu 24.04 with Docker and services active."*

**Action 3 (Show Live SSH in Terminal):**
- In Terminal, run:
  ```bash
  ssh ubuntu@192.168.100.50
  ```
- Run a quick command:
  ```bash
  uname -a
  docker ps
  ```
> *"We have direct SSH into the server at `192.168.100.50`. Full Ubuntu 24.04 LTS shell, Docker containers running, disk encrypted, completely managed."*

---

### Step 5: The End Pitch (10 Seconds)
> *"That's Velocitee Vector: From an unboxed server plugged into a router to a secure, encrypted, production server on the network in seconds. Zero truck rolls, zero manual configuration, ultra-light footprint. Thank you."*

---

## 🔍 Prototype vs. Production (How to answer judges cleanly)

If a judge asks: *"What is real here and what is simulated?"*

| Stage | What we built in this Prototype (Today) | What the Real Product does (Production) |
|---|---|---|
| **Hardware** | Simulated locally via macOS loopback (`192.168.100.1` & `.50`) to prove efficiency (<30MB RAM). | Physical Telia CPE router (e.g. DGA4330) connected via Cat6 to an on-premise microserver. |
| **Detection** | Daemon detects unprovisioned node state and simulates the quarantine switch port. | Router DHCP/eBPF intercepts the unprovisioned MAC address and forces it into isolated VLAN 999. |
| **Installation** | Orchestrator pipeline triggers real HMAC authorization and simulates OS stream stages. | Real iPXE / netboot over local LAN wire streaming signed rootfs image directly to server RAM/disk. |
| **Final State** | Real SSH terminal (`ssh ubuntu@192.168.100.50`), real Web UI, real API endpoints. | Real server with TPM 2.0 sealed LUKS2 disk, migrated to office LAN VLAN 10, running sovereign containers. |
| **User Flow** | **100% Identical:** The non-technical SME owner just sees the device appear and clicks **1 button**. | **100% Identical:** Owner opens their Telia portal, sees the box, clicks **1 button**. Done. |

> **The 1-liner:** *"Today's demo faithfully simulates the exact network protocols, API states, and user flow on standard Mac loopback to show how featherweight the architecture is, while the production version flashes directly onto the Telia router's Linux firmware to netboot real physical servers."*

---

## Demo Reset & Quick Commands

```bash
# 🔁 Reset to unprovisioned quarantine (takes 1 second):
curl -s -X POST http://localhost:3000/api/v1/reset

# 🚀 Open all demo windows (Console, Router, Server Hub, SSH):
./launch_demo.sh --monitor

# 🛑 Stop all background services:
./teardown_demo.sh
```
