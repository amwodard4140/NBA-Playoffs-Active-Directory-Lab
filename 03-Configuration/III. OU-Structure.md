# III. OU Structure

✅ **Status: Completed.** All 18 OUs built with no naming changes from the original list, "Protect container from accidental deletion" left checked on every one, no issues encountered.

Built by hand in **Active Directory Users and Computers** before any automation touched it, so `New-ADOrganizationalUnit` wouldn't just be a mystery command copy-pasted later.

## Step 1 — Open ADUC

`Server Manager → Tools → Active Directory Users and Computers`, or `dsa.msc`.

## Step 2 — Create the top-level NBA OU

Right-click **nba.local → New → Organizational Unit** → name: `NBA`. Leave **"Protect container from accidental deletion"** checked.

That checkbox isn't just a UI lock — it sets an explicit **Deny ACE** for the Delete permission on the object's security descriptor. Visible directly in ADUC: enable **View → Advanced Features**, then check the OU's **Security** tab.

📸 *Screenshot: `06-Screenshots/Configuration/07-New-OU-Dialog.png`*

## Step 3 — Create the two Conference OUs

Right-click **NBA → New → Organizational Unit**, twice: `Eastern Conference`, `Western Conference`.

## Step 4 — Create the 16 team OUs

Under each Conference OU, one OU per team:

**Eastern Conference:** Detroit Pistons, Boston Celtics, New York Knicks, Cleveland Cavaliers, Toronto Raptors, Atlanta Hawks, Philadelphia 76ers, Orlando Magic

**Western Conference:** Oklahoma City Thunder, San Antonio Spurs, Denver Nuggets, Los Angeles Lakers, Houston Rockets, Minnesota Timberwolves, Portland Trail Blazers, Phoenix Suns

Exact spelling matters here — these names need to character-match the `Team` column in the roster CSV used in [Automation](../04-Automation/I.%20Roster-Data.md). A typo creates a second, differently-named OU instead of throwing an error.

## Step 5 — Verify the tree

```
nba.local
└── NBA
    ├── Eastern Conference
    │   └── (8 team OUs)
    └── Western Conference
        └── (8 team OUs)
```

18 OUs total (1 + 2 + 16).

📸 *Screenshot: `06-Screenshots/Configuration/08-Full-OU-Tree.png` — this is the most important screenshot in the whole repo. It proves the entire OU design in one image.*

📸 *Screenshot (optional): `06-Screenshots/Configuration/09-OU-Security-Tab-Deny-Delete.png` — an OU's Security tab showing the Deny Delete ACE.*
