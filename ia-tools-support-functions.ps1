## Support functions for ia-tools

# Load the Compare-CSV script
. .\Compare-CSV.ps1

# Define the default export location
$global:exportLocation = "$HOME\Downloads"
$global:exportLocationALT = "I:\" +  $(Get-Date -f yyyy)


function Show-Header {
    Write-Host "##### IA TOOLS #####" -ForegroundColor Green
    Write-Host "##### Working Directory: " -NoNewline -ForegroundColor Green
    Write-Host "$exportLocation" -ForegroundColor Red   
}

function Check-Number {
    param (
        [Parameter(Mandatory=$true)]
        [string]$number
    )
    if($number -match "^[0-9]+$"){
        return $true
    }
    else {
        return $false
    }
}

function Edit-WorkingDirectory {
    # while locationStatus is false, prompt user to enter new export location
    $locationStatus = $false
    while ($locationStatus -eq $false) {
        $origExportLocation = $exportLocation
        $newExportLocation = Read-Host "Enter new working directory location or '1' for $exportLocationALT"
        if ($newExportLocation -eq "1") {
            $global:exportLocation = $exportLocationALT
            $locationStatus = Test-ExportLocation
            if ($locationStatus -eq $false) {
                $global:exportLocation = $origExportLocation
            }
        }
        elseif ($newExportLocation -eq "") {
            break
        }
        else {
            $global:exportLocation = $newExportLocation
        }
        $locationStatus = Test-ExportLocation
    }
    Write-Host "Working Directory: $exportLocation"
    Start-Sleep -s 2
}

function Test-ExportLocation {
    # If the export location does not exist, show and error message
    if (!(Test-Path $exportLocation)) {
        Write-Host "Export location ($exportLocation) does not exist!" -ForegroundColor Red
        Write-Host "Please create the export location or select a new location."
        Start-Sleep -s 3
        return $false
    }
    return $true
}