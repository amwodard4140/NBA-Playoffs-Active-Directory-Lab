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

<img width="1920" height="1080" alt="Screenshot (157)" src="https://github.com/user-attachments/assets/1a2c7a80-3f06-4318-bb2e-adffbfcc1416" />


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

<img width="1920" height="1080" alt="Screenshot (159)" src="https://github.com/user-attachments/assets/a42d3e71-3847-437d-9b56-62bd80035b15" />


## Verifying in ADUC

Refresh ADUC (F5) and drill into a team OU — e.g. `NBA → Eastern Conference → Denver Nuggets` should show 15 user objects.

<img width="1920" height="1080" alt="Screenshot (161)" src="https://github.com/user-attachments/assets/3d76190a-e138-426d-ba87-0a52deb89549" />

Double-click a user to confirm basic attributes (name, logon name) landed correctly.

<img width="1920" height="1080" alt="Screenshot (197)" src="https://github.com/user-attachments/assets/c7c02871-6c05-4dbb-9f4f-3c544696caf3" />

<img width="1920" height="1080" alt="Screenshot (198)" src="https://github.com/user-attachments/assets/f30b3a7a-f4f2-400c-a688-26c3e0e16b09" />
