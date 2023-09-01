# Load the Compare-CSV.ps1 script
. .\Compare-CSV.ps1

# Call the Compare-CSV function
Compare-CSV -Csv1Path "./test-data/file1.csv" -Csv2Path "./test-data/file2.csv" -ComparisonColumn "name"