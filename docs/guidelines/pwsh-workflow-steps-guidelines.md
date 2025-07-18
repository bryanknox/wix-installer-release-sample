# PowerShell Workflow Steps Guidelines

Guidelines for development of PowerShell functions and scripts
for use in GitHub Actions workflow steps.

## Tooling to use

- Use PowerShell 7.2.x for scripts and modules.
- Use Pester 5.7.x testing framework.
- Use the latest stable patch version of PowerShell modules.

## Script Step Guidelines

- Use `shell: pwsh` for script steps.
  - To ensure PowerShell 7 is used in workflow steps.

- The `name:` field should be the first line of each step.
  - To help make the workflow easy to understand.

- Put complex workflow step logic in separate PowerShell scripts or functions
  in the `.github/workflows/pwsh` folder.

## Logging Errors, Warnings, and Notices

- Use GitHub workflow command for logging errors, warnings, and notices.

Example
```powershell
Write-Output "::error title=Setup Failed::Missing config file."
Write-Output "::warning title=Skipping validation::Validation API times-out."
Write-Output "::Notice title=Skipping workflow::No v-tag."
```

## Script and Module Files

- Put PowerShell scripts in `.ps1` files.
  - One script per `.ps1` file.

- Put PowerShell functions in `.psm1` module files.
  - One function per `.psm1` module files.

## Line-wrap PowerShell for readability

- Line-wrap long PowerShell lines to 80 column.

- Use backticks for line continuation in PowerShell scripts.

 - When line-wrapping commands, place the command and subcommand on the first line, and each subsequent argument on separate lines.

   Example:
   ```PowerShell
   dotnet build `
       --configuration $configuration `
       --no-restore
   ```

## workflow Steps that Output Task Variables

 If a workflow step with complex logic outputs values as workflow step variables then:

- The step logic should be implemented in a PowerShell function within a
  `.psm1` module file.

- The function should return the raw data to be output by the step.

- The workflow step should then use GitHub workflow commands to output the data returned from the function as step output environment variables that can be accessed in subsequent workflow steps.

Example:
```PowerShell
steps:

  - name: Call PowerShell function and set output variable
    id: source_function
    shell: pwsh
    run: |
      Import-Module "./pwsh/Get-Greeting.psm1" -Force
      $result = Get-Greeting -name "GitHub User"
      "GREETING=$result" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append

  - name: Use output variable
    shell: pwsh
    run: |
      $greeting = "${{ steps.source_function.outputs.GREETING }}"
      Write-Host "Greeting: $greeting"
```

This help provide transparency and control within the workflow file for the variable names that are used, and helps make it clear where the values come from.

### Unit Tests Guidelines

- Maintain unit tests in the `.github/workflows/pwsh-unit-tests` folder.

- Separate test `.Tests.ps1` file for each function or script being tested.
  - e.g. `.github/workflows/pwsh-unit-tests/{script-function-name}.Tests.ps1`

- Mock all external dependencies (like `Invoke-RestMethod`)
