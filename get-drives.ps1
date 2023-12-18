# Get the machine name
$machineName = (Get-WmiObject -Class Win32_ComputerSystem).Name

Write-Output "Machine Name: $machineName"

# Get the machine serial number
$machineSerialNumber = (Get-WmiObject -Class Win32_BIOS).SerialNumber

Write-Output "Machine Serial Number: $machineSerialNumber"

# Get all physical drives
$drives = Get-WmiObject -Class Win32_DiskDrive

# Loop through each drive and print its information
foreach ($drive in $drives) {
    Write-Output "Drive SerialNumber: $($drive.SerialNumber.Trim())"
}