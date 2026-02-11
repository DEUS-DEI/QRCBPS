
try {
    Write-Host "Sourcing QRCBScript.ps1..."
    . "$PSScriptRoot\QRCBScript.ps1"
    Write-Host "Sourced successfully."
} catch {
    Write-Host "Error sourcing: $_"
}

if (Get-Command New-RS -ErrorAction SilentlyContinue) {
    Write-Host "New-RS exists"
} else {
    Write-Host "New-RS does NOT exist"
}
