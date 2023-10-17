# Tite: AD User Export Script
# Author: Brett Barker
# Date: 17 October 2023
# CHANGES:
# 2023-10-16 - specific ad-user fields added; porting other changes.
# 2023-10-17 - fixed dynamic OU discovery
#

# Load the Compare-CSV.ps1 script
. .\Compare-CSV.ps1



# Import Active Directory Module
Import-Module ActiveDirectory

# Handle errors if module import fails
if ($? -eq $false) {
    Write-Host ""
    Write-Host "Active Directory Module failed to import!" -ForegroundColor Red
    Write-Host "Please install the Active Directory Module and try again."
    $adImportError = $true
    Start-Sleep -s 3
}

## SET VARIABLES
# Set default file export location variable
$global:exportLocation = "$HOME\Downloads"
$exportLocationALT = "I:\" +  $(Get-Date -f yyyy)
$exportFileNameRegular = "RegularUsers-$(Get-Date -f yyyymmdd).csv"
$exportFileNamePrivileged = "PrivilegedUsers-$(Get-Date -f yyyymmdd).csv"
$exportFileNameService = "ServiceAccounts-$(Get-Date -f yyyymmdd).csv"

# Set the filter to search for your regular user, privileged, and service account OUs
$OURegular = Get-ADOrganizationalUnit -Filter 'Name -like "01-Users"' | Select-Object -ExpandProperty "DistinguishedName" 
$OUPrivileged = Get-ADOrganizationalUnit -Filter 'Name -like "02-Privileged*"' | Select-Object -ExpandProperty "DistinguishedName"
$OUService = Get-ADOrganizationalUnit -Filter 'Name -like "*Service-Accounts*"' | Select-Object -ExpandProperty "DistinguishedName"


# Declare a sub-function that will check if the export location exists
function Test-ExportLocation {
    # If the export location does not exist, show and error message
    if (!(Test-Path $exportLocation)) {
        Write-Host "Export location ($exportLocation) does not exist!" -ForegroundColor Red
        Write-Host "Please create the export location or select a new location."
        Start-Sleep -s 3
        return $false
    }
    return $true
}

