# 01 — Planning

## Why this lab exists

This started as a way to get hands-on with Active Directory while studying for the Microsoft SC-300 (Identity and Access Administrator Associate) certification. Reading about OU design and PowerShell provisioning is one thing; actually building a domain, breaking something, and figuring out why, is what makes it stick.

The NBA theme isn't the point of the project — it's just a more interesting dataset to organize than generic placeholder employees. Two conferences, sixteen playoff teams, and full playoff rosters mapped naturally onto a two-tier OU structure, which made it a good stand-in for how a real organization might segment by region or department.

## Goals for the lab

- Design a real OU hierarchy instead of dropping every account into the default `Users` container
- Provision enough accounts (230, across 16 teams) that doing it by hand would be impractical, but build the structure manually first so the automation isn't a black box
- Work with data messy enough to need real handling — duplicate surnames needing disambiguated logon names, for example
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

<svg viewBox="0 0 900 640" xmlns="http://www.w3.org/2000/svg" font-family="Segoe UI, Helvetica, Arial, sans-serif">
  <rect x="0" y="0" width="900" height="640" fill="#ffffff"/>

  <text x="450" y="32" text-anchor="middle" font-size="20" font-weight="700" fill="#1a202c">NBA Playoffs AD Lab — Network Architecture</text>

  <!-- Internet cloud -->
  <ellipse cx="230" cy="95" rx="100" ry="42" fill="#cfe8ff" stroke="#5b9bd5" stroke-width="2"/>
  <text x="230" y="90" text-anchor="middle" font-size="15" font-weight="600" fill="#1a4d7a">Internet</text>
  <text x="230" y="108" text-anchor="middle" font-size="11" fill="#1a4d7a">(Windows Update only)</text>

  <!-- NAT connection line -->
  <line x1="230" y1="137" x2="230" y2="200" stroke="#5b9bd5" stroke-width="2" marker-end="url(#arrow)"/>
  <text x="245" y="170" font-size="11" fill="#3b6ea5">NAT</text>
  <text x="245" y="184" font-size="11" fill="#3b6ea5">10.0.2.x</text>

  <!-- VirtualBox Host boundary -->
  <rect x="60" y="200" width="780" height="400" rx="10" fill="#fafbfc" stroke="#a0aec0" stroke-width="2" stroke-dasharray="6,4"/>
  <text x="80" y="225" font-size="13" font-weight="600" fill="#4a5568">VirtualBox Host</text>

  <!-- Domain Controller box -->
  <rect x="130" y="250" width="270" height="170" rx="8" fill="#1e3a5f" />
  <text x="265" y="282" text-anchor="middle" font-size="15" font-weight="700" fill="#ffffff">Domain Controller</text>
  <text x="265" y="302" text-anchor="middle" font-size="12" fill="#cbd5e0">Windows Server</text>
  <text x="265" y="320" text-anchor="middle" font-size="12" font-style="italic" fill="#cbd5e0">nba.local</text>

  <rect x="150" y="335" width="230" height="26" rx="4" fill="#2d5a8c"/>
  <text x="265" y="352" text-anchor="middle" font-size="11" fill="#ffffff">NIC 1 — NAT (Internet)</text>

  <rect x="150" y="368" width="230" height="26" rx="4" fill="#2d5a8c"/>
  <text x="265" y="385" text-anchor="middle" font-size="11" fill="#ffffff">NIC 2 — Internal: 192.168.10.1</text>

  <!-- Client VM box -->
  <rect x="500" y="250" width="270" height="170" rx="8" fill="#2f4858"/>
  <text x="635" y="282" text-anchor="middle" font-size="15" font-weight="700" fill="#ffffff">Client VM</text>
  <text x="635" y="302" text-anchor="middle" font-size="12" fill="#cbd5e0">NBA-Client01 — Windows 10/11</text>
  <text x="635" y="320" text-anchor="middle" font-size="12" font-style="italic" fill="#cbd5e0">domain-joined to nba.local</text>

  <rect x="520" y="335" width="230" height="26" rx="4" fill="#3d6577"/>
  <text x="635" y="352" text-anchor="middle" font-size="11" fill="#ffffff">NIC — Internal: 192.168.10.10</text>

  <rect x="520" y="368" width="230" height="26" rx="4" fill="#3d6577"/>
  <text x="635" y="385" text-anchor="middle" font-size="11" fill="#ffffff">DNS → 192.168.10.1</text>

  <!-- Internal network switch bar -->
  <rect x="150" y="500" width="600" height="50" rx="6" fill="#e2e8f0" stroke="#a0aec0" stroke-width="1.5"/>
  <text x="450" y="521" text-anchor="middle" font-size="13" font-weight="600" fill="#2d3748">Internal Network — "intnet"</text>
  <text x="450" y="538" text-anchor="middle" font-size="11" fill="#4a5568">192.168.10.0/24 (isolated, no gateway, no internet access)</text>

  <!-- Connectors from VM boxes down to switch -->
  <line x1="265" y1="420" x2="265" y2="500" stroke="#1e3a5f" stroke-width="2" marker-end="url(#arrowDark)"/>
  <line x1="635" y1="420" x2="635" y2="500" stroke="#2f4858" stroke-width="2" marker-end="url(#arrowDark)"/>

  <!-- Footer note -->
  <text x="450" y="610" text-anchor="middle" font-size="11" fill="#718096">Internal Network is a name-matched virtual switch — both VMs must use the identical adapter name to communicate.</text>

  <defs>
    <marker id="arrow" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
      <path d="M0,0 L8,4 L0,8 Z" fill="#5b9bd5"/>
    </marker>
    <marker id="arrowDark" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
      <path d="M0,0 L8,4 L0,8 Z" fill="#2d3748"/>
    </marker>
  </defs>
</svg>
