# Get all physical drives
$drives = Get-WmiObject -Class Win32_DiskDrive

# Loop through each drive and print its serial number
foreach ($drive in $drives) {
    Write-Output "Drive $($drive.DeviceID): $($drive.SerialNumber.Trim())"
}