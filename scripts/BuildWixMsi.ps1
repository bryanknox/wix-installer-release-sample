#!/usr/bin/env pwsh
<#
.SYNOPSIS
Builds the WiX MSI installer for the SampleWpfApp.

.DESCRIPTION
This script builds the WiX MSI installer using the parameterized project. It accepts
version information and other properties that can be passed to the WiX build process.
The script assumes that the application has already been published and are located in
the directory indicated by the PublishedFilesPath parameter.

.PARAMETER Version
The version number in semantic version format (e.g., "1.2.3"). This will be converted
to a 4-part version number for the MSI package (e.g., "1.2.3.0").

.PARAMETER ProductName
The name of the product to be displayed in the installer. Defaults to "Sample WPF App".

.PARAMETER Manufacturer
The manufacturer name to be displayed in the installer. Defaults to "Bryan Knox".

.PARAMETER PublishedFilesPath
The path to the published application files. Defaults to "../local-published/SampleWpfApp-output".

.PARAMETER Configuration
The build configuration to use. Defaults to "Release".

.PARAMETER Platform
The target platform. Defaults to "x64" (the only platform currently supported).

.EXAMPLE
.\BuildWixMsi.ps1 -Version "1.2.3"

.EXAMPLE
.\BuildWixMsi.ps1 -Version "1.0.0" -ProductName "My WPF App" -Manufacturer "My Company"

.EXAMPLE
.\BuildWixMsi.ps1 -Version "2.1.0" -Configuration "Debug" -Platform "x86"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$Version,

    [Parameter(Mandatory = $false)]
    [string]$ProductName = "Sample WPF App",

    [Parameter(Mandatory = $false)]
    [string]$Manufacturer = "Bryan Knox",

    [Parameter(Mandatory = $false)]
    [string]$PublishedFilesPath = "local-published\SampleWpfApp-output",

    [Parameter(Mandatory = $false)]
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",

    [Parameter(Mandatory = $false)]
    [ValidateSet("x64")]
    [string]$Platform = "x64"
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Define constants
$WIX_PROJECT_PATH = 'WixMsi\WixMsi.wixproj'

try {
    Write-Host "🚀 Starting WiX MSI build for $ProductName v$Version" -ForegroundColor Green

    # Validate that we're in the correct directory (check for solution file)
    $solutionFile = 'SampleWpfApp.sln'
    if (-not (Test-Path $solutionFile)) {
        throw "Solution file '$solutionFile' not found. Please run this script from the repository root."
    }

    # Validate that the WiX project file exists
    if (-not (Test-Path $WIX_PROJECT_PATH)) {
        throw "WiX project file '$WIX_PROJECT_PATH' not found."
    }

    # Convert 3-part version to 4-part version for MSI
    $packageVersion = "$Version.0"

    # Resolve the published files path to an absolute path
    if ([System.IO.Path]::IsPathRooted($PublishedFilesPath)) {
        $absolutePublishedFilesPath = $PublishedFilesPath
    } else {
        $absolutePublishedFilesPath = Resolve-Path $PublishedFilesPath -ErrorAction SilentlyContinue
    }

    if (-not $absolutePublishedFilesPath -or -not (Test-Path $absolutePublishedFilesPath)) {
        throw "Published files path '$PublishedFilesPath' not found. Please run PublishLocalSampleWpfApp.ps1 first."
    }

    Write-Host "📋 Build configuration:" -ForegroundColor Cyan
    Write-Host "  - Product Name: $ProductName"
    Write-Host "  - Manufacturer: $Manufacturer"
    Write-Host "  - Version: $Version"
    Write-Host "  - Package Version: $packageVersion"
    Write-Host "  - Configuration: $Configuration"
    Write-Host "  - Platform: $Platform"
    Write-Host "  - Published Files Path: $absolutePublishedFilesPath"

    # Validate that published files exist
    if (-not (Test-Path (Join-Path $absolutePublishedFilesPath "*.exe"))) {
        throw "No executable files found in '$absolutePublishedFilesPath'. Please run PublishLocalSampleWpfApp.ps1 first."
    }

    # Build the MSI using dotnet build with MSBuild properties
    Write-Host "📦 Building WiX MSI installer..." -ForegroundColor Yellow

    $buildArgs = @(
        'build'
        $WIX_PROJECT_PATH
        '--configuration', $Configuration
        '--verbosity', 'minimal'
        "-p:Platform=$Platform"
        "-p:ProductName=$ProductName"
        "-p:Manufacturer=$Manufacturer"
        "-p:PackageVersion=$packageVersion"
        "-p:PublishedFilesPath=$absolutePublishedFilesPath"
    )

    Write-Host "  - Running: dotnet $($buildArgs -join ' ')" -ForegroundColor Gray
    & dotnet @buildArgs

    if ($LASTEXITCODE -ne 0) {
        throw "dotnet build failed with exit code $LASTEXITCODE"
    }

    Write-Host "✅ WiX MSI installer built successfully!" -ForegroundColor Green

    # Find and display the output MSI file
    $msiPattern = "WixMsi\bin\$Platform\$Configuration\en-US\*.msi"
    $msiFiles = Get-ChildItem $msiPattern -ErrorAction SilentlyContinue

    if ($msiFiles) {
        $msiFile = $msiFiles[0]
        Write-Host ""
        Write-Host "🎉 MSI installer created successfully!" -ForegroundColor Green
        Write-Host "📂 MSI file location: $($msiFile.FullName)" -ForegroundColor Cyan

        $fileInfo = Get-Item $msiFile.FullName
        Write-Host "📄 MSI file: $($fileInfo.Name) ($([math]::Round($fileInfo.Length / 1MB, 2)) MB)" -ForegroundColor Gray

        Write-Host ""
        Write-Host "✨ You can now install the application using:" -ForegroundColor Yellow
        Write-Host "   msiexec /i `"$($msiFile.FullName)`"" -ForegroundColor White
    } else {
        Write-Warning "MSI file not found in expected location: $msiPattern"
    }

}
catch {
    Write-Host ""
    Write-Host "❌ Error during WiX MSI build: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    exit 1
}
