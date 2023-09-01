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

    # OS Column
    #$csv = $csv | Select-Object *,@{Name='OS';Expression={if($_.Software -like '*Windows 10*') {'Windows'} else {$_.OS}}}

    # Add a new column to the CSV called "OS" that is initially blank for all rows
    #$csv = $csv | Select-Object *,@{Name='OS';Expression={""}} | Select-Object -Property "Software","Version","OS","Count"
    # If the 'Software' column contains "Windows", add "Windows" to the 'OS' column
    #$csv = $csv | Select-Object *,@{Name='OS';Expression={if($_.Software -like "*Windows*") {"Windows"}}} | Select-Object -Property "Software","Version","OS","Count"
    # If the 'Software' column contains "Linux" or ".el7" or ".el8", add "Linux" to the 'OS' column
    #$csv = $csv | Select-Object *,@{Name='OS';Expression={if($_.Software -like "*Linux*"){"Linux"}}} | Select-Object -Property "Software","Version","OS","Count"
    #$csv = $csv | Select-Object *,@{Name='OS';Expression={if($_.Software -like "*.el7*"){"RHEL 7"}}} | Select-Object -Property "Software","Version","OS","Count"
    #$csv = $csv | Select-Object *,if($_.Software -like "*.el8*")@{Name='OS';Expression={"RHEL 8"}}else@{Name='OS';Expression={"cheese"}} | Select-Object -Property "Software","Version","OS","Count"
    

    # Export the output CSV file
    # Check if $OutputPath is null, if so, use the default path
    if(!$OutputPath){
        $OutputPath = $SoftwareListPath.Replace(".csv","-formatted.csv")
    }
    $csv | Export-Csv -Path $OutputPath -NoTypeInformation

}