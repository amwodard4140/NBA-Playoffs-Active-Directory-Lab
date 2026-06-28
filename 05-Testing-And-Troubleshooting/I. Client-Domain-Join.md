# I. Client Domain Join

✅ **Status: Completed.** Join completed cleanly, no errors. Tested with the Aaron Gordon account — forced password-change prompt appeared as expected, and login succeeded right after setting a new password.

With the client VM built and networked (see [Environment Setup II](../02-Environment-Setup/II.%20Client-VM-Setup.md)), the next step is actually joining it to `nba.local`.

## Step 1 — Join the domain

GUI: **Settings → Accounts → Access work or school → Connect → "Join this device to a local Active Directory domain"** → domain `nba.local` → enter `NBA\Administrator` credentials.

PowerShell equivalent:

```powershell
Add-Computer -DomainName "nba.local" -Credential (Get-Credential) -Restart
```

📸 *Screenshot: `06-Screenshots/Testing-And-Troubleshooting/01-Domain-Join-Dialog.png`*

## Step 2 — Verify the join

On the client:

```powershell
(Get-WmiObject Win32_ComputerSystem).Domain   # should return nba.local
```

On the DC:

```powershell
Get-ADComputer -Filter * | Select Name        # the client should now be listed
```

📸 *Screenshot: `06-Screenshots/Testing-And-Troubleshooting/02-Get-ADComputer-Output.png`*

## Step 3 — Log in as a player account

At the login screen: `NBA\<logonname>` with the default password (`ChangeMe!2026`). This should immediately prompt **"You must change your password before signing in"** — confirming `ChangePasswordAtLogon` is working as configured.

📸 *Screenshot: `06-Screenshots/Testing-And-Troubleshooting/03-Forced-Password-Change-Prompt.png`*

📸 *Screenshot: `06-Screenshots/Testing-And-Troubleshooting/04-Successful-Player-Login.png`*