function Edit-WorkingDirectory {
                # while locationStatus is false, prompt user to enter new export location
                $locationStatus = $false
                while ($locationStatus -eq $false) {
                    $origExportLocation = $exportLocation
                    $newExportLocation = Read-Host "Enter new working directory location or '1' for $exportLocationALT"
                    if ($newExportLocation -eq "1") {
                        $global:exportLocation = $exportLocationALT
                        $locationStatus = Test-ExportLocation
                        if ($locationStatus -eq $false) {
                            $global:exportLocation = $origExportLocation
                        }
                    }
                    elseif ($newExportLocation -eq "") {
                        break
                    }
                    else {
                        $global:exportLocation = $newExportLocation
                    }
                    $locationStatus = Test-ExportLocation
                }
                Write-Host "Working Directory: $exportLocation"
                Start-Sleep -s 2
}
function Export-ADData{
    # Create While True Loop to Print Menu unless user selects 0 to exit
    while ($true) {
        # Print Menu
        Write-Host "##### AD Export Script #####" -ForegroundColor Green
        if ($adImportError -eq $true) {
            Write-Host "ERROR: Active Directory Module failed to import!" -ForegroundColor Red
        }
        Write-Host "##### Working Directory: " -NoNewline -ForegroundColor Green
        Write-Host "$exportLocation" -ForegroundColor Red    
        Write-Host "1. Export List of All Regular User Accounts"
        Write-Host "2. Export List of All Privileged User Accounts"
        Write-Host "3. Export List of All Service Accounts"
        Write-Host "4. Print Accounts Created in Last X Days"
        Write-Host "5. Compare Previous Exported Lists"
        Write-Host "..."
        Write-Host "9. Change Working Directory"
        Write-Host "0. Exit"

        # Prompt user for selection.
        $selection = Read-Host "Selection"

        # If user selects 1, print "Exporting Regular Users List"
        if ($selection -eq 1) {
            $locationStatus = Test-ExportLocation
            if ($locationStatus -eq $true) {
                Write-Host "Exporting Regular Users List"
                # Execute Get-ADUser command to export Regular Users List
                Get-ADUser -Properties *,msDS-UserPasswordExpiryTimeComputed -Filter * -SearchBase $OURegular | Select-Object Surname, GivenName, displayname, SamAccountName, @{n='OU' ;e={$_.DistinguishedName.split(',')|Where-Object {$_.Startswith("OU=")}|ForEach-Object{$_.split("=")[1]}|Select-Object -first 1}}, Enabled, LastLogonDate, Created, PasswordLastSet, PasswordNeverExpires, @{Name="PasswordExpiryDate"; Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, Description | Export-Csv -Path "$exportLocation/$exportFileNameRegular" -NoTypeInformation
                #Get-ADUser -Filter * -Properties * | Select-Object Name, SamAccountName, DistinguishedName, Enabled | Export-Csv -Path "$exportLocation\$exportFileNameRegular"-NoTypeInformation
                Write-Host "Export Complete"
                Start-Sleep -s 2
                Clear-Host
            }
        }

        # If user selects 2, print "Exporting Privileged Users List"
        elseif ($selection -eq 2) {
            $locationStatus = Test-ExportLocation
                if ($locationStatus -eq $true) {
                Write-Host "Exporting Privileged Users List"

                # Execute Get-ADUser command to export Privileged Users List
                Get-ADUser -Properties *,msDS-UserPasswordExpiryTimeComputed -Filter * -SearchBase $OUPrivileged | Select-Object Surname, GivenName, displayname, SamAccountName, @{n='OU' ;e={$_.DistinguishedName.split(',')|Where-Object {$_.Startswith("OU=")}|ForEach-Object{$_.split("=")[1]}|Select-Object -first 2}}, Enabled, LastLogonDate, Created, PasswordLastSet, PasswordNeverExpires, @{Name="PasswordExpiryDate"; Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, Description | Export-Csv -Path "$exportLocation/$exportFileNamePrivileged" -NoTypeInformation
                #Get-ADUser -Filter * -Properties * | Select-Object Name, SamAccountName, DistinguishedName, Enabled | Export-Csv -Path "$exportLocation\$exportFileNamePrivileged"-NoTypeInformation
                Write-Host "Export Complete"
                Start-Sleep -s 2
                Clear-Host
                }
        }

        # If user selects 3, print "Exporting Service Accounts List"
        elseif ($selection -eq 3) {
            $locationStatus = Test-ExportLocation
                if ($locationStatus -eq $true) {
                Write-Host "Exporting Service Account List"

                # Execute Get-ADUser command to export Service Account
                Get-ADUser -Properties *,msDS-UserPasswordExpiryTimeComputed -Filter * -SearchBase $OUService | Select-Object SamAccountName, @{n='OU' ;e={$_.DistinguishedName.split(',')|Where-Object {$_.Startswith("OU=")}|ForEach-Object{$_.split("=")[1]}|Select-Object -first 1}}, Enabled, LastLogonDate, Created, PasswordLastSet, PasswordNeverExpires, @{Name="PasswordExpiryDate"; Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, Description | Export-Csv -Path "$exportLocation/$exportFileNameService" -NoTypeInformation
                Write-Host "Export Complete"
                Start-Sleep -s 2
                Clear-Host
                }
        }
        # If user selects 4, print User list where "Created" date is X days or less
        elseif ($selection -eq 4) {
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
                        Clear-Host
                    }
                }
            }

            Write-Host "Printing Accounts Created in the Last $days Days"

            # Execute Get-ADUser command to show users created in the last 7 days

            # Get current date
            $currentDate = Get-Date
            
            # Get date 7 days ago
            $dateXDaysAgo = $currentDate.AddDays(-$days)
            # Execute Get-ADUser command to show users created in the last X days
            Get-ADUser -Properties *,msDS-UserPasswordExpiryTimeComputed -Filter * -SearchBase $OURegular | Select-Object Surname, GivenName, displayname, SamAccountName, @{n='OU' ;e={$_.DistinguishedName.split(',')|Where-Object {$_.Startswith("OU=")}|ForEach-Object{$_.split("=")[1]}|Select-Object -first 1}}, Enabled, LastLogonDate, Created, PasswordLastSet, PasswordNeverExpires, @{Name="PasswordExpiryDate"; Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, Description | Where-Object {$_.Created -ge $dateXDaysAgo}
            Get-ADUser -Properties *,msDS-UserPasswordExpiryTimeComputed -Filter * -SearchBase $OUPrivileged | Select-Object Surname, GivenName, displayname, SamAccountName, @{n='OU' ;e={$_.DistinguishedName.split(',')|Where-Object {$_.Startswith("OU=")}|ForEach-Object{$_.split("=")[1]}|Select-Object -first 2}}, Enabled, LastLogonDate, Created, PasswordLastSet, PasswordNeverExpires, @{Name="PasswordExpiryDate"; Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, Description | Where-Object {$_.Created -ge $dateXDaysAgo}
            Get-ADUser -Properties *,msDS-UserPasswordExpiryTimeComputed -Filter * -SearchBase $OUService | Select-Object SamAccountName, @{n='OU' ;e={$_.DistinguishedName.split(',')|Where-Object {$_.Startswith("OU=")}|ForEach-Object{$_.split("=")[1]}|Select-Object -first 1}}, Enabled, LastLogonDate, Created, PasswordLastSet, PasswordNeverExpires, @{Name="PasswordExpiryDate"; Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, Description | Where-Object {$_.Created -ge $dateXDaysAgo}
            
            Write-Host ""
            pause

        }

        # If user selects 5, run Compare-CSV.ps1 script with CSV1 and CSV2 as parameters. These should be the last two files named like "RegularUsers-$(Get-Date -f yyyymmdd).csv"
        elseif ($selection -eq 5) {
            $locationStatus = Test-ExportLocation
            if ($locationStatus -eq $true) {
                # Prompt user "Which set of files do you want to compare?"
                Write-Host "Which set of files do you want to compare?"
                Write-Host "1. Last two Regular Users"
                Write-Host "2. Last two Privileged Users"
                Write-Host "3. Last two Service Accounts"
                Write-Host "4. Manual Selection"
                Write-Host "0. Cancel and Go Back"
                $selection = Read-Host "Selection"

                # If user selects 1, set $filter to "RegularUsers-*.csv"
                if ($selection -eq 1) {
                    $filter = "RegularUsers-*.csv"
                }
                elseif ($selection -eq 2) {
                    $filter = "PrivilegedUsers-*.csv"
                }
                elseif ($selection -eq 3) {
                    $filter = "ServiceAccounts-*.csv"
                }
                elseif ($selection -eq 4) {
                    $filter = $null
                    # Prompt user to enter CSV1 and CSV2 file names
                    $csv1 = Read-Host "Enter CSV1 file name"
                    $csv2 = Read-Host "Enter CSV2 file name"
                    if ($csv1 -eq $csv2) {
                        Write-Host "CSV1 and CSV2 cannot be the same file"
                        Start-Sleep -s 1
                        Clear-Host
                        continue
                    }
                    $csv1 = Get-ChildItem -Path $exportLocation -Filter $csv1
                    $csv2 = Get-ChildItem -Path $exportLocation -Filter $csv2
                    if ($null -eq $csv1 -or $null -eq $csv2) {
                        Write-Host "CSV1 or CSV2 not found"
                        Start-Sleep -s 1
                        Clear-Host
                        continue
                    }
                    
                }
                elseif ($selection -eq 0) {
                    continue
                }
                else {
                    Write-Host "Invalid Selection"
                    Start-Sleep -s 1
                    Clear-Host
                    continue
                }
                if ($null -ne $filter) {
                    Write-Host "Filter: $filter"
                    # Get the last two files in the export location that match the filter
                    $csvFiles = Get-ChildItem -Path $exportLocation -Filter $filter | Where-Object { $_.Name -notlike "*comparison*" } | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 2
                    $csv1 = $csvFiles[0]
                    $csv2 = $csvFiles[1]
                }

                if ($null -eq $csv1 -or $null -eq $csv2) {
                    Write-Host "No CSV files found"
                    Start-Sleep -s 2
                    Clear-Host
                    continue
                }

                Write-Host "CSV1: $($csv1.FullName)"
                Write-Host "CSV2: $($csv2.FullName)"
                # Prompt to confirm
                $confirm = Read-Host "Confirm comparison (y/n)"
                if ($confirm -ne "y") {
                    Write-Host "Comparison cancelled"
                    Start-Sleep -s 2
                    Clear-Host
                    continue
                }

                # Execute Compare-CSV.ps1 script with CSV1 and CSV2 as parameters
                Compare-CSV -Csv1Path $csv1.FullName -Csv2Path $csv2.FullName -ComparisonColumn SamAccountName
                Write-Host "Comparison Complete"
                Start-Sleep -s 3
                Clear-Host
            }
        }

        # If user selects 9, prompt user to enter new export location
        elseif ($selection -eq 9) {
            Edit-WorkingDirectory
        }

        # If user selects 0, print "Exiting"
        elseif ($selection -eq 0) {
            exit
        }

        # If user selects anything else, print "Invalid Selection"
        else {
            Write-Host "Invalid Selection"
            Start-Sleep -s 1
        }
    }
}

# Call Export-ADData function if the script is run directly either by relative or absolute path
if ($MyInvocation.InvocationName -eq ".\Export-Users.ps1" -or $MyInvocation.InvocationName -eq $ScriptPath) {
    Export-ADData
}
Export-ADData