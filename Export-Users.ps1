# Tite: AD User Export Script
# Author: Brett Barker
# Date: 29 August 2023

# Import Active Directory Module
Import-Module ActiveDirectory

# Set default file export location variable
$exportLocation = "C:\Users\Public\Documents\"

# Create While True Loop to Print Menu unless user selects 0 to exit
while ($true) {
    # Print Menu
    Write-Host "##### User Export Script #####" -ForegroundColor Green
    # Print "Exporting to $exportLocation"
    Write-Host "##### Exporting to: " -NoNewline -ForegroundColor Green
    Write-Host "$exportLocation" -ForegroundColor Red    
    Write-Host "1. Export Regular Users List"
    Write-Host "2. Export Privileged Users List"
    Write-Host "3. Export All Users List"
    Write-Host "..."
    Write-Host "9. Change Export Location"
    Write-Host "0. Exit"

    # Prompt user to select 1, 2, or 0 for Export Regular users, Privileged users, or Exit.
    $selection = Read-Host "Select 1, 2, or 0"

    # If user selects 1, print "Exporting Regular Users List"
    if ($selection -eq 1) {
        Write-Host "Exporting Regular Users List"
        Get-ADUser -Filter * -Properties * | Select-Object Name, SamAccountName, DistinguishedName, Enabled
        Write-Host "Export Complete"
        Start-Sleep -s 3
        clear
    }

    # If user selects 2, print "Exporting Privileged Users List"
    elseif ($selection -eq 2) {
        Write-Host "Exporting Privileged Users List"
        Get-ADUser -Filter * -Properties * | Select-Object Name, SamAccountName, DistinguishedName, Enabled
        Write-Host "Export Complete"
        Start-Sleep -s 3
        clear
    }

    # If user selects 3, print "Exporting All Users List"
    elseif ($selection -eq 3) {
        Write-Host "Exporting All Users List"
        Get-ADUser -Filter * -Properties * | Select-Object Name, SamAccountName, DistinguishedName, Enabled
        Write-Host "Export Complete"
        Start-Sleep -s 3
        clear
    }

    # If user selects 9, prompt user to enter new export location
    elseif ($selection -eq 9) {
        $exportLocation = Read-Host "Enter new export location"
        Write-Host "Exporting to $exportLocation"
    }

    # If user selects 0, print "Exiting"
    elseif ($selection -eq 0) {
        Write-Host "Exiting"
        break
    }

    # If user selects anything other than 1, 2, or 0, print "Invalid Selection"
    else {
        Write-Host "Invalid Selection"
    }
}
