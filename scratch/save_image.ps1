param(
    [string]$Name
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ========================================
# Validate environment variable
# ========================================
$OutputFolder = $env:IMAGE_SAVE_PATH

if (-not $OutputFolder -or $OutputFolder.Trim() -eq "") {
    Write-Host "ERROR: Environment variable IMAGE_SAVE_PATH is not set."
    Write-Host ""
    Write-Host "To set it permanently, run:"
    Write-Host '  [System.Environment]::SetEnvironmentVariable("IMAGE_SAVE_PATH", "C:\Path\To\Save", "User")'
    Write-Host ""
    Write-Host "To set it for the current session only, run:"
    Write-Host '  $env:IMAGE_SAVE_PATH = "C:\Path\To\Save"'
    exit 1
}

# ========================================
# Define file name
# ========================================
if (-not $Name -or $Name.Trim() -eq "") {
    $Name = (Get-Date -Format "yyyyMMdd_HHmmss")
}

# Ensure directory exists
if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
}

$OutputPath = Join-Path $OutputFolder "$Name.png"

# ========================================
# Capture clipboard image
# ========================================
$ImageFromClipboard = [System.Windows.Forms.Clipboard]::GetImage()

if ($ImageFromClipboard -ne $null) {
    $ImageFromClipboard.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host "Image saved successfully to:"
    Write-Host "  $OutputPath"
} else {
    Write-Host "No image found in the clipboard."
}


# Example usage:
# 1. Set the environment variable permanently
# [System.Environment]::SetEnvironmentVariable("IMAGE_SAVE_PATH", "C:\Users\618027\source\nishantnepal.github.io\_posts\2025-11-12-enterprise-gen-ai-intro", "User")

# 2. Or set it for the current session
# $env:IMAGE_SAVE_PATH = "C:\Users\618027\source\nishantnepal.github.io\_posts\2025-11-12-enterprise-gen-ai-intro"

# .\save_image.ps1 -Name "ArchitectureDiagram"
