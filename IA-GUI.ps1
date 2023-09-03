Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PowerShell GUI"
$form.Size = New-Object System.Drawing.Size(400,250)
$form.StartPosition = "CenterScreen"

# Create a label
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(380,20)
$label.Text = "Select two CSV files to compare:"

# Create the first file selection box
$fileBox1 = New-Object System.Windows.Forms.TextBox
$fileBox1.Location = New-Object System.Drawing.Point(10,50)
$fileBox1.Size = New-Object System.Drawing.Size(300,20)

$fileButton1 = New-Object System.Windows.Forms.Button
$fileButton1.Location = New-Object System.Drawing.Point(320,50)
$fileButton1.Size = New-Object System.Drawing.Size(70,20)
$fileButton1.Text = "Browse"

$fileButton1.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "CSV Files (*.csv)|*.csv"
    $dialog.Multiselect = $false
    $result = $dialog.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $fileBox1.Text = $dialog.FileName
    }
})

# Create the second file selection box
$fileBox2 = New-Object System.Windows.Forms.TextBox
$fileBox2.Location = New-Object System.Drawing.Point(10,80)
$fileBox2.Size = New-Object System.Drawing.Size(300,20)

$fileButton2 = New-Object System.Windows.Forms.Button
$fileButton2.Location = New-Object System.Drawing.Point(320,80)
$fileButton2.Size = New-Object System.Drawing.Size(70,20)
$fileButton2.Text = "Browse"

$fileButton2.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "CSV Files (*.csv)|*.csv"
    $dialog.Multiselect = $false
    $result = $dialog.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $fileBox2.Text = $dialog.FileName
    }
})

# Create a label for the comparison column field
$comparisonColumnLabel = New-Object System.Windows.Forms.Label
$comparisonColumnLabel.Location = New-Object System.Drawing.Point(10,110)
$comparisonColumnLabel.Size = New-Object System.Drawing.Size(380,20)
$comparisonColumnLabel.Text = "Enter the comparison column name:"

# Create a text box for the comparison column
$comparisonColumnBox = New-Object System.Windows.Forms.TextBox
$comparisonColumnBox.Location = New-Object System.Drawing.Point(10,140)
$comparisonColumnBox.Size = New-Object System.Drawing.Size(300,20)

# Create a button to run the script
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(150,180)
$button.Size = New-Object System.Drawing.Size(100,30)
$button.Text = "Run Script"

# Add an event handler to the button
$button.Add_Click({
    # Load the Compare-CSV.ps1 script
    . .\Compare-CSV.ps1

    # Load the Format-SoftwareList.ps1 script
    . .\Format-SoftwareList.ps1

    # Call the Compare-CSV function
    Compare-CSV -Csv1Path $fileBox1.Text -Csv2Path $fileBox2.Text -ComparisonColumn $comparisonColumnBox.Text

    # # Call the Format-SoftwareList function
    # Format-SoftwareList -SoftwareListPath $fileBox1.Text
})

# Add the controls to the form
$form.Controls.Add($label)
$form.Controls.Add($fileBox1)
$form.Controls.Add($fileButton1)
$form.Controls.Add($fileBox2)
$form.Controls.Add($fileButton2)
$form.Controls.Add($comparisonColumnLabel)
$form.Controls.Add($comparisonColumnBox)
$form.Controls.Add($button)

# Show the form
$form.ShowDialog() | Out-Null