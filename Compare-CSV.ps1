################################################
# CSV Comparison Script
# Author: Brett Barker
# Date: 2023-08-30
# Description: This script compares two CSV files and outputs the differences to a new CSV file.
# Usage: ./Compare-CSV.ps1
################################################

function Compare-CSV {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Csv1Path,
        [Parameter(Mandatory=$true)]
        [string]$Csv2Path,
        [Parameter(Mandatory=$true)]
        [string]$ComparisonColumn,
        [Parameter(Mandatory=$false)]
        [string]$OutputPath
    )
    # Import the CSV files as arrays of objects
    $csv1 = Import-Csv -Path $csv1Path
    $csv2 = Import-Csv -Path $csv2Path

    # Compare the two CSV files based on the matching column
    $comparison = Compare-Object -ReferenceObject $csv1 -DifferenceObject $csv2 -Property $ComparisonColumn -PassThru -IncludeEqual

    # Add a new column to the output CSV file indicating the status change
    $output = $comparison | Select-Object *,@{Name="Status Change";Expression={
        if($_.SideIndicator -eq "<="){"Deleted"}
        elseif($_.SideIndicator -eq "=>"){"Added"}
        else{"Unchanged"}
    }}

    # Get only the filename from the end of the path for $Csv1Path and $Csv2Path
    $Csv1Name = $Csv1Path.Split("\")[-1]
    $Csv2Name = $Csv2Path.Split("\")[-1]
    # Get the directory of the first CSV file
    $OutputDirectory = $Csv1Path.Replace($Csv1Name,"")

    # Export the output CSV file
    # Check if $OutputPath is null, if so, use the default path
    if(!$OutputPath -or $OutputPath -eq ""){
        # $OutputPath = $Csv1Path.Replace(".csv","-") + $Csv2Name.Replace(".csv","-comparison.csv")
        $newname = $Csv1Name.Replace(".csv","-") + $Csv2Name.Replace(".csv","-comparison.csv")
        $OutputPath = Join-Path -Path $OutputDirectory -ChildPath $newname
    }
    try {
        $output | Export-Csv -Path $OutputPath -NoTypeInformation
        Write-Host "Output file saved to $OutputPath"
    }
    catch {
        Write-Host "Error: Failed to save output file. $($Error[0].Exception.Message)"
    }
}
