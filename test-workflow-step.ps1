# Test script to simulate the workflow step
$env:WPFAPP_CSPROJ_PATH = "src/SampleWpfApp/SampleWpfApp.csproj"
$env:GITHUB_OUTPUT = "$env:TEMP\github_output_test.txt"

# Clear any existing output file
if (Test-Path $env:GITHUB_OUTPUT) {
    Remove-Item $env:GITHUB_OUTPUT -Force
}

# Import the module
Import-Module "./.github/workflows/pwsh/Get-AssemblyNameOrExit.psm1" -Force

# Call the function and capture result
$assemblyName = Get-AssemblyNameOrExit -ProjectPath $env:WPFAPP_CSPROJ_PATH

# Output to GitHub Actions
"wpf_exe_name=$assemblyName" | Out-File -FilePath $env:GITHUB_OUTPUT -Encoding utf8 -Append
Write-Host "Extracted WPF app exe name: $assemblyName"

# Display the output file content
Write-Host "Contents of GITHUB_OUTPUT file:"
Get-Content $env:GITHUB_OUTPUT
