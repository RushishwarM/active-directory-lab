param(
    [Parameter(Mandatory=$true)]
    [string]$Username
)

$logFile = "C:\Lab\deprovision-log.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$user = Get-ADUser -Filter "SamAccountName -eq '$Username'" -Properties MemberOf
if (-not $user) {
    Write-Host "User $Username not found" -ForegroundColor Red
    exit 1
}

try {
    Disable-ADAccount -Identity $user -ErrorAction Stop

    foreach ($groupDN in $user.MemberOf) {
        Remove-ADGroupMember -Identity $groupDN -Members $user -Confirm:$false -ErrorAction Stop
    }

    Move-ADObject -Identity $user.DistinguishedName -TargetPath "OU=Disabled Users,DC=lab,DC=local" -ErrorAction Stop

    Add-Content $logFile "$timestamp - Disabled $Username, removed from $($user.MemberOf.Count) group(s), moved to Disabled Users"
    Write-Host "Deprovisioned $Username" -ForegroundColor Green
}
catch {
    Add-Content $logFile "$timestamp - FAILED for $Username : $($_.Exception.Message)"
    Write-Host "Failed to deprovision $Username : $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
