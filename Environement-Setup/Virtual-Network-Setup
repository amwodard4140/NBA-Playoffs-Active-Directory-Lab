# I. VirtualBox Network Setup

✅ **Status: Completed.** The DC runs two NICs: one for outbound internet (Windows Updates only), and one isolated internal network (`intnet`) that carries all the actual AD/DNS/domain traffic.

> **Note:** `intnet` is VirtualBox's default Internal Network name — it was left as-is on the DC rather than set to a custom name. This matters later: see [Testing & Troubleshooting IV](../05-Testing-And-Troubleshooting/IV.%20Internal-Network-Name-Mismatch.md) for what happened when the client VM's adapter got a different name typed in instead.

## Step 1 — Configure the adapters in VirtualBox

1. Select the DC VM → **Settings → Network**
2. **Adapter 1**: Enable, attached to **NAT**
3. **Adapter 2**: Enable, attached to **Internal Network**, name: `intnet` — this exact name has to match on every future VM that needs to see the DC

📸 *Screenshot: `06-Screenshots/Environment-Setup/01-DC-NIC-Settings.png` — VirtualBox Settings → Network, both adapters visible.*

## Step 2 — Identify the NICs inside Windows

Adapter order in Windows doesn't always match VirtualBox's Adapter 1/2 order.

```powershell
ipconfig /all
```

- The NIC pulling a `10.0.2.x` address is the NAT/Internet NIC
- The other one (no IP yet, or APIPA) is the Internal NIC

Rename both in Network Connections (`ncpa.cpl`) so this is obvious at a glance later.

📸 *Screenshot: `06-Screenshots/Environment-Setup/02-ipconfig-DC.png` — `ipconfig /all` output showing both NICs.*

## Step 3 — Configure the Internal NIC (static IP)

- IP address: `192.168.10.1`
- Subnet mask: `255.255.255.0`
- Default gateway: *(blank — no router on this segment)*
- Preferred DNS: `127.0.0.1` *(resolves once the DNS role is installed)*

📸 *Screenshot: `06-Screenshots/Environment-Setup/03-Internal-NIC-IPv4-Properties.png`*

## Step 4 — Leave the Internet NIC on DHCP

No changes — it pulls its address from VirtualBox's NAT engine automatically.

## Step 5 — Harden the Internet NIC

On the **Internet** NIC only:

1. IPv4 Properties → Advanced → DNS tab → uncheck **"Register this connection's addresses in DNS"**
2. WINS tab → **"Disable NetBIOS over TCP/IP"**

Then fix the binding order so Windows always prefers the Internal NIC for name resolution: `ncpa.cpl` → Alt → **Advanced → Advanced Settings** → move **Internal** above **Internet**.

📸 *Screenshot: `06-Screenshots/Environment-Setup/04-Adapter-Binding-Order.png`*

## Step 6 — Verify

```powershell
Get-NetAdapter
Get-NetIPConfiguration
Test-NetConnection -ComputerName 8.8.8.8   # confirms the Internet NIC works
```

📸 *Screenshot: `06-Screenshots/Environment-Setup/05-Verification-Output.png`*
