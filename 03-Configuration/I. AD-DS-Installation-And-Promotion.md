# I. AD DS Installation and Domain Promotion

✅ **Status: Completed.** Domain name kept as planned (`nba.local`). No warnings beyond the expected DNS delegation notice, no deviations from the steps below.

> Before starting: take a VirtualBox snapshot of the DC ("Pre-DCPromo"). Promoting to a DC is painful to walk back manually.

## Step 1 — Install the AD DS role

1. **Server Manager → Manage → Add Roles and Features**
2. Role-based or feature-based installation → Next
3. Local server selected → Next
4. **Server Roles** → check **Active Directory Domain Services** → accept the "Add Features" prompt → Next
5. Features → Next, AD DS info page → Next
6. **Confirmation** → check "Restart the destination server automatically if required" → **Install**

📸 *Screenshot: `06-Screenshots/Configuration/01-AD-DS-Role-Confirmation.png`*

## Step 2 — Promote to a domain controller

1. Click the notification flag in Server Manager → **"Promote this server to a domain controller"**
2. **Deployment Configuration** → "Add a new forest" → root domain name: `nba.local`

📸 *Screenshot: `06-Screenshots/Configuration/02-Deployment-Configuration.png`*

3. **Domain Controller Options** → leave functional levels at default, DNS Server checked, Global Catalog checked (greyed out for first DC). Set a DSRM password — a separate "break glass" password used only for offline AD recovery.
4. **DNS Options** → expect a yellow warning about DNS delegation — normal for an isolated lab with no parent zone.
5. **Additional Options** → NetBIOS name auto-fills to `NBA`.
6. **Paths** → leave defaults.
7. **Review Options** → the "View script" link shows the PowerShell equivalent of every click so far, worth a glance.
8. **Prerequisites Check** → wait for "All prerequisite checks passed successfully" → **Install**

📸 *Screenshot: `06-Screenshots/Configuration/03-Prerequisites-Check.png`*

The server reboots automatically when this finishes.

## Step 3 — Verify

Log back in as `NBA\Administrator` and check:

- **ADUC** — `nba.local` with the standard containers present
- **DNS Manager** — `nba.local` forward lookup zone with SOA/NS/A records
- **Active Directory Domains and Trusts** — `nba.local` listed as the one domain in the one forest
- **Event Viewer → Directory Service** — mostly Information-level events, no red Errors around the promotion timestamp

📸 *Screenshot: `06-Screenshots/Configuration/04-ADUC-Post-Promotion.png`*
