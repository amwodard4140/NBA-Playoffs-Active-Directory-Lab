# II. DNS Verification

✅ **Status: Completed.** Verification came back clean across the board — no issues.

DNS gets installed automatically during domain promotion, but it's worth confirming it actually came up correctly before building anything on top of it.

## Step 1 — Check the forward lookup zone

**Server Manager → Tools → DNS Manager** → expand **Forward Lookup Zones** → `nba.local` should be present with:

- An SOA (Start of Authority) record
- An NS (Name Server) record
- An A record for the DC itself, pointing at its own internal IP (`192.168.10.1`)

📸 *Screenshot: `06-Screenshots/Configuration/05-DNS-Manager-Forward-Zone.png`*

## Step 2 — Confirm resolution from the command line

```powershell
nslookup nba.local
```

Should return the DC's internal IP. If this fails, nothing downstream — domain join, Kerberos, group policy — will work either, so it's worth fixing here before moving on.

📸 *Screenshot: `06-Screenshots/Configuration/06-nslookup-Output.png`*

## Step 3 — Confirm the DC's own DNS client settings

```powershell
Get-DnsClientServerAddress
```

The Internal NIC should point at `127.0.0.1` or its own IP — not anything related to the Internet-facing NAT adapter.
