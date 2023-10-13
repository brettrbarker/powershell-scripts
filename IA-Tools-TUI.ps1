# Load the Compare-CSV.ps1 script
. .\Compare-CSV.ps1

# Load the Format-SoftwareList.ps1 script
. .\Format-SoftwareList.ps1

# Load the User Export script
. .\Export-Users.ps1



## LOAD MAIN MENU
while ($true) {
    # Print Menu
    Write-Host "##### IA TOOLS #####" -ForegroundColor Green
    Write-Host "1. Export Active Directory Data"
    Write-Host "2. Format Software List"
    Write-Host "3. "
    Write-Host "..."
    Write-Host "8. Run Comparison"
    Write-Host "9. Change Export Location"
    Write-Host "0. Exit"

    # Prompt user to select 1, 2, or 0 for Export Regular users, Privileged users, or Exit.
    $selection = Read-Host "Selection"

    # If user selects 1, execute Export-Users.ps1
    if ($selection -eq 1) {
        Export-ADData
    }
    elseif ($selection -eq 2) {
        Enter-SoftwareMenu
    }

    elseif ($selection -eq 0) {
        break
    }

}