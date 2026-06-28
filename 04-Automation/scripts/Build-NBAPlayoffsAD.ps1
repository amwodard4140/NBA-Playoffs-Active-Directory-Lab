#Requires -Module ActiveDirectory
<#
.SYNOPSIS
    Builds an NBA-themed Active Directory OU structure and populates it with the
    2025-26 NBA Playoffs teams and rosters.

.DESCRIPTION
    Creates: NBA > Eastern Conference / Western Conference > one OU per team,
    then reads NBA_Playoffs_2026_Roster.csv and creates one AD user per player
    in the correct Team OU, using the pre-computed LogonName column as the
    SamAccountName.

.PARAMETER DomainDN
    The distinguishedName suffix for your domain, e.g. "DC=nba,DC=local".

.PARAMETER CsvPath
    Path to the roster CSV. Defaults to a file in the same folder as this script.

.PARAMETER DefaultPassword
    Temporary password assigned to every created account. Change before use
    outside an isolated lab.

.PARAMETER ProtectOUs
    If set, created OUs are protected from accidental deletion. Off by default.

.EXAMPLE
    .\Build-NBAPlayoffsAD.ps1 -DomainDN "DC=nba,DC=local"
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$DomainDN,

    [string]$CsvPath = (Join-Path $PSScriptRoot "NBA_Playoffs_2026_Roster.csv"),

    [string]$DefaultPassword = "ChangeMe!2026",

    [switch]$ProtectOUs
)

Import-Module ActiveDirectory -ErrorAction Stop

$SecurePassword = ConvertTo-SecureString $DefaultPassword -AsPlainText -Force

# ---------------------------------------------------------------------------
# 1. Load the roster data
# ---------------------------------------------------------------------------
if (-not (Test-Path $CsvPath)) {
    throw "Roster CSV not found at '$CsvPath'. Pass -CsvPath explicitly if it's elsewhere."
}

$roster = Import-Csv -Path $CsvPath
Write-Host "Loaded $($roster.Count) players from $CsvPath" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 2. Create the top-level NBA OU
# ---------------------------------------------------------------------------
function New-OUIfMissing {
    param(
        [string]$Name,
        [string]$ParentDN
    )
    $ouDN = "OU=$Name,$ParentDN"
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouDN'" -ErrorAction SilentlyContinue)) {
        Write-Host "Creating OU: $ouDN" -ForegroundColor Yellow
        New-ADOrganizationalUnit -Name $Name -Path $ParentDN -ProtectedFromAccidentalDeletion:$ProtectOUs.IsPresent
    }
    else {
        Write-Host "OU already exists: $ouDN" -ForegroundColor DarkGray
    }
    return $ouDN
}

$nbaOU = New-OUIfMissing -Name "NBA" -ParentDN $DomainDN

# ---------------------------------------------------------------------------
# 3. Create the two Conference OUs
# ---------------------------------------------------------------------------
$conferences = $roster.Conference | Sort-Object -Unique
$conferenceOUs = @{}
foreach ($conf in $conferences) {
    $conferenceOUs[$conf] = New-OUIfMissing -Name $conf -ParentDN $nbaOU
}

# ---------------------------------------------------------------------------
# 4. Create a Team OU under the correct Conference for every team in the data
# ---------------------------------------------------------------------------
$teamOUs = @{}
$teamLookup = $roster | Select-Object Conference, Team -Unique
foreach ($entry in $teamLookup) {
    $parentOU = $conferenceOUs[$entry.Conference]
    $teamOUs[$entry.Team] = New-OUIfMissing -Name $entry.Team -ParentDN $parentOU
}

# ---------------------------------------------------------------------------
# 5. Create a user for every player, using the CSV's LogonName as SamAccountName
# ---------------------------------------------------------------------------
$created = 0
$skipped = 0

foreach ($player in $roster) {

    $sam = $player.LogonName
    $displayName = $player.Name
    $teamOU = $teamOUs[$player.Team]
    $upn = "$sam@$($DomainDN -replace 'DC=','' -replace ',','.')"

    # Split "Name" into GivenName/Surname at the first space, for basic AD hygiene
    $nameParts = $displayName -split ' ', 2
    $givenName = $nameParts[0]
    $surname = if ($nameParts.Count -gt 1) { $nameParts[1] } else { '' }

    if (Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue) {
        Write-Host "Skipping existing user: $displayName ($sam)" -ForegroundColor DarkGray
        $skipped++
        continue
    }

    try {
        New-ADUser `
            -Name $displayName `
            -GivenName $givenName `
            -Surname $surname `
            -DisplayName $displayName `
            -SamAccountName $sam `
            -UserPrincipalName $upn `
            -Path $teamOU `
            -AccountPassword $SecurePassword `
            -ChangePasswordAtLogon $true `
            -Enabled $true `
            -ErrorAction Stop

        Write-Host "Created: $displayName ($sam) -> $teamOU" -ForegroundColor Green
        $created++
    }
    catch {
        Write-Warning "Failed to create $displayName ($sam): $($_.Exception.Message)"
    }
}

# ---------------------------------------------------------------------------
# 6. Summary
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " NBA Playoffs AD Lab Build Complete"      -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Teams provisioned : $($teamOUs.Count)"
Write-Host "Users created     : $created"
Write-Host "Users skipped     : $skipped (already existed)"
Write-Host "Default password  : $DefaultPassword  (change at next logon enforced)"
