# I. Roster Data

[`data/NBA_Playoffs_2026_Roster.csv`](./data/NBA_Playoffs_2026_Roster.csv) lists every player on each of the 16 playoff teams' actual playoff roster — not the full regular-season roster, just who was active during the playoffs.

| Column | Description |
|---|---|
| `Conference` | Eastern Conference / Western Conference |
| `Team` | One of the 16 playoff teams — must exactly match the OU names from [Configuration III](../03-Configuration/III.%20OU-Structure.md) |
| `Name` | Player's display name |
| `LogonName` | Pre-computed, deduplicated `sAMAccountName` |

230 rows total.

## Logon name convention

Logon names follow a `{first initial}{surname}` pattern, lowercase, non-alphanumeric characters stripped — e.g. `Jalen Brunson` → `jbrunson`.

## Handling collisions

`sAMAccountName` has to be unique across the **entire domain**, not just within a single OU. Three different players named Green play for three different teams, which collide under this convention:

| Player | Team | Logon Name |
|---|---|---|
| Javonte Green | Detroit Pistons | `jgreen` |
| Jeff Green | Houston Rockets | `jgreen1` |
| Jalen Green | Phoenix Suns | `jgreen2` |

Same story with two Thompsons (`athompson` / `athompson1`) and two Williamses (`jwilliams` / `jwilliams1`). This wasn't engineered into the data on purpose — it's a realistic example of the kind of naming collision that shows up provisioning real accounts at scale, which is exactly why it's worth documenting rather than smoothing over.
