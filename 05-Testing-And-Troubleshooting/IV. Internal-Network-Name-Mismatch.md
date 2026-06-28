# IV. Internal Network Name Mismatch

## What happened

While setting up the client VM, `ping 192.168.10.1` (the DC) succeeded, but `nslookup nba.local` kept timing out. Since ping worked, the assumption going in was that basic connectivity was fine and the problem had to be DNS-specific.

## The investigation — three reasonable checks, none of them the actual cause

**Check 1 — Is the DC's DNS service even running?**
```powershell
Get-Service DNS
```
Came back `Running`. Not the cause.

**Check 2 — Is Windows Firewall blocking port 53?**
```powershell
Get-NetFirewallRule -DisplayGroup "DNS Service" | Select DisplayName, Enabled, Direction, Action
```
All rules showed `Enabled : True`. Not the cause, at least not directly.

**Check 3 — Is the DC's Internal NIC categorized as Public instead of Private/Domain?**
This one had a real basis: Windows Firewall rules are often scoped to specific network profiles, and isolated internal networks with no default gateway frequently get miscategorized as `Public` (Windows can't verify the network identity, so it defaults to the most restrictive category). Checking confirmed the Internal NIC *was* showing `Public`.

```powershell
Set-NetConnectionProfile -InterfaceAlias "<Internal NIC>" -NetworkCategory Private
```

This looked like a strong candidate — and it's a legitimate thing to fix regardless — but `Test-NetConnection -ComputerName 192.168.10.1 -Port 53` still came back `TcpTestSucceeded : False` afterward.

## The actual cause

None of the above. The DC's Internal Network adapter had been left at VirtualBox's default name, `intnet`, this entire time — it was never actually renamed to a custom name, despite that having been the original intent. The client VM's adapter, meanwhile, had been explicitly named something else when it was configured.

VirtualBox's Internal Network mode is a purely name-matched virtual switch: two VMs are only on the same internal network if their adapter's "Name" field matches **character-for-character**. If it doesn't match, the two VMs are on entirely separate, non-communicating virtual networks — and nothing inside Windows can detect or report this. `ipconfig`, `Test-NetConnection`, Event Viewer, firewall rules, service status — none of it can see a VirtualBox-level configuration mismatch, because from Windows' perspective on either VM, its own network adapter looks perfectly normal.

## The fix

In the client VM's VirtualBox settings (**Settings → Network**), the Internal Network adapter name was changed to `intnet`, matching the DC's adapter exactly. Immediately after:

```powershell
Test-NetConnection -ComputerName 192.168.10.1 -Port 53   # TcpTestSucceeded : True
nslookup nba.local                                        # resolved correctly
```

Both succeeded right away.

## Why this took multiple passes to find

This is worth being honest about rather than smoothing over: the troubleshooting went DNS service → firewall rules → network profile category before landing on the real cause, and all three of those were reasonable, defensible things to check given the symptom. The actual bug lived one layer below all of them, at the hypervisor's virtual networking configuration — a layer none of the in-OS diagnostic tools have any visibility into at all.

## Takeaway

When two VMs on what's supposed to be the same isolated network can't talk to each other, it's worth checking the **literal VirtualBox adapter settings on both VMs, side by side**, before spending time on DNS, firewall, or profile troubleshooting inside Windows. None of those tools can tell you the hypervisor-level network name doesn't match — that's a check that has to happen outside the guest OS entirely. A single typo, or in this case a default value that was assumed to have been changed but never was, is invisible from every angle except literally comparing the two settings panes.
