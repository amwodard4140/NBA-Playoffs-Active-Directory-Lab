# NBA Playoffs Active Directory Lab

A hands-on Identity and Access Management (IAM) homelab that uses the 2025-26 NBA Playoffs as themed data to practice core Active Directory administration: domain controller deployment, OU design, bulk account provisioning via PowerShell, and authentication/authorization troubleshooting.

This project was built while studying for the Microsoft **SC-300 (Identity and Access Administrator Associate)** certification. 

---

## What's actually in here

| Folder | Covers |
|---|---|
| [`01-Planning`](./01-Planning/) | Project goals, environment overview |
| [`02-Environment-Setup`](./02-Environment-Setup/) | VirtualBox networking, DC and client VM creation |
| [`03-Configuration`](./03-Configuration/) | AD DS install, forest promotion, DNS, OU structure |
| [`04-Automation`](./04-Automation/) | Roster CSV, PowerShell provisioning script |
| [`05-Testing-And-Troubleshooting`](./05-Testing-And-Troubleshooting/) | Domain join, login testing, and two real problems I hit and fixed |
| [`06-Screenshots`](./06-Screenshots/) | Screenshots referenced throughout, organized by phase |

The rest of this README is the short version. Click into any folder above for the full step-by-step write-up.

---

## OU structure

```
nba.local
└── NBA
    ├── Eastern Conference
    │   ├── Detroit Pistons
    │   ├── Boston Celtics
    │   ├── New York Knicks
    │   ├── Cleveland Cavaliers
    │   ├── Toronto Raptors
    │   ├── Atlanta Hawks
    │   ├── Philadelphia 76ers
    │   └── Orlando Magic
    └── Western Conference
        ├── Oklahoma City Thunder
        ├── San Antonio Spurs
        ├── Denver Nuggets
        ├── Los Angeles Lakers
        ├── Houston Rockets
        ├── Minnesota Timberwolves
        ├── Portland Trail Blazers
        └── Phoenix Suns
```

18 OUs total (1 top-level + 2 conference + 16 team), built manually in ADUC before any automation touched them — see [Configuration III](./03-Configuration/III.%20OU-Structure.md) for the full walkthrough, including how "protect from accidental deletion" actually works under the hood.

---

## The automation

[`04-Automation/scripts/Build-NBAPlayoffsAD.ps1`](./04-Automation/scripts/Build-NBAPlayoffsAD.ps1) reads [`04-Automation/data/NBA_Playoffs_2026_Roster.csv`](./04-Automation/data/NBA_Playoffs_2026_Roster.csv) and provisions all 230 accounts — one per playoff roster spot, across all 16 teams — into the correct team OU, with a forced password change on first login. 

```powershell
.\Build-NBAPlayoffsAD.ps1 -DomainDN "DC=nba,DC=local"
```

Full breakdown in [Automation II](./04-Automation/II.%20PowerShell-Provisioning.md).

---

## What I actually learned

The most useful part of this project wasn't the automation — it was two problems that looked like bugs and turned out to be real lessons.

**Authentication vs. authorization:** After provisioning all the accounts, I tried logging into one directly at the Domain Controller and got blocked with "the sign-in method you're trying to use isn't allowed." The account was fine — Windows Server's Default Domain Controllers Policy deliberately restricts console logon at a DC to a handful of admin-tier groups, regardless of whether a regular account's credentials are valid. The fix wasn't loosening that policy; it was testing from a properly domain-joined client VM instead, which is also just the realistic way end users actually log in. Full writeup: [Testing & Troubleshooting II](./05-Testing-And-Troubleshooting/II.%20Authentication-vs-Authorization.md).

**A dropped static IP:** Setting up that client VM, `ping` to the DC failed. Turned out the client's static IP hadn't actually applied — `ipconfig` showed no address at all, despite having configured one earlier. Re-entering it fixed the connectivity immediately. Full writeup: [Testing & Troubleshooting III](./05-Testing-And-Troubleshooting/III.%20Static-IP-Issue.md).

---

## Possible next steps

- Security groups (per position or per conference) for an RBAC demonstration layered on top of the OU structure
- Conditional Access and MFA policy simulation
- A reverse lookup DNS zone and DHCP scope for the internal network
- OU-scoped Group Policy instead of relying solely on domain-wide defaults
