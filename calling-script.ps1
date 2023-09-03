# Load the Compare-CSV.ps1 script
. .\Compare-CSV.ps1

# Load the Format-SoftwareList.ps1 script
. .\Format-SoftwareList2.ps1

# Call the Compare-CSV function
Compare-CSV -Csv1Path "./test-data/file1.csv" -Csv2Path "./test-data/file2.csv" -ComparisonColumn "name"

# Call the Format-SoftwareList function
Format-SoftwareList -SoftwareListPath "./test-data/software1.csv"
