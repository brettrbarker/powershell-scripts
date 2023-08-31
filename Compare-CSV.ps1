################################################
# CSV Comparison Script
# Author: Brett Barker
# Date: 2023-08-30
# Description: This script compares two CSV files and outputs the differences to a new CSV file.
# Usage: ./Compare-CSV.ps1
################################################

# Define the paths to the input CSV files
$csv1Path = "./test-data/file1.csv"
$csv2Path = "./test-data/file2.csv"

# Import the CSV files as arrays of objects
$csv1 = Import-Csv -Path $csv1Path
$csv2 = Import-Csv -Path $csv2Path

# Define the name of the column to match on
$columnName = "name"

# Compare the two CSV files based on the matching column
$comparison = Compare-Object -ReferenceObject $csv1 -DifferenceObject $csv2 -Property $columnName -PassThru -IncludeEqual

# Add a new column to the output CSV file indicating the status change
$output = $comparison | Select-Object *,@{Name="Status Change";Expression={
    if($_.SideIndicator -eq "<="){"Deleted"}
    elseif($_.SideIndicator -eq "=>"){"Created"}
    else{"Unchanged"}
}}

# Export the output CSV file
$outputPath = "./test-data/output.csv"
$output | Export-Csv -Path $outputPath -NoTypeInformation