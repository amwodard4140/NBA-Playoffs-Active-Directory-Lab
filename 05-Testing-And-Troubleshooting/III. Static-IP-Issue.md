# III. The Static IP Issue

> *This issue was identified during the original build of this lab. It's kept here because it's the reason connectivity is explicitly double-checked before every domain join attempt in this workflow — but it wasn't re-triggered during the most recent rebuild. (A different, related issue — a network name mismatch — did come up this round; see [Testing & Troubleshooting IV](./IV.%20Internal-Network-Name-Mismatch.md).)*

## What happened

While setting up the client VM for domain join, `ping 192.168.10.1` (the DC) failed.

## What was actually going on

Checking the client's network connection (`ipconfig`) showed its static IP address wasn't actually applied — the adapter had no IP assigned at all, despite having been configured earlier in [Environment Setup II](../02-Environment-Setup/II.%20Client-VM-Setup.md).

📸 *Screenshot: `06-Screenshots/Testing-And-Troubleshooting/07-ipconfig-Missing-IP.png` — the client's adapter showing no IP assigned.*

## The fix

Manually re-entering the static IP (`192.168.10.10`, matching the `192.168.10.0/24` internal network) resolved it immediately. `ping` and `nslookup nba.local` both succeeded right after, and the domain join completed cleanly.

📸 *Screenshot: `06-Screenshots/Testing-And-Troubleshooting/08-ipconfig-IP-Restored.png` — the same adapter after re-entering the static IP.*

## Takeaway

Don't assume a VM's network configuration "stuck" just because it was set once — especially on an isolated internal network with no DHCP server to fall back on. If a static IP silently drops, there's nothing to reassign one automatically, and the symptom (failed `ping`, failed domain join) looks identical to several other possible causes. Checking `ipconfig` on the client was the actual first diagnostic step that mattered, before assuming the problem was DNS, firewall rules, or VirtualBox's network configuration.
