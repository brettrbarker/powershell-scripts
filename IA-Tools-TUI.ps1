# Load the Format-SoftwareList.ps1 script
. .\Format-SoftwareList.ps1

# Load the User Export script
. .\Export-Users.ps1



function Show-Header {
    Write-Host "##### IA TOOLS #####" -ForegroundColor Green
    Write-Host "##### Working Directory: " -NoNewline -ForegroundColor Green
    Write-Host "$exportLocation" -ForegroundColor Red   
}
function Enter-MainMenu {
    while ($true) {
        # Print Menu
        Show-Header   
        Write-Host "1. Active Directory Tools"
        Write-Host "2. Software List Tools"
        Write-Host "..."
        Write-Host "9. Change Working Directory"
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
        elseif ($selection -eq 3) {
            # Enter-SoftwareMenu
        }
        elseif ($selection -eq 8) {
            # Compare-CSV
        }
        elseif ($selection -eq 9) {
            Edit-WorkingDirectory
        }
        elseif ($selection -eq 0) {
            break
        }
    }
}

Enter-MainMenu