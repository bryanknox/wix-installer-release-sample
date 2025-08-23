# WiX MSI Installer for Sample WPF App

This directory contains a WiX 6 installer project that creates an MSI installer for the Sample WPF Application. The installer project is fully parameterized to support different build scenarios.

## Overview

The WiX installer project uses the WiX 6 Toolset with HeatWave Community Edition features:

- **File Harvesting**: Uses the `Files` element to automatically harvest all files from the published application output
- **Parameterization**: Supports configurable product name, manufacturer, version, file paths, and MSI filename

## Project Structure

- `Package.wxs` - Main package definition with parameterized properties
- `AppComponents.wxs` - Component group that harvests files using the `Files` element
- `Folders.wxs` - Directory structure definition
- `Package.en-us.wxl` - Localization strings
- `WixMsi.wixproj` - MSBuild project file with parameterization support

## Key Features

### File Harvesting with `Files` Element

The installer uses the WiX 6 `Files` element to automatically harvest all files in the published application directory.

See [Files Element Documentation](https://docs.firegiant.com/wix/schema/wxs/files/) in the WiX Core docs.

### Parameterization

The installer supports the following parameters:

| Parameter | Description | Default Value |
|-----------|-------------|---------------|
| `PackageId` | Unique identifier for the package | "bryanknox.SampleWpfApp.5fce338" |
| `PackageVersion` | 4-part version number (e.g., "1.2.3.0") | "1.0.0.0" |
| `ProductName` | Display name of the product | "Sample WPF App" |
| `Manufacturer` | Company/manufacturer name | "Bryan Knox" |
| `PublishedFilesPath` | Path to published application files | "../local-published/SampleWpfApp-output" |
| `MainExecutableFileName` | Name of the main executable file in the PublishedFilesPath | "SampleWpfApp.exe" |
| `MsiFileName` | Base name for the generated MSI file (without .msi extension) | "WixMsi" |

### Version Upgrades

The installer is configured with WiX 6's modern upgrade strategy using the `UpgradeStrategy="majorUpgrade"` attribute. This ensures that:

- **Automatic Upgrades**: When a newer version is installed, it automatically replaces the previous version
- **Single Entry in Add/Remove Programs**: Only one version appears in Windows "Installed Apps" list
- **Preserved Settings**: User settings and configurations are maintained during upgrades
- **Downgrade Protection**: Installing an older version over a newer one is blocked by default

**How it works:**
- The `PackageId` remains constant across all versions (acts as the upgrade family identifier)
- The `PackageVersion` changes with each release
- The `ProductCode` is automatically generated uniquely for each build
- Windows Installer uses the PackageId to detect and upgrade related products

**Version Numbering:**
- Use 4-part version numbers (e.g., "1.2.3.10")
- Increment the version number for each release to enable proper upgrade detection
- The GitHub workflow automatically appends the build number to create unique versions

## Usage

### Prerequisites

1. Install WiX 6 Toolset
   - `dotnet tool install --global wix --version 6.0.0`
1. Ensure the application has been published to the directory specified by the `PublishedFilesPath` parameter.

### Building the MSI Installer

#### Option 1: Using a PowerShell Build Script (Recommended)

Use the provided PowerShell scripts for an automated build process:

```powershell
# Build & publish app then build MSI
.\scripts\PublishAndBuildMsi.ps1 -Version "1.2.3"

# Build & publish app then build MSI, with custom product information
.\scripts\PublishAndBuildMsi.ps1 -Version "1.0.0" -ProductName "My WPF App" -Manufacturer "My Company"

# Build & publish app then build MSI with custom MSI filename
.\scripts\PublishAndBuildMsi.ps1 -Version "1.2.3" -MsiFileName "MyApp-Setup"

# Build & publish app then build MSI, placing output in c:\build\msi\
.\scripts\PublishAndBuildMsi.ps1 -Version "1.2.3" -MsiOutFolderPath "c:\build\msi"

# Build only the MSI (if app is already published)
.\scripts\BuildWixMsi.ps1 -Version "1.2.3"

# Build only MSI with custom filename
.\scripts\BuildWixMsi.ps1 -Version "1.2.3" -MsiFileName "MyApp-Setup"

# Build only MSI, placing output in .\artifacts\msi\
.\scripts\BuildWixMsi.ps1 -Version "1.2.3" -MsiOutFolderPath ".\artifacts\msi"
```

#### Option 2: Using dotnet build directly

```powershell
dotnet build WixMsi\WixMsi.wixproj `
  --configuration Release `
  -p:Platform=x64 `
  -p:ProductName="Sample WPF App" `
  -p:Manufacturer="Bryan Knox" `
  -p:PackageVersion="1.2.3.0" `
  -p:PublishedFilesPath="C:\full\path\to\published\files" `
  -p:MsiFileName="MyApp-Setup"
```

#### Option 3: Using MSBuild

```powershell
msbuild WixMsi\WixMsi.wixproj `
  /p:Configuration=Release `
  /p:Platform=x64 `
  /p:ProductName="Sample WPF App" `
  /p:Manufacturer="Bryan Knox" `
  /p:PackageVersion="1.2.3.0" `
  /p:PublishedFilesPath="C:\full\path\to\published\files" `
  /p:MsiFileName="MyApp-Setup"
```

### Output Location

The MSI installer will be created in:
```
WixMsi\bin\{Platform}\{Configuration}\en-US\{MsiFileName}.msi
```

For example:
- Default: `WixMsi\bin\x64\Release\en-US\WixMsi.msi`
- With custom name: `WixMsi\bin\x64\Release\en-US\MyApp-Setup.msi`

## GitHub Actions Integration

The parameterized design makes it easy to integrate with CI/CD pipelines.

Example GitHub Actions usage:

```yaml
- name: Build MSI Installer
  run: |
    dotnet build WixMsi/WixMsi.wixproj `
      --configuration Release `
      -p:Platform=x64 `
      -p:ProductName="Sample WPF App" `
      -p:Manufacturer="Bryan Knox" `
      -p:PackageVersion="${{ github.event.inputs.version }}.0" `
      -p:PublishedFilesPath="${{ github.workspace }}/published-output" `
      -p:MsiFileName="SampleWpfApp-${{ github.event.inputs.version }}-Setup"
```

## Development Notes

### Version Handling

- The installer expects a 4-part `PackageVersion` version number (e.g., "1.2.3.4")
- Version is used for MSI package versioning and upgrade logic

### MSI File Naming

- The `MsiFileName` parameter controls the output MSI filename
- Do not include the `.msi` extension - it will be added automatically
- Useful for including version numbers or build identifiers in the filename

### Localization

- Currently supports US English (en-US) localization
- Localization strings are defined in `Package.en-us.wxl`
- Additional languages can be added by creating additional `.wxl` files

## Troubleshooting

### Common Issues

1. **"Published files not found"**
   - Ensure the application has been published first using `PublishLocalSampleWpfApp.ps1`
   - Verify the `PublishedFilesPath` parameter points to the correct location

2. **"WiX toolset not found"**
   - Install WiX 6 Toolset: `dotnet tool install --global wix --version 6.0.0`
   - Ensure WiX is available in your PATH

3. **"Bind path not resolved"**
   - Check that the `PublishedFilesPath` is an absolute path
   - Verify that the path contains the published application files

4. **"Multiple versions appearing in Add/Remove Programs"**
   - Ensure all installers use the same `PackageId` value
   - Verify that `UpgradeStrategy="majorUpgrade"` is set in Package.wxs
   - Check that version numbers are incrementing properly (newer versions should have higher numbers)

5. **"Upgrade not working"**
   - Verify the `PackageVersion` is higher than the currently installed version
   - Ensure the `PackageId` matches between versions
   - Check Windows Event Viewer for MSI installation logs if needed

### Debugging

To enable verbose output during build:

```powershell
dotnet build WixMsi\WixMsi.wixproj --verbosity detailed
```

## Additional Resources

- [WiX Toolset Documentation](https://docs.firegiant.com/wix/)

