$users = Import-Csv "C:\Lab\users.csv"
$password = Read-Host "Enter a temporary password for the new users" -AsSecureString

foreach ($u in $users) {
    $name = "$($u.FirstName) $($u.LastName)"
    $ou = "OU=$($u.Department),DC=lab,DC=local"

    if (Get-ADUser -Filter "SamAccountName -eq '$($u.Username)'") {
        Write-Host "Skipping $($u.Username): already exists" -ForegroundColor Yellow
        continue
    }

    New-ADUser -Name $name -GivenName $u.FirstName -Surname $u.LastName `
        -SamAccountName $u.Username -UserPrincipalName "$($u.Username)@lab.local" `
        -Path $ou -AccountPassword $password -Enabled $true -ChangePasswordAtLogon $true

    Add-ADGroupMember -Identity "$($u.Department)-Staff" -Members $u.Username
    Write-Host "Created $name in $($u.Department)" -ForegroundColor Green
}
