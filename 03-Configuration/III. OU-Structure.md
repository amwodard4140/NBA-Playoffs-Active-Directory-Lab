# III. OU Structure

✅ **Status: Completed.** All 18 OUs built with no naming changes from the original list, "Protect container from accidental deletion" left checked on every one, no issues encountered.

Built by hand in **Active Directory Users and Computers** before any automation touched it, so `New-ADOrganizationalUnit` wouldn't just be a mystery command copy-pasted later.

## Step 1 — Open ADUC

`Server Manager → Tools → Active Directory Users and Computers`, or `dsa.msc`.

## Step 2 — Create the top-level NBA OU

Right-click **nba.local → New → Organizational Unit** → name: `NBA`. Leave **"Protect container from accidental deletion"** checked.

<img width="1920" height="1080" alt="Screenshot (151)" src="https://github.com/user-attachments/assets/7daa5f23-a90d-4d25-a705-f585e8249077" />


## Step 3 — Create the two Conference OUs

Right-click **NBA → New → Organizational Unit**, twice: `Eastern Conference`, `Western Conference`.

<img width="1920" height="1080" alt="Screenshot (191)" src="https://github.com/user-attachments/assets/8381bd58-bd35-4201-82f0-a738579a3c23" />


## Step 4 — Create the 16 team OUs

Under each Conference OU, one OU per team:

**Eastern Conference:** Detroit Pistons, Boston Celtics, New York Knicks, Cleveland Cavaliers, Toronto Raptors, Atlanta Hawks, Philadelphia 76ers, Orlando Magic

**Western Conference:** Oklahoma City Thunder, San Antonio Spurs, Denver Nuggets, Los Angeles Lakers, Houston Rockets, Minnesota Timberwolves, Portland Trail Blazers, Phoenix Suns

Exact spelling matters here — these names need to character-match the `Team` column in the roster CSV used in [Automation](../04-Automation/I.%20Roster-Data.md). A typo creates a second, differently-named OU instead of throwing an error.

<img width="1920" height="1080" alt="Screenshot (193)" src="https://github.com/user-attachments/assets/78f12b0c-3836-45e7-af05-45c497d233cd" />


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

<img width="1920" height="1080" alt="Screenshot (194)" src="https://github.com/user-attachments/assets/cd81588d-82c1-4dfb-9445-ce279ef92efa" />

<img width="1920" height="1080" alt="Screenshot (195)" src="https://github.com/user-attachments/assets/d731be27-f9b2-4eb6-b1fb-fa8740c2a3cd" />
