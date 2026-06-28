# I. AD DS Installation and Domain Promotion

✅ **Status: Completed.** Domain name kept as planned (`nba.local`). No warnings beyond the expected DNS delegation notice, no deviations from the steps below.

## Step 1 — Install the AD DS role

1. **Server Manager → Manage → Add Roles and Features**
2. Role-based or feature-based installation → Next
3. Local server selected → Next
4. **Server Roles** → check **Active Directory Domain Services** → accept the "Add Features" prompt → Next
5. Features → Next, AD DS info page → Next
6. **Confirmation** → check "Restart the destination server automatically if required" → **Install**

<img width="1920" height="1080" alt="Screenshot (145)" src="https://github.com/user-attachments/assets/2d623c47-b8a9-439b-b5aa-2a29ebf3c897" />


## Step 2 — Promote to a domain controller

1. Click the notification flag in Server Manager → **"Promote this server to a domain controller"**
2. **Deployment Configuration** → "Add a new forest" → root domain name: `nba.local`

<img width="1920" height="1080" alt="Screenshot (146)" src="https://github.com/user-attachments/assets/4d90aeeb-a5aa-404d-9f2a-9a176a6006c2" />

3. **Domain Controller Options** → leave functional levels at default, DNS Server checked, Global Catalog checked (greyed out for first DC). Set a DSRM password — a separate "break glass" password used only for offline AD recovery.
4. **DNS Options** → expect a yellow warning about DNS delegation — normal for an isolated lab with no parent zone.
5. **Additional Options** → NetBIOS name auto-fills to `NBA`.
6. **Paths** → leave defaults.
7. **Review Options** → the "View script" link shows the PowerShell equivalent of every click so far, worth a glance.
8. **Prerequisites Check** → wait for "All prerequisite checks passed successfully" → **Install**

<img width="1920" height="1080" alt="Screenshot (148)" src="https://github.com/user-attachments/assets/cb8bfbf7-cbc7-430f-ad68-64b15e508c5a" />


The server reboots automatically when this finishes.

## Step 3 — Verify

Log back in as `NBA\Administrator` and check:

- **ADUC** — `nba.local` with the standard containers present
- **DNS Manager** — `nba.local` forward lookup zone with SOA/NS/A records
- **Active Directory Domains and Trusts** — `nba.local` listed as the one domain in the one forest
- **Event Viewer → Directory Service** — mostly Information-level events, no red Errors around the promotion timestamp

<img width="1920" height="1080" alt="Screenshot (149)" src="https://github.com/user-attachments/assets/9c25cf1e-8c0a-4be8-bd8a-b1da9429f418" />

