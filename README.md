# wix-installer-release-sample README

A sample WiX installer project for a .NET app with GitHub Actions workflow for creating releases of the installer.

The sample WiX installer project and GitHub workflows can be easily adapted to other .NET applications
that need an MSI for installation on Windows machines.

## Tech Stack

- WiX 6 Toolkit - https://docs.firegiant.com/wix/
- PowerShell 7.2.x
- Pester 5.7.x test framework for PowerShell - https://pester.dev/
- .NET 9 - used in sample app
- Windows Presentation Foundation (WPF) - used in sample app
- Windows 11 is the target platform
- GitHub Actions workflows - used for CI and Releases

## Key Features

- Super simple .NET 9 WPF sample app (does nothing but display a blank window)
  - It is meant as a place holder app to be installed.

- Wix 6 MSI installer project for the WPF sample app.

- GitHub Actions workflows for:
  - CI for PowerShell scripts used in GitHub workflows
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

## Other docs in this repo

- [PowerShell in GitHub Actions Workflows](./docs/pwsh-in-workflows.md)

- [WiX MSI Installer for Sample WPF App](./WixMsi/README.md)

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
