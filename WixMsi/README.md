# WiX MSI Installer for Sample WPF App

This directory contains a WiX 6 installer project that creates an MSI installer for the Sample WPF Application. The installer project is fully parameterized to support different build scenarios.

## Overview

The WiX installer project uses the modern WiX 6 Toolset with HeatWave Community Edition features:

- **File Harvesting**: Uses the `Files` element to automatically harvest all files from the published application output
- **Parameterization**: Supports configurable product name, manufacturer, version, and file paths
- **Modern WiX 6**: Built with WiX 6 Toolset and HeatWave Community Edition (no deprecated Heat tool)

## Project Structure

- `Package.wxs` - Main package definition with parameterized properties
- `AppComponents.wxs` - Component group that harvests files using the `Files` element
- `Folders.wxs` - Directory structure definition
- `Package.en-us.wxl` - Localization strings
- `WixMsi.wixproj` - MSBuild project file with parameterization support

## Key Features

### File Harvesting with `Files` Element

The installer uses the WiX 6 `Files` element to automatically harvest all files from the published application output:

```xml
<Files
  Include="!(bindpath.PublishedFiles)\**"
  Directory="INSTALLFOLDER" />
```

This approach:
- Automatically includes all files from the published output
- No need to manually maintain file lists
- Uses bind paths for flexible source location configuration

### Parameterization

The installer supports the following parameters:

| Parameter | Description | Default Value |
|-----------|-------------|---------------|
| `ProductName` | Display name of the product | "Sample WPF App" |
| `Manufacturer` | Company/manufacturer name | "Bryan Knox" |
| `PackageVersion` | 4-part version number (e.g., "1.2.3.0") | "1.0.0.0" |
| `PublishedFilesPath` | Path to published application files | "../local-published/SampleWpfApp-output" |

## Usage

### Prerequisites

1. Install WiX 6 Toolset
2. Ensure the application has been published using `PublishLocalSampleWpfApp.ps1`

### Building the MSI Installer

#### Option 1: Using the Build Script (Recommended)

Use the provided PowerShell scripts for an automated build process:

```powershell
# Build both the application and MSI installer
.\scripts\PublishAndBuildMsi.ps1 -Version "1.2.3"

# Build with custom product information
.\scripts\PublishAndBuildMsi.ps1 -Version "1.0.0" -ProductName "My WPF App" -Manufacturer "My Company"

# Build only the MSI (if app is already published)
.\scripts\BuildWixMsi.ps1 -Version "1.2.3"
```

#### Option 2: Using dotnet build directly

```powershell
dotnet build WixMsi\WixMsi.wixproj `
  --configuration Release `
  -p:Platform=x64 `
  -p:ProductName="Sample WPF App" `
  -p:Manufacturer="Bryan Knox" `
  -p:PackageVersion="1.2.3.0" `
  -p:PublishedFilesPath="C:\full\path\to\published\files"
```

#### Option 3: Using MSBuild

```powershell
msbuild WixMsi\WixMsi.wixproj `
  /p:Configuration=Release `
  /p:Platform=x64 `
  /p:ProductName="Sample WPF App" `
  /p:Manufacturer="Bryan Knox" `
  /p:PackageVersion="1.2.3.0" `
  /p:PublishedFilesPath="C:\full\path\to\published\files"
```

### Output Location

The MSI installer will be created in:
```
WixMsi\bin\{Platform}\{Configuration}\en-US\WixMsi.msi
```

For example: `WixMsi\bin\x64\Release\en-US\WixMsi.msi`

## GitHub Actions Integration

The parameterized design makes it easy to integrate with CI/CD pipelines. Example GitHub Actions usage:

```yaml
- name: Build MSI Installer
  run: |
    dotnet build WixMsi/WixMsi.wixproj `
      --configuration Release `
      -p:Platform=x64 `
      -p:ProductName="Sample WPF App" `
      -p:Manufacturer="Bryan Knox" `
      -p:PackageVersion="${{ github.event.inputs.version }}.0" `
      -p:PublishedFilesPath="${{ github.workspace }}/published-output"
```

## Development Notes

### File Binding

The project uses WiX bind paths to reference the published files:

- `PublishedFiles` bind path points to the published application output
- Configured via `WixBindPath` in the project file
- Allows flexible source location without hardcoded paths

### Version Handling

- The installer expects a 4-part version number (e.g., "1.2.3.0")
- Scripts automatically convert 3-part semantic versions to 4-part versions
- Version is used for MSI package versioning and upgrade logic

### Localization

- Currently supports English (en-US) localization
- Localization strings are defined in `Package.en-us.wxl`
- Additional languages can be added by creating additional `.wxl` files

## Troubleshooting

### Common Issues

1. **"Published files not found"**
   - Ensure the application has been published first using `PublishLocalSampleWpfApp.ps1`
   - Verify the `PublishedFilesPath` parameter points to the correct location

2. **"WiX toolset not found"**
   - Install WiX 6 Toolset: `dotnet tool install --global wix`
   - Ensure WiX is available in your PATH

3. **"Bind path not resolved"**
   - Check that the `PublishedFilesPath` is an absolute path
   - Verify that the path contains the published application files

### Debugging

To enable verbose output during build:

```powershell
dotnet build WixMsi\WixMsi.wixproj --verbosity detailed
```

## Additional Resources

- [WiX 6 Documentation](https://docs.firegiant.com/)
- [Files Element Documentation](https://docs.firegiant.com/wix/schema/wxs/files/)
- [WiX 6 Migration Guide](https://docs.firegiant.com/migration/)
