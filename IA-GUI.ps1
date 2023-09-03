Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "PowerShell GUI"
$form.Size = New-Object System.Drawing.Size(400,300)
$form.StartPosition = "CenterScreen"

# Create the label
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(380,20)
$label.Text = "Select two CSV files to compare:"

# Create the Compare button
$compareButton = New-Object System.Windows.Forms.Button
$compareButton.Location = New-Object System.Drawing.Point(10,50)
$compareButton.Size = New-Object System.Drawing.Size(100,30)
$compareButton.Text = "Compare"
$compareButton.Add_Click({
    # Show the file selection boxes
    $fileBox1.Visible = $true
    $fileButton1.Visible = $true
    $fileBox2.Visible = $true
    $fileButton2.Visible = $true
})

# Create the Export Users button
$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Location = New-Object System.Drawing.Point(120,50)
$exportButton.Size = New-Object System.Drawing.Size(100,30)
$exportButton.Text = "Export Users"
$exportButton.Add_Click({
    # Show the radio button and Run Report button
    $radioButtonRegular.Visible = $true
    $radioButtonPrivileged.Visible = $true
    $runReportButton.Visible = $true
})

# Create the first file selection box
$fileBox1 = New-Object System.Windows.Forms.TextBox
$fileBox1.Location = New-Object System.Drawing.Point(10,90)
$fileBox1.Size = New-Object System.Drawing.Size(300,20)
$fileBox1.Visible = $false

$fileButton1 = New-Object System.Windows.Forms.Button
$fileButton1.Location = New-Object System.Drawing.Point(320,90)
$fileButton1.Size = New-Object System.Drawing.Size(70,20)
$fileButton1.Text = "Browse"
$fileButton1.Visible = $false

# Create the second file selection box
$fileBox2 = New-Object System.Windows.Forms.TextBox
$fileBox2.Location = New-Object System.Drawing.Point(10,120)
$fileBox2.Size = New-Object System.Drawing.Size(300,20)
$fileBox2.Visible = $false

$fileButton2 = New-Object System.Windows.Forms.Button
$fileButton2.Location = New-Object System.Drawing.Point(320,120)
$fileButton2.Size = New-Object System.Drawing.Size(70,20)
$fileButton2.Text = "Browse"
$fileButton2.Visible = $false

# Create the radio button for Regular Users
$radioButtonRegular = New-Object System.Windows.Forms.RadioButton
$radioButtonRegular.Location = New-Object System.Drawing.Point(10,160)
$radioButtonRegular.Size = New-Object System.Drawing.Size(100,20)
$radioButtonRegular.Text = "Regular Users"
$radioButtonRegular.Visible = $false

# Create the radio button for Privileged Users
$radioButtonPrivileged = New-Object System.Windows.Forms.RadioButton
$radioButtonPrivileged.Location = New-Object System.Drawing.Point(120,160)
$radioButtonPrivileged.Size = New-Object System.Drawing.Size(120,20)
$radioButtonPrivileged.Text = "Privileged Users"
$radioButtonPrivileged.Visible = $false

# Create the Run Report button
$runReportButton = New-Object System.Windows.Forms.Button
$runReportButton.Location = New-Object System.Drawing.Point(10,190)
$runReportButton.Size = New-Object System.Drawing.Size(100,30)
$runReportButton.Text = "Run Report"
$runReportButton.Visible = $false
$runReportButton.Add_Click({
    # Code to execute Export-Users.ps1 goes here
    & "Export-Users.ps1"
})

# Add the controls to the form
$form.Controls.Add($compareButton)
$form.Controls.Add($exportButton)
$form.Controls.Add($label)
$form.Controls.Add($fileBox1)
$form.Controls.Add($fileButton1)
$form.Controls.Add($fileBox2)
$form.Controls.Add($fileButton2)
$form.Controls.Add($radioButtonRegular)
$form.Controls.Add($radioButtonPrivileged)
$form.Controls.Add($runReportButton)

# Show the form
$form.ShowDialog() | Out-Null