# Velocitee Vector: Physical Lab Setup & Hardware Bill of Materials (BOM)
**Prepared for:** Telia Technical Architecture & Engineering Review  
**Objective:** Physical Proof-of-Concept (PoC) validating zero-touch bare-metal provisioning from a carrier edge CPE to a local microserver.

---

## 1. Physical Lab Architecture

```
                                  [ WAN Uplink / Telia Fiber ]
                                                │
                                                ▼
                                    ┌───────────────────────┐
                                    │   CARRIER EDGE CPE    │
                                    │  (OpenWrt / Linux)    │
                                    │   192.168.100.1/24    │
                                    │  Vector Gateway :8088 │
                                    └───────────┬───────────┘
                                                │
                     ┌──────────────────────────┴──────────────────────────┐
  Port 1 (Trusted)   │                                                     │   Port 4 (Quarantine)
  VLAN 10 Untagged   │                                                     │   VLAN 999 Isolated
                     ▼                                                     ▼
           ┌──────────────────┐                                  ┌───────────────────┐
           │ OPERATOR LAPTOP  │                                  │ TARGET MICROSERVER│
           │  192.168.100.10  │                                  │  192.168.100.50   │
           │  Web UI (:3000)  │                                  │ Blank NVMe + TPM2 │
           └──────────────────┘                                  └───────────────────┘
                                                                           │
                                                                           ▼
                                                                 ┌───────────────────┐
                                                                 │ 1. UEFI PXE/iPXE  │
                                                                 │ 2. Egress Blocked │
                                                                 │ 3. LUKS2 + TPM2   │
                                                                 │ 4. Promote VLAN 10│
                                                                 └───────────────────┘
```

---

## 2. Hardware Bill of Materials (BOM)

To demonstrate this convincingly to Telia's network architects, you need hardware that represents their production ecosystem without spending thousands of euros:

### A. The Carrier Edge Router (Gateway / Provisioner)
The goal is to prove the provisioner runs on low-power, constrained carrier hardware (<30MB RAM overhead).

| Option | Hardware Model | Specs | Est. Price | Why It's Great for Telia |
| :--- | :--- | :--- | :--- | :--- |
| **Recommended (Commercial)** | **GL.iNet GL-MT6000 (Flint 2)** | MediaTek MT7986 ARM64, 1GB DDR4, dual 2.5G + 4x 1G ports, native OpenWrt 23.05 | ~€130–€150 | Closest architecture to modern Telia X2 / Technicolor CPEs. Native LuCI / OpenWrt firmware with physical port isolation. |
| **Alternative (Modular)** | **NanoPi R6S or R5S** | Rockchip RK3588S / RK3568, 4GB RAM, dual 2.5G ports, metal enclosure | ~€85–€120 | Extremely compact, low power (<5W), robust Linux/OpenWrt support. |
| **Alternative (x86 Multi-NIC)** | **Topton / Protectli 4-Port N100 Mini-PC** | Intel N100, 4x Intel i226-V 2.5GbE, fanless aluminum chassis | ~€150–€180 | Allows running Debian or OpenWrt x86 directly, giving 4 physical discrete eth ports. |

### B. The Target Bare-Metal Server (Edge MicroServer)
The server must support **UEFI PXE / HTTP Boot**, a **hardware TPM 2.0 chip**, and an **NVMe drive** to prove automated LUKS2 drive encryption.

| Option | Hardware Model | Specs | Est. Price | Target Role |
| :--- | :--- | :--- | :--- | :--- |
| **Recommended (Mini Server)** | **Minisforum MS-01 or ASUS NUC / PN64** | Intel Core i5/i9 or 12th/13th Gen, Intel i226 NICs, 32GB RAM, discrete TPM 2.0, PCIe NVMe | ~€350–€480 | Real workstation/edge server with dual 10G SFP+ and dual 2.5G ports. Supports Intel vPro / AMT for remote power control. |
| **Budget Friendly** | **Beelink EQ12 / Mini-PC with Intel N100** | Intel N100, 16GB DDR5, 512GB NVMe, dual Intel i225/i226 NICs, firmware TPM 2.0 (fTPM) | ~€160–€200 | Very affordable, has real dual Intel NICs with UEFI PXE support and fTPM 2.0. |
| **Enterprise Server (Rackmount)** | **Supermicro 1U (Refurbished X10SDV or X11SCL)** | Intel Xeon D-1541 or Xeon E-2100, 32GB ECC RAM, IPMI / BMC dedicated port | ~€300–€500 | Real 1U enterprise rack chassis with IPMI remote console (great visual for enterprise demos). |

### C. Network Accessories & Cables
- 1x Simple 5-port Gigabit Managed Switch (e.g. **TP-Link TL-SG105E**, ~€25) — *Only needed if your router does not have independent hardware switch chips for VLAN trunking.*
- 3x Cat6 Snagless Ethernet Patch Cables (1m each, ~€10).
- 1x USB-to-TTL Serial or HDMI Dummy Plug (for debugging boot stages if needed, ~€8).

**Total Estimated Lab Budget:** **€350 – €650** depending on the server model chosen.

---

## 3. Real Physical Software Stack

In the production lab, the loopback simulation is replaced with standard carrier protocols:

### 1. DHCP & Bootloader Chain (`dnsmasq` on Router)
Configure `dnsmasq.conf` on the router:
```conf
# Interface binding
interface=lan4
dhcp-range=lan4,192.168.100.50,192.168.100.60,255.255.255.0,1h
dhcp-option=lan4,3,192.168.100.1
dhcp-option=lan4,6,192.168.100.1

# UEFI PXE / HTTP Boot chainload
dhcp-match=set:efi-x86_64,option:client-arch,7
dhcp-match=set:efi-x86_64,option:client-arch,9
dhcp-boot=tag:efi-x86_64,ipxe.efi
```

### 2. Network Isolation (`nftables` on Router)
When a device first connects to LAN 4:
```nft
# Quarantine table: only allow DHCP, DNS, and Vector Agent HTTP (:8088)
table inet filter {
    chain forward {
        type filter hook forward priority 0; policy drop;
        iifname "lan4" oifname "wan" drop
        iifname "lan4" oifname "lan1" drop
    }
    chain input {
        type filter hook input priority 0; policy accept;
        iifname "lan4" tcp dport { 8088 } accept
        iifname "lan4" udp dport { 67, 53 } accept
        iifname "lan4" drop
    }
}
```
Upon authorization in the UI, `agent.py` updates the switch chip port association or switches the `nftables` policy to allow routing to `wan` and `lan1`.

### 3. Automated Bare-Metal Autoinstall (`cloud-init` / Ubuntu Subiquity)
The server boots over HTTP and loads the official Ubuntu 24.04 netboot ISO with `user-data`:
```yaml
#cloud-config
autoinstall:
  version: 1
  storage:
    layout:
      name: direct
    config:
      - id: disk0
        type: disk
        match:
          size: largest
      - id: luks0
        type: luks
        volume: disk0
        name: cryptroot
  late-commands:
    # Enroll TPM 2.0 PCRs so drive unseals ONLY on this physical motherboard
    - curtin in-target -- systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0,7 /dev/nvme0n1p2
    # Signal Vector Agent that provisioning completed
    - curtin in-target -- curl -s -X POST http://192.168.100.1:8088/api/v1/nodes/complete
```

---

## 4. How to Present the Live Physical Test to Telia Engineers

When Telia's technical team arrives:

1. **Step 1: The "Clean State" Handshake**
   - Show them the physical microserver sitting on the table, completely unplugged.
   - Show them the router running the Vector Agent (`top -b -n 1 | grep agent` -> proves 26 MB RAM, 0% CPU).
2. **Step 2: Plug in the Ethernet Cable**
   - Plug the server into Port 4. Turn on the server.
   - Show the browser console at `http://192.168.100.1:3000`: within 3 seconds, a yellow **"Quarantined Device Detected"** card appears with the server's real Intel MAC address.
3. **Step 3: Prove Zero-Trust Isolation**
   - Attempt to ping the internet from the server or SSH into it from the office laptop: demonstrate that the firewall actively drops packets or rejects connections.
4. **Step 4: One-Click Zero-Touch Authorization**
   - Select the target operating system (e.g. *Sovereign Legal Advisory* or *Ubuntu Server 24.04*).
   - Click **"Authorize & Deploy Appliance"**.
   - Watch the server's HDMI screen (or serial console): it immediately chainloads iPXE over HTTP, streams the kernel, seals the NVMe partition with TPM 2.0, and reboots.
5. **Step 5: The Grand Finale**
   - The UI automatically updates to **ACTIVE (VLAN 10)**.
   - Connect via SSH: `ssh ubuntu@192.168.100.50`.
   - Run `systemd-cryptenroll --tpm2-device=list` and `cryptsetup status cryptroot`: prove to their security architects that the disk is locked with LUKS2 and bound to the physical Infineon/Intel TPM 2.0 chip!
