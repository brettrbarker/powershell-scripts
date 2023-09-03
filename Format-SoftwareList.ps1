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
        # if Software has a "-" at the end of it, remove it and trailing whitespace.
        $_.Software = $_.Software -replace '-$','' -replace '\s+$',''
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