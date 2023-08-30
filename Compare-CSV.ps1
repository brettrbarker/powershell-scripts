# Write a script that takes two CSV files, Matches the values from the first column that is called "name" and determines if lines have been added or removed.
# The script will write a new CSV file that will have the lines from the first CSV with a new column called 'Status Change' that says 'Deleted' if it is not in the second file.
# If the line is in the second file and not the first, the 'Status Changed' column will have "Created" in it.

# Define the paths to the input CSV files
$csv1Path = "C:\path\to\file1.csv"
$csv2Path = "C:\path\to\file2.csv"

# Import the CSV files as arrays of objects
$csv1 = Import-Csv -Path $csv1Path
$csv2 = Import-Csv -Path $csv2Path

# Define the name of the column to match on
$columnName = "name"

# Compare the two CSV files based on the matching column
$comparison = Compare-Object -ReferenceObject $csv1 -DifferenceObject $csv2 -Property $columnName -PassThru

# Add a new column to the output CSV file indicating the status change
$output = $comparison | Select-Object *,@{Name="Status Change";Expression={
    if($_.SideIndicator -eq "<="){"Deleted"}
    elseif($_.SideIndicator -eq "=>"){"Created"}
    else{"Unchanged"}
}}

# Export the output CSV file
$outputPath = "C:\path\to\output.csv"
$output | Export-Csv -Path $outputPath -NoTypeInformation