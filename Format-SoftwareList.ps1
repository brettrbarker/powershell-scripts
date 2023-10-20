################################################
# Security Center Software List Formatter
# Author: Brett Barker
# Date: 2023-09-01
# Description: This script takes the output of the Security Center Software List, cleans it up, and formats with a version number column.
# Usage: ./Format-SoftwareList.ps1
# Usage: ./Format-SoftwareList.ps1 -SoftwareListPath "./test-data/software1.csv"
# Usage: ./Format-SoftwareList.ps1 -SoftwareListPath "./test-data/software1.csv" -OutputPath "./test-data/software1-formatted.csv"
# Original CSV format: "Software","Count","Detection Method"
################################################

# Load the ia-tools-support-functions.ps1 script
. .\ia-tools-support-functions.ps1

function Enter-SoftwareMenu {
    param (
        [Parameter(Mandatory=$false)]
        [string]$workingDirectory
    )

    # If $workingDirectory is null, set it to the user's download folder
    if(!$workingDirectory){
        $workingDirectory = "$HOME\Downloads"
    }


    while ($true) {
        # Print Menu
        Show-Header
        Write-Host "##### SOFTWARE MENU #####" -ForegroundColor Green
        Write-Host "1. Format Software List"
        Write-Host "2. Compare Software Lists"
        Write-Host "0. Exit"
    
        # Prompt user to select 1, 2, or 0 for Export Regular users, Privileged users, or Exit.
        $selection = Read-Host "Selection"
    
        # If user selects 1, execute Format-SoftwareList.ps1
        if ($selection -eq 1) {
            # Prompt user to enter the path to the software list CSV file
            $SoftwareListPath = Read-Host "Enter the path to the software list CSV file"
            # Check if the CSV file exists
            if(!(Test-Path $SoftwareListPath)){
                Write-Host "Error: $SoftwareListPath does not exist!"
                Start-Sleep -s 3
                Clear-Host
                continue
            }
            # Prompt user to enter the path to the output CSV file or leave blank to use the default path
            $OutputPath = Read-Host "Enter the path to the output CSV file or leave blank to use the default path"
            # Check if the Output path exists
            if($OutputPath -and !(Test-Path $OutputPath)){
                Write-Host "Error: $OutputPath does not exist!"
                Start-Sleep -s 3
                Clear-Host
                continue
            }
            # Execute Format-SoftwareList.ps1 use output path if provided
            if($OutputPath){
                Format-SoftwareList -SoftwareListPath $SoftwareListPath -OutputPath $OutputPath
            }
            # Execute Format-SoftwareList.ps1 use default output path if not provided
            else {
            Format-SoftwareList -SoftwareListPath $SoftwareListPath
            }
        }
        # If user selects 2, execute Compare-CSV.ps1
        elseif ($selection -eq 2) {
            Clear-Host
            $csv1Path = $null
            $csv2Path = $null
            Show-Header
            Write-Host "##### COMPARE SOFTWARE LISTS #####" -ForegroundColor Green
            # Get list of CSV files in the current working directory
            $csvFiles = Get-ChildItem -Path $workingDirectory -Filter *.csv | Where-Object { $_.Name -imatch "software" } | Sort-Object -Property LastWriteTime -Descending | Select-Object -Property Name,LastWriteTime
            
            # Print list of first 6 CSV files in the current working directory with a number for each file
            $csvFiles | Select-Object -First 6 | ForEach-Object -Begin { $i = 1 } -Process { Write-Host "$i. $($_.Name)"; $i++ }
            Write-Host "9. Enter a custom path to a CSV file"
            Write-Host "0. Cancel  and Go Back"
            $selection1 = Read-Host "Select the first (oldest) CSV file to compare"
            # Check if the selection is a number
            if(!(Check-Number $selection1)){
                Clear-Host
                Write-Host "Error: $selection1 is not a number!"
                Start-Sleep -s 3
                continue
            }
            if ($selection1 -eq 9) {
                # Prompt user to enter CSV1 and CSV2 file names
                $csv1 = Read-Host "Enter CSV1 file name (oldest file)"
                $csv2 = Read-Host "Enter CSV2 file name (newest file)"
                if ($csv1 -eq $csv2) {
                    Write-Host "CSV1 and CSV2 cannot be the same file"
                    Start-Sleep -s 1
                    Clear-Host
                    continue
                }
                $csv1Path = Get-ChildItem -Path $exportLocation -Filter "*$csv1*" | Where-Object { $_.Name -notlike "*comparison*" } | Select-Object -First 1
                $csv2Path = Get-ChildItem -Path $exportLocation -Filter "*$csv2*" | Where-Object { $_.Name -notlike "*comparison*" } | Select-Object -First 1
                if ($null -eq $csv1 -or $null -eq $csv2) {
                    Write-Host "CSV1 or CSV2 not found"
                    Start-Sleep -s 1
                    Clear-Host
                    continue
                }
            }
            elseif ($selection1 -eq 0) {
                break
            }
            if ($selection1 -ne 9) {
                # Check if the selection is a valid number
                if($selection1 -gt $csvFiles.Count){
                    Clear-Host
                    Write-Host "Error: $selection1 is not a valid number!"
                    Start-Sleep -s 3
                    continue
                }
                $selection2 = Read-Host "Select the second (newest) CSV file to compare"
                # Check if the selection is a number
                if ($selection2 -eq 0){
                    break
                }
                if(!(Check-Number $selection2)){
                    Clear-Host
                    Write-Host "Error: $selection2 is not a number!"
                    Start-Sleep -s 3
                    continue
                }
                # Check if the selection is a valid number
                if($selection2 -gt $csvFiles.Count){
                    Clear-Host
                    Write-Host "Error: $selection2 is not a valid number!"
                    Start-Sleep -s 3
                    continue
                }
                # Get the path to the first CSV file
                $Csv1Path = "$workingDirectory\$($csvFiles[$selection1-1].Name)"
                # Get the path to the second CSV file
                $Csv2Path = "$workingDirectory\$($csvFiles[$selection2-1].Name)"
            }
            # Execute Compare-CSV.ps1
            Compare-CSV -Csv1Path $Csv1Path -Csv2Path $Csv2Path -ComparisonColumn Software
        }
        
        elseif ($selection -eq 0) {
            break
        }
    }
}
function Format-SoftwareList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$SoftwareListPath,
        [Parameter(Mandatory=$false)]
        [string]$OutputPath
    )

    # Import the CSV files as arrays of objects
    $csv = Import-Csv -Path $SoftwareListPath

    # Add a new column to the CSV for the version number
    $csv = $csv | Select-Object *,@{Name='Version';Expression={($_.Software -split '\[version ')[1] -replace '\]',''}} 

    # # Remove the version number from the Software column
    $csv = $csv | Select-Object *,@{Name='SoftwareTemp';Expression={($_.Software -split '\[version ')[0] -replace '\s+$',''}}

    # Remove entire 'Software' Column
    $csv = $csv | Select-Object -Property "SoftwareTemp","Version","Count"

    # Rename 'SoftwareTemp' column to 'Software'
    $csv = $csv | Select-Object *,@{Name='Software';Expression={$_.SoftwareTemp}} | Select-Object -Property "Software","Version","Count"
    
    # If the 'Software' column contains the content of the 'Version' column, remove it from the 'Software' column
    $csv = $csv | Select-Object *,@{Name='SoftwareTemp';Expression={($_.Software -replace $_.Version,'') -replace '\s+$',''}} | Select-Object -Property "SoftwareTemp","Version","Count"

    # If the 'SoftwareTemp' column contains a "|", remove it and everything following it from the 'Software' column. And remove any trailing whitespace.
    $csv = $csv | Select-Object *,@{Name='Software';Expression={($_.SoftwareTemp -split '\|')[0] -replace '\s+$',''}} | Select-Object -Property "Software","Version","Count"

    # Add a new column to the CSV called "OS" that is initially blank for all rows
    $csv = $csv | Select-Object *,@{Name='OS';Expression={""}} | Select-Object -Property "Software","Version","OS","Count"
      
    # Loop through each object in the CSV and set the OS column based on the Software column
    $csv = $csv | ForEach-Object {
        if($_.Software -like "*Windows*" -or $_.Software -like "*Microsoft*") {
            $_.OS = "Windows"
        }
        elseif($_.Software -like "*el7*") {
            $_.OS = "RHEL7"
        }
        elseif($_.Software -like "*el8*") {
            $_.OS = "RHEL8"
        }
        else {
            $_.OS = ""
        }

        
        # Extract version from RHEL7 and RHEL8 software names
        if($_.Software -like "*.el7*" -or $_.Software -like "*.el8*") {
            $versionNumber = $_.Software -replace '[a-zA-Z-_0-9+]*[a-zA-Z][0-9]*-([\d.-]+)[a-zA-Z]*\.el[78].*','$1'
            if ($_.Software -ne $versionNumber) {
                $_.Version = $versionNumber
                $_.Software = $_.Software -replace '(\.el\d+).*',''
            }
            #$_.Version = $_.Software -replace '[a-zA-Z-_]*[a-zA-Z][0-9]*-([\d.-]+)[a-zA-Z]*\.el[78].*','$1'
            $_.Software = $_.Software -replace $_.Version,''
            #    $_.Version = $_.Software -replace '.*(\d+-\d+-\d+).*','$1'
         #   $_.Software = $_.Software -replace '(\.el\d+).*','$1'
            
        }

        

        # if Software has a "-" at the end of it, remove it and trailing whitespace.
        $_.Software = $_.Software -replace '-$','' -replace '\s+$',''

        # Return the object
        $_
    }

    # Find rows with matching 'Software'
    $csv = $csv | Group-Object -Property @("Software", "Version") | ForEach-Object {
        # If there is more than one row with the same 'Software' and 'Version' values, combine them into one row
        if($_.Count -gt 1) {
            # Combine the 'Version' column values into a single string
            $Version = ($_.Group | Select-Object -ExpandProperty Version) -join ","
            # Set 'Version' to the same value for all rows
            $Version = $Version.Split(",")[0]
            # Combine the 'OS' column values into a single string
            $OS = ($_.Group | Select-Object -ExpandProperty OS) -join ","
            # Set 'OS' to the same value for all rows
            $OS = $OS.Split(",")[0]
            # Convert the 'Count' column values into integers and add them together
            $Count = ($_.Group | Select-Object -ExpandProperty Count | ForEach-Object {[int]$_}) | Measure-Object -Sum | Select-Object -ExpandProperty Sum
            
            
            # Create a new object with the combined values
            [PSCustomObject]@{
                Software = $_.Name.Split(",")[0]
                Version = $Version
                OS = $OS
                Count = $Count
            }
        }
        # If there is only one row with the same 'Software' value, return the row as-is
        else {
            $_.Group
        }
    }

    # Export the output CSV file
    # Check if $OutputPath is null, if so, use the default path
    if(!$OutputPath){
        $OutputPath = $SoftwareListPath.Replace(".csv","-formatted.csv")
    }
    $csv | Export-Csv -Path $OutputPath -NoTypeInformation

}

# Call function if the script is run directly either by relative or absolute path
if ($MyInvocation.InvocationName -eq ".\Format-SoftwareList.ps1" -or $MyInvocation.InvocationName -eq $ScriptPath) {
    Enter-SoftwareMenu
}