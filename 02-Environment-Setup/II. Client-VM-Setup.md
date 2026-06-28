# II. Client VM Setup

✅ **Status: Completed.** Connectivity confirmed working (`ping` and `nslookup nba.local` both succeed) — but it took a few passes to get there. See [Testing & Troubleshooting IV](../05-Testing-And-Troubleshooting/IV.%20Internal-Network-Name-Mismatch.md) for the full story; short version is the client's internal network adapter name didn't match the DC's, which silently put them on two separate virtual networks.

A domain-joined client VM is needed to test player logins correctly — logging in directly at the DC console is blocked by design (see [Testing & Troubleshooting II](../05-Testing-And-Troubleshooting/II.%20Authentication-vs-Authorization.md) for why).

## Step 1 — Create the VM

Standard VirtualBox VM creation: Windows 10/11, 4GB+ RAM, 50-60GB disk, Windows ISO attached.

## Step 2 — Attach the NIC to the internal network

**Settings → Network → Adapter 1**: Enable, attached to **Internal Network**, name **`intnet`** — must match the DC's internal NIC name exactly.

📸 *Screenshot: `06-Screenshots/Environment-Setup/06-Client-NIC-Settings.png`*

## Step 3 — Configure a static IP

Since there's no DHCP server on this internal segment, the client needs a static IP in the same range as the DC.

- IP address: `192.168.10.10`
- Subnet mask: `255.255.255.0`
- Default gateway: *(blank)*
- Preferred DNS server: `192.168.10.1` *(the DC — critical for domain join to work)*

📸 *Screenshot: `06-Screenshots/Environment-Setup/07-Client-IPv4-Properties.png`*

## Step 4 — Verify connectivity to the DC before joining

```powershell
ping 192.168.10.1
nslookup nba.local
```

If either of these fails, **stop and fix it before attempting a domain join** — domain join will fail for the same reason and the error message is usually less obvious about the actual cause. Common culprits: the static IP didn't actually apply (check with `ipconfig`), the internal network name doesn't match character-for-character between the two VMs, or the DC's firewall is blocking something.

📸 *Screenshot: `06-Screenshots/Environment-Setup/08-Client-Connectivity-Test.png`*
