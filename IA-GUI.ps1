# Create a PowerShell GUI

# Create a new form
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "IA GUI"
$Form.Size = New-Object System.Drawing.Size(500,500)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = 'FixedDialog'
$Form.MaximizeBox = $false
$Form.MinimizeBox = $false
$Form.Topmost = $true

# Create a label
$Label = New-Object System.Windows.Forms.Label
$Label.Location = New-Object System.Drawing.Size(10,10)
$Label.Size = New-Object System.Drawing.Size(480,20)
$Label.Text = "Select a script to run:"
$Form.Controls.Add($Label)
