# I. Client Domain Join

✅ **Status: Completed.** Join completed cleanly, no errors. Tested with the Aaron Gordon account — forced password-change prompt appeared as expected, and login succeeded right after setting a new password.

With the client VM built and networked (see [Environment Setup II](../02-Environment-Setup/II.%20Client-VM-Setup.md)), the next step is actually joining it to `nba.local`.

## Step 1 — Join the domain

GUI: **Settings → Accounts → Access work or school → Connect → "Join this device to a local Active Directory domain"** → domain `nba.local` → enter `NBA\Administrator` credentials.

PowerShell equivalent:

```powershell
Add-Computer -DomainName "nba.local" -Credential (Get-Credential) -Restart
```

<img width="1920" height="1080" alt="Screenshot (175)" src="https://github.com/user-attachments/assets/da4c70ba-b993-49ce-a4db-26418f482b7d" />

<img width="1920" height="1080" alt="Screenshot (176)" src="https://github.com/user-attachments/assets/51c4cca9-9477-4f07-bb7d-4d483cc87d50" />

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

<img width="1920" height="1080" alt="Screenshot (183)" src="https://github.com/user-attachments/assets/8e889090-2b6f-456b-a191-85a3612bdcac" />

<img width="1920" height="1080" alt="Screenshot (185)" src="https://github.com/user-attachments/assets/1d01703a-d76e-4f2d-bd6c-23679293a941" />

<img width="1920" height="1080" alt="Screenshot (186)" src="https://github.com/user-attachments/assets/05c58c08-5d63-4765-a630-6578ecb97c32" />

<img width="1920" height="1080" alt="Screenshot (189)" src="https://github.com/user-attachments/assets/04c15f86-d024-43e3-a76d-f403c703e97f" />
