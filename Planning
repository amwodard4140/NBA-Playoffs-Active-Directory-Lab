# 01 — Planning

## Why this lab exists

This started as a way to get hands-on with Active Directory while studying for the Microsoft SC-300 (Identity and Access Administrator Associate) certification. Reading about OU design and PowerShell provisioning is one thing; actually building a domain, breaking something, and figuring out why, is what makes it stick.

The NBA theme isn't the point of the project — it's just a more interesting dataset to organize than generic placeholder employees. Two conferences, sixteen playoff teams, and full playoff rosters mapped naturally onto a two-tier OU structure, which made it a good stand-in for how a real organization might segment by region or department.

## Goals for the lab

- Design a real OU hierarchy instead of dropping every account into the default `Users` container
- Provision enough accounts (230, across 16 teams) that doing it by hand would be impractical, but build the structure manually first so the automation isn't a black box
- Hit and resolve actual problems along the way (a blocked login, a dropped static IP) rather than following a script where everything works the first time

## Environment overview

| Component | Detail |
|---|---|
| Hypervisor | Oracle VirtualBox |
| Domain Controller | Windows Server, promoted to a new forest |
| Client | Windows 10/11, domain-joined |
| Domain | `nba.local` (NetBIOS: `NBA`) |
| Network | Isolated VirtualBox Internal Network (`intnet`) |

## Planned build order

1. [Environment Setup](../02-Environment-Setup/README.md) — VirtualBox networking, DC and client VM creation
2. [Configuration](../03-Configuration/README.md) — AD DS install, forest promotion, DNS, OU structure
3. [Automation](../04-Automation/README.md) — roster data and the PowerShell provisioning script
4. [Testing & Troubleshooting](../05-Testing-And-Troubleshooting/README.md) — domain join, login testing, and what went wrong along the way
