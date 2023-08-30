# Tite: AD User Export Script
# Author: Brett Barker
# Date: 29 August 2023

# Import Active Directory Module
Import-Module ActiveDirectory

# Handle errors if module import fails
if ($? -eq $false) {
    Write-Host "Active Directory Module failed to import!" -ForegroundColor Red
    Write-Host "Please install the Active Directory Module and try again."
    Start-Sleep -s 3
    exit
}

# Set default file export location variable

$exportLocation = "$HOME\Downloads"
$exportLocationALT = "I:\" +  $(Get-Date -f yyyy)
$exportFileNameRegular = "RegularUsers-$(Get-Date -f yyyymmdd).csv"
$exportFileNamePrivileged = "PrivilegedUsers-$(Get-Date -f yyyymmdd).csv"

# Declare a sub-function that will check if the export location exists
function Check-ExportLocation {
    # If the export location does not exist, show and error message
    if (!(Test-Path $exportLocation)) {
        Write-Host "Export location ($exportLocation) does not exist!" -ForegroundColor Red
        Write-Host "Please create the export location or select a new location."
        Start-Sleep -s 3
        return $false
    }
    return $true
}


# Create While True Loop to Print Menu unless user selects 0 to exit
while ($true) {
    # Print Menu
    Write-Host "##### User Export Script #####" -ForegroundColor Green
    # Print "Exporting to $exportLocation"
    Write-Host "##### Exporting to: " -NoNewline -ForegroundColor Green
    Write-Host "$exportLocation" -ForegroundColor Red    
    Write-Host "1. Export All Regular Users List"
    Write-Host "2. Export All Privileged Users List"
    Write-Host "3. Print Users Created in Last X Days"
    Write-Host "..."
    Write-Host "9. Change Export Location"
    Write-Host "0. Exit"

    # Prompt user to select 1, 2, or 0 for Export Regular users, Privileged users, or Exit.
    $selection = Read-Host "Selection"

    # If user selects 1, print "Exporting Regular Users List"
    if ($selection -eq 1) {
        $locationStatus = Check-ExportLocation
        if ($locationStatus -eq $true) {
            Write-Host "Exporting Regular Users List"

            # Execute Get-ADUser command to export Regular Users List
            Get-ADUser -Filter * -Properties * | Select-Object Name, SamAccountName, DistinguishedName, Enabled | Export-Csv -Path "$exportLocation\$exportFileNameRegular"-NoTypeInformation
            Write-Host "Export Complete"
            Start-Sleep -s 3
            clear
        }
    }

    # If user selects 2, print "Exporting Privileged Users List"
    elseif ($selection -eq 2) {
        $locationStatus = Check-ExportLocation
            if ($locationStatus -eq $true) {
            Write-Host "Exporting Privileged Users List"

            # Execute Get-ADUser command to export Privileged Users List
            Get-ADUser -Filter * -Properties * | Select-Object Name, SamAccountName, DistinguishedName, Enabled | Export-Csv -Path "$exportLocation\$exportFileNamePrivileged"-NoTypeInformation
            Write-Host "Export Complete"
            Start-Sleep -s 3
            clear
            }
    }

    # If user selects 3, print User list where "Created" date is X days or less
    elseif ($selection -eq 3) {
        $days = ""
        while ($days -isnot [int]) {
            # Prompt User to enter number of days
            $days = Read-Host "Enter number of days"
            try {
                $days = [int]$days   
            }
            catch {
                # Test if $days is an integer
                if ($days -isnot [int]) {
                    Write-Host "Invalid number of days"
                    Start-Sleep -s 1
                    clear
                }
            }
        }

        Write-Host "Printing Users Created in the Last $days Days"

        # Execute Get-ADUser command to show users created in the last 7 days

        # Get current date
        $currentDate = Get-Date

        # Get date 7 days ago
        $dateXDaysAgo = $currentDate.AddDays(-$days)

        # Execute Get-ADUser command to show users created in the last X days
        Get-ADUser -Filter * -Properties * | Where-Object {$_.whenCreated -ge $dateXDaysAgo} | Select-Object Name, SamAccountName, DistinguishedName, Enabled 
        Write-Host ""
        pause

    }

    # If user selects 9, prompt user to enter new export location
    elseif ($selection -eq 9) {
        $exportLocation = Read-Host "Enter new export location or '1' for $exportLocationALT"
        if ($exportLocation -eq "1") {
            $exportLocation = $exportLocationALT
        }
        Write-Host "Exporting to $exportLocation"
    }

    # If user selects 0, print "Exiting"
    elseif ($selection -eq 0) {
        Write-Host "Exiting..."
        Start-Sleep -s 1
        exit
    }

    # If user selects anything other than 1, 2, or 0, print "Invalid Selection"
    else {
        Write-Host "Invalid Selection"
        Start-Sleep -s 1
    }
}
