#!/usr/bin/env pwsh
# Wenget Remote Installation Script for Windows
# Usage: irm https://raw.githubusercontent.com/superyngo/Wenget/main/install.ps1 | iex

param(
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

# Colors
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }

# Configuration
$APP_NAME = "wenget"
$REPO = "superyngo/Wenget"
$INSTALL_DIR = "$env:USERPROFILE\.wenget\apps\wenget"
$BIN_PATH = "$INSTALL_DIR\$APP_NAME.exe"

function Get-LatestRelease {
    try {
        $apiUrl = "https://api.github.com/repos/$REPO/releases/latest"
        Write-Info "Fetching latest release information..."

        $release = Invoke-RestMethod -Uri $apiUrl -Headers @{
            "User-Agent" = "wenget-installer"
        }

        return $release
    } catch {
        Write-Error "Failed to fetch release information: $_"
        exit 1
    }
}

function Get-Architecture {
    $arch = $env:PROCESSOR_ARCHITECTURE
    switch ($arch) {
        "AMD64" { return "x86_64" }
        "x86" { return "i686" }
        "ARM64" { return "aarch64" }
        default {
            Write-Warning "Unknown architecture: $arch, defaulting to x86_64"
            return "x86_64"
        }
    }
}

function Install-Wenget {
    Write-Info "=== Wenget Installation Script ==="
    Write-Info ""

    # Get latest release
    $release = Get-LatestRelease
    $version = $release.tag_name
    Write-Success "Latest version: $version"

    # Determine architecture
    $arch = Get-Architecture
    Write-Info "Detected architecture: $arch"

    # Find download URL for Windows
    $assetName = "$APP_NAME-windows-$arch.exe"
    $asset = $release.assets | Where-Object { $_.name -eq $assetName }

    if (-not $asset) {
        Write-Error "Could not find Windows release asset"
        Write-Info "Available assets:"
        $release.assets | ForEach-Object { Write-Info "  - $($_.name)" }
        Write-Info ""
        Write-Info "Looking for: $assetName"
        exit 1
    }

    $downloadUrl = $asset.browser_download_url
    Write-Info "Download URL: $downloadUrl"
    Write-Info ""

    # Create installation directory
    if (-not (Test-Path $INSTALL_DIR)) {
        New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
    }

    # Download binary directly
    Write-Info "Downloading $APP_NAME..."

    $ProgressPreference = 'SilentlyContinue'
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $BIN_PATH -UseBasicParsing
        $ProgressPreference = 'Continue'
        Write-Success "Downloaded successfully!"
    } catch {
        $ProgressPreference = 'Continue'
        Write-Error "Download failed: $_"
        exit 1
    }

    Write-Info "Installed to: $INSTALL_DIR"
    Write-Success "Binary installed successfully!"
    Write-Info ""

    # Run wenget init
    Write-Info "Initializing Wenget..."
    Write-Info ""

    try {
        & $BIN_PATH init --yes
        Write-Info ""
        Write-Success "Wenget initialized successfully!"
    } catch {
        Write-Warning "Failed to run wenget init. You can run it manually later."
        Write-Info "  Run: wenget init"
    }

    Write-Info ""
    Write-Success "Installation completed successfully!"
    Write-Info ""
    Write-Info "Installed version: $version"
    Write-Info "Installation path: $BIN_PATH"
    Write-Info ""
    Write-Info "Usage:"
    Write-Info "  wenget search <keyword>     - Search packages"
    Write-Info "  wenget add <package>        - Install a package"
    Write-Info "  wenget list                 - List installed packages"
    Write-Info "  wenget --help               - Show help"
    Write-Info ""
    Write-Warning "Note: You may need to restart your terminal for PATH changes to take effect."
    Write-Info ""
    Write-Info "To uninstall, run:"
    Write-Info "  irm https://raw.githubusercontent.com/$REPO/main/install.ps1 | iex -Uninstall"
}

function Uninstall-Wenget {
    Write-Info "=== Wenget Uninstallation Script ==="
    Write-Info ""

    # Check if wenget is available and run self-deletion
    if (Test-Path $BIN_PATH) {
        Write-Info "Running Wenget self-deletion..."
        try {
            & $BIN_PATH del self --yes
            Write-Success "Wenget uninstalled successfully!"
        } catch {
            Write-Warning "Wenget self-deletion failed. Performing manual cleanup..."

            # Remove binary
            Write-Info "Removing binary..."
            Remove-Item $BIN_PATH -Force -ErrorAction SilentlyContinue
            Write-Success "Binary removed"

            # Remove installation directory if empty
            if (Test-Path $INSTALL_DIR) {
                $items = Get-ChildItem $INSTALL_DIR -ErrorAction SilentlyContinue
                if ($items.Count -eq 0) {
                    Remove-Item $INSTALL_DIR -Force
                    Write-Success "Installation directory removed"
                }
            }

            # Try to remove .wenget directory if empty
            $wengetDir = "$env:USERPROFILE\.wenget"
            if (Test-Path $wengetDir) {
                $items = Get-ChildItem $wengetDir -Recurse -ErrorAction SilentlyContinue
                if ($items.Count -eq 0) {
                    Remove-Item $wengetDir -Force -Recurse
                    Write-Success ".wenget directory removed"
                } else {
                    Write-Info ".wenget directory contains other files, keeping it"
                }
            }
        }
    } else {
        Write-Info "Binary not found (already removed?)"
    }

    Write-Info ""
    Write-Success "Uninstallation completed!"
    Write-Warning "Note: You may need to restart your terminal for PATH changes to take effect."
}

# Main
if ($Uninstall) {
    Uninstall-Wenget
} else {
    Install-Wenget
}
