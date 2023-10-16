# Tite: AD User Export Script
# Author: Brett Barker
# Date: 16 October 2023
# CHANGES:
# 2023-10-16 - specific ad-user fields added; porting other changes.
#
#



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

# Set default file export location variable

$exportLocation = "$HOME\Downloads"
$exportLocationALT = "I:\" +  $(Get-Date -f yyyy)
$exportFileNameRegular = "RegularUsers-$(Get-Date -f yyyymmdd).csv"
$exportFileNamePrivileged = "PrivilegedUsers-$(Get-Date -f yyyymmdd).csv"
$exportFileNameService = "ServiceAccounts-$(Get-Date -f yyyymmdd).csv"
$OURegular = Get-ADOrganizationalUnit -Filter 'Name -like "01-Users"' | Select-Object -ExpandProperty "DistinguishedName" | Out-String
$OUPrivileged = Get-ADOrganizationalUnit -Filter 'Name -like "02-Privileged*"' | Select-Object -ExpandProperty "DistinguishedName" | Out-String
$OUService = Get-ADOrganizationalUnit -Filter 'Name -like "*Service-Accounts*"' | Select-Object -ExpandProperty "DistinguishedName" | Out-String

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

function Export-ADData{
    # Create While True Loop to Print Menu unless user selects 0 to exit
    while ($true) {
        # Print Menu
        Write-Host "##### AD Export Script #####" -ForegroundColor Green
        if ($adImportError -eq $true) {
            Write-Host "ERROR: Active Directory Module failed to import!" -ForegroundColor Red
        }
        Write-Host "##### Exporting to: " -NoNewline -ForegroundColor Green
        Write-Host "$exportLocation" -ForegroundColor Red    
        Write-Host "1. Export All Regular Users List"
        Write-Host "2. Export All Privileged Users List"
        Write-Host "3. Export All Service Accounts List"
        Write-Host "4. Print Users Created in Last X Days"
        Write-Host "..."
        Write-Host "8. Run Comparison"
        Write-Host "9. Change Export Location"
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
        # If user selects 3, print User list where "Created" date is X days or less
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

            Write-Host "Printing Users Created in the Last $days Days"

            # Execute Get-ADUser command to show users created in the last 7 days

            # Get current date
            $currentDate = Get-Date
            
            # Get date 7 days ago
            $dateXDaysAgo = $currentDate.AddDays(-$days)
            Write-Host $OUPrivileged
            # Execute Get-ADUser command to show users created in the last X days
            Get-ADUser -Properties *,msDS-UserPasswordExpiryTimeComputed -Filter * -SearchBase $OURegular | Select-Object Surname, GivenName, displayname, SamAccountName, @{n='OU' ;e={$_.DistinguishedName.split(',')|Where-Object {$_.Startswith("OU=")}|ForEach-Object{$_.split("=")[1]}|Select-Object -first 1}}, Enabled, LastLogonDate, Created, PasswordLastSet, PasswordNeverExpires, @{Name="PasswordExpiryDate"; Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, Description | Where-Object {$_.whenCreated -ge $dateXDaysAgo}
            #Get-ADUser -Properties *,msDS-UserPasswordExpiryTimeComputed -Filter * -SearchBase $OUPrivileged | Select-Object Surname, GivenName, displayname, SamAccountName, @{n='OU' ;e={$_.DistinguishedName.split(',')|Where-Object {$_.Startswith("OU=")}|ForEach-Object{$_.split("=")[1]}|Select-Object -first 2}}, Enabled, LastLogonDate, Created, PasswordLastSet, PasswordNeverExpires, @{Name="PasswordExpiryDate"; Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, Description | Where-Object {$_.whenCreated -ge $dateXDaysAgo}
            #Get-ADUser -Properties *,msDS-UserPasswordExpiryTimeComputed -Filter * -SearchBase $OUService | Select-Object SamAccountName, @{n='OU' ;e={$_.DistinguishedName.split(',')|Where-Object {$_.Startswith("OU=")}|ForEach-Object{$_.split("=")[1]}|Select-Object -first 1}}, Enabled, LastLogonDate, Created, PasswordLastSet, PasswordNeverExpires, @{Name="PasswordExpiryDate"; Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}, Description | Where-Object {$_.whenCreated -ge $dateXDaysAgo}
            #Get-ADUser -Filter * -Properties * -SearchBase $OURegular | Where-Object {$_.whenCreated -ge $dateXDaysAgo} | Select-Object Name, SamAccountName, DistinguishedName, Enabled 
            Write-Host ""
            pause

        }

        # If user selects 8, run Compare-CSV.ps1 script with CSV1 and CSV2 as parameters. These should be the last two files named like "RegularUsers-$(Get-Date -f yyyymmdd).csv"
        elseif ($selection -eq 8) {
            $locationStatus = Test-ExportLocation
            if ($locationStatus -eq $true) {
                Write-Host "Running Comparison"

                # Get the last two files named like "RegularUsers-$(Get-Date -f yyyymmdd).csv"
                $csvFiles = Get-ChildItem -Path $exportLocation -Filter "*.csv" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 2
                $csv1 = $csvFiles[0]
                $csv2 = $csvFiles[1]

                # Execute Compare-CSV.ps1 script with CSV1 and CSV2 as parameters
                .\Compare-CSV.ps1 -Csv1Path $csv1.FullName -Csv2Path $csv2.FullName -ComparisonColumn SamAccountName -OutputPath $exportLocation
                Write-Host "Comparison Complete"
                Start-Sleep -s 3
                Clear-Host
            }
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
            break
        }

        # If user selects anything other than 1, 2, or 0, print "Invalid Selection"
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
