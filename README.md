# wix-installer-release-sample README

A sample WiX installer project for a .NET app with GitHub Actions workflow for creating releases of the installer.

The sample WiX installer project and GitHub workflows can be easily adapted to other .NET applications
that need an MSI for installation on Windows machines.

## Key Features

- Super simple .NET 9 WPF sample app (does nothing but display a blank window)
  - It is meant as a place holder app to be installed.

- Wix 6 MSI installer project for the WPF sample app.

- GitHub Actions workflows for:
  - CI of the WPF sample App
  - Release of the WiX MSI.
    - Publishes a GitHub release of the WiX based MSI installer for the WPF sample app.
      - And also a .zip archive of the WPF sample app's built files that can be manually installed.

- PowerShell scripts used by workflows
  - And Pester unit tests for those PowerShell scripts

- GitHub Copilot custom chat mode instructions.


## Folder structure

`docs\guidelines\` - Guidelines for devs and GitHub Copilot agents developing in this repo.

`scripts\` - Scripts for development and local dev testing.

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

## Create a Release

Pushing a v-tag to the GitHub repo will trigger the `.github\workflows\vtag-release.yml` GitHub Actions workflow.
That workflow will build the app and MSI installer, and the publish a GitHub release assocated with the v-tag.

A v-tag is a git tag like: `v1.2.3`. It must be a strict 3-part sematic version.

You can use git commands like the following create and push the v-tag:
```PowerShell
git tag -a v1.2.3 -m "Release version 1.2.3"

git push origin v1.2.3
```

Or, better yet, use the PowerShell script:
```PowerShell
.\scripts\CreateVTagRelease.ps1 -Version 1.2.3
```
