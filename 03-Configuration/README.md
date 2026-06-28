# 03 — Configuration

With networking in place, this phase turns the server into an actual functioning domain: installing AD DS, promoting it to a forest, verifying DNS came up correctly, and building the OU structure that everything else hangs off of.

- [I. AD DS Installation and Domain Promotion](./I.%20AD-DS-Installation-And-Promotion.md)
- [II. DNS Verification](./II.%20DNS-Verification.md)
- [III. OU Structure](./III.%20OU-Structure.md)

All of this was done through Server Manager / ADUC rather than PowerShell, deliberately — the goal was to understand what each wizard click actually does before letting a script do the equivalent work later in [Automation](../04-Automation/README.md).
