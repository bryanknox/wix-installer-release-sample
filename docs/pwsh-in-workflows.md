# PowerShell in GitHub Actions Workflows

PowerShell scripts are used in GitHub Actions workflows.

We write unit tests for those scripts too.

## Guidelines

For guidelines relatred to PowerShell script files within workflows, and unit tests for those scripts and functions, see:

- [PowerShell Workflow Steps Guidelines](./guidelines/pwsh-workflow-steps-guidelines.md)

- [PowerShell `OrExit` Pattern Guidelines](./guidelines/pwsh-orexit-pattern-guidelines.md)

## Using GitHub Copilot

The `workflow-pwsh-dev` GitHub Copilot custom chat mode has been defined that is helpful for development of PowerShell scripts for use in GitHub workflows.

See: [workflow-pwsh-dev.chatmode.md](../.github\chatmodes\workflow-pwsh-dev.chatmode.md)


## Unit Tests for Workflow PowerShell

Pester is used for PowerShell tests.
See https://pester.dev/

### CI for PowerShell in Workflows

Changes made to the PowerShell files used in workflows trigger a CI workflow that runs all of the Pester unit tests for those scripts.

See `.github\workflows\ci-workflow-pwsh.yml`

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
