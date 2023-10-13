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

    try {
        # Check if the CSV files exist
        if(!(Test-Path $Csv1Path)){
            throw "Error: $Csv1Path does not exist!"
        }
        if(!(Test-Path $Csv2Path)){
            throw "Error: $Csv2Path does not exist!"
        }
    }
    catch {
        Write-Host $_
        return
    }
    Write-Host "##### CSV Comparison Script #####" -ForegroundColor Green

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
    $Csv1Name = Split-Path -Leaf $Csv1Path
    $Csv2Name = Split-Path -Leaf $Csv2Path
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


# Get absolute path of the script
$ScriptPath = $MyInvocation.MyCommand.Path

# Call the Compare-CSV function if the script is run directly either by relative or absolute path
if($MyInvocation.InvocationName -eq ".\Compare-CSV.ps1" -or $MyInvocation.InvocationName -eq $ScriptPath){
    Compare-CSV
}
