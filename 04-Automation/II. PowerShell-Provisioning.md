# II. PowerShell Provisioning

✅ **Status: Completed.** Ran clean on the first real attempt — summary matched expectations exactly: `Teams provisioned: 16`, `Users created: 230`, `Users skipped: 0`. Default temporary password applied as configured.

[`scripts/Build-NBAPlayoffsAD.ps1`](./scripts/Build-NBAPlayoffsAD.ps1) reads the roster CSV and does three things:

1. Creates the OU structure if it doesn't already exist (checks `Get-ADOrganizationalUnit` first — see idempotency note below)
2. Creates one AD user per row, in the correct team OU, using the CSV's `LogonName` column as the `sAMAccountName`
3. Sets a temporary password (`-ChangePasswordAtLogon $true` by default) so every account forces a password change at first login

## Getting the files onto the DC

Since this is an isolated lab VM with no shared folders set up, the simplest path is pasting the file contents directly into Notepad and saving with **"Save as type: All Files"** (otherwise Notepad appends `.txt`).

## Running it

```powershell
cd C:\NBA-Lab
Get-ExecutionPolicy
# If Restricted:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
```

Preview first with `-WhatIf` (the script supports `SupportsShouldProcess`):

```powershell
.\Build-NBAPlayoffsAD.ps1 -DomainDN "DC=nba,DC=local" -WhatIf
```

Then for real:

```powershell
.\Build-NBAPlayoffsAD.ps1 -DomainDN "DC=nba,DC=local"
```

📸 *Screenshot: `06-Screenshots/Automation/01-WhatIf-Preview.png`*

## What a successful run looks like

- 18× `"OU already exists"` in dark gray, if the OUs were already built manually (confirms the manual and scripted approaches agree)
- 230× `"Created: <Player Name> -> OU=..."` in green
- A summary block:
  ```
  Teams provisioned : 16
  Users created     : 230
  Users skipped     : 0 (already existed)
  Default password  : ChangeMe!2026  (change at next logon enforced)
  ```

📸 *Screenshot: `06-Screenshots/Automation/02-Script-Run-Summary.png`*

## Verifying in ADUC

Refresh ADUC (F5) and drill into a team OU — e.g. `NBA → Eastern Conference → New York Knicks` should show 15 user objects.

📸 *Screenshot: `06-Screenshots/Automation/03-Populated-Team-OU.png`*

Double-click a user to confirm basic attributes (name, logon name) landed correctly.

📸 *Screenshot: `06-Screenshots/Automation/04-User-Properties-Dialog.png`*

## Idempotency

Re-running the script after it's already succeeded should produce 230× `"Skipping existing user"` and zero new creates — confirming it's safe to run more than once without duplicating or erroring out.
