# II. Authentication vs. Authorization

> *This issue was identified during the original build of this lab. It's kept here because it's the reason the workflow in this repo tests logins from a domain-joined client rather than at the DC console — but it wasn't re-triggered during the most recent rebuild, since the lesson was already factored in from the start (see [Testing & Troubleshooting I](./I.%20Client-Domain-Join.md)).*

## What happened

After running the provisioning script, I tried to confirm a player account worked by logging into it (Aaron Gordon) directly at the Domain Controller. After resetting the forced password, login failed with:

> *"The sign-in method you're trying to use isn't allowed."*

## What was actually going on

The account itself was fine — getting past the password reset screen meant authentication had already succeeded. The failure was a separate step: authorization to log on to that specific machine.

Every Windows Server Domain Controller ships with a **Default Domain Controllers Policy** GPO that restricts the **"Allow log on locally"** user right (and the RDP equivalent) to a short list of privileged groups: Administrators, Account Operators, Backup Operators, Server Operators, Print Operators. Ordinary domain users — every player account in this lab — aren't on that list by default. A DC holds `NTDS.dit`, the Kerberos KDC, and every credential hash in the forest, so letting any authenticated domain user sit at its console would collapse the security boundary the domain is supposed to provide.

📸 *Screenshot: `06-Screenshots/Testing-And-Troubleshooting/05-Sign-In-Method-Error.png` — the actual error screen.*

📸 *Screenshot: `06-Screenshots/Testing-And-Troubleshooting/06-GPO-Allow-Log-On-Locally.png` — Default Domain Controllers Policy → User Rights Assignment → Allow log on locally, showing the restricted group list.*

## The fix

Not granting the player account more rights — recognizing that testing end-user logons *at the DC* was the wrong approach. The correct fix was building a domain-joined client VM (see [Testing & Troubleshooting I](./I.%20Client-Domain-Join.md)) and logging in from there instead, which worked immediately.

## Why it matters

This is a clean example of a basic IAM distinction: **authentication confirms who you are; authorization decides what you're allowed to do, and where.** A single account can correctly pass the first check and correctly fail the second — that's not a bug, that's the system enforcing least privilege on infrastructure that holds the keys to the entire domain.
