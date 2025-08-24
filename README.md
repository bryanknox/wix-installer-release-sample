# wpf-release-play

This repo is for playing around with release workflows for WPF apps.
Seems weird. But there are some advantages to WPF-Blazor hybrid apps
over MAUI-Blazor hybrid apps. So it's worth figuring out the nuances
of the release workflows.

## Key Features

- Super simple WPF Sample App (does nothing but display a blank window)

- Wix 6 MSI installer project for the WPF Sample App.

- GitHub Actions workflow for CI and Releasing the WPF Sample App MSI.

- GitHub Copilot custom chat mode instructions.

## Folder structure

`docs\guidelines\` - Guidelines for devs and GitHub Copilot agents developing in this repo.

`scripts\` - Scripts for development and testing.

`src\SampleWpfApp\` - Sample WPF app. Just a raw sample doesn't do anything interesting.

`WixMsi\` - WiX project for the Sample WPF app's installer (MSI).

`.github\chatmodes\` - GitHub Copilot custom chat modes.

`.github\workflows\` - GitHub Actions workflows.

`.github\workflows\pwsh\` - PowerShell scripts used by workflows.

`.github\workflows\pwsh-unit-tests\` - Tests for Powershell scripts used by workflows.

## Running Workflow PowerShell Unit Tests

Pester is used for PowerShell tests. See https://pester.dev/

### Run a tests

```PowerShell
Invoke-Pester -Path "Get-AssemblyNameOrExit.Tests.ps1"

Invoke-Pester -Path "Get-AssemblyNameOrExit.Tests.ps1" -Verbose

Invoke-Pester -Path "Get-AssemblyNameOrExit.Tests.ps1" -Output Detailed
```

#### Run all tests in directory

```PowerShell
Invoke-Pester -Path "."
```

#### Run with Code Coverage (if you want to see coverage)

```PowerShell
Invoke-Pester -Path "Get-AssemblyNameOrExit.Tests.ps1" -CodeCoverage "../pwsh/Get-AssemblyNameOrExit.psm1"
```

#### Run Tests and Generate Results File

```PowerShell
Invoke-Pester -Path "Get-AssemblyNameOrExit.Tests.ps1" -OutputFile "TestResults.xml" -OutputFormat NUnitXml
```

## Create a Draft Release

A draft release of the sample app can be created by pushing a v-tag to the GitHub repo.

```PowerShell
git tag -a v1.2.3 -m "Release version 1.2.3"

git push origin v1.2.3
```

Doing that will trigger the `.github\workflows\vtag-draft-release.yml` GitHub Actions workflow.
