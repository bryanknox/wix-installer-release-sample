BeforeAll {
    # Import the module
    Import-Module "$PSScriptRoot\..\pwsh\Get-AssemblyNameOrExit.psm1" -Force
}

Describe "Get-AssemblyNameOrExit" {
    BeforeEach {
        # Create a temporary directory for test files
        $script:TestDir = New-Item -ItemType Directory -Path "$env:TEMP\Get-AssemblyNameOrExit-Tests-$(Get-Date -Format 'yyyyMMdd-HHmmss')" -Force
    }

    AfterEach {
        # Clean up test files
        if (Test-Path $script:TestDir) {
            Remove-Item $script:TestDir -Recurse -Force
        }
    }

    Context "Success scenarios" {
        It "Returns explicit AssemblyName when present" {
            # Arrange
            $projectContent = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net9.0-windows</TargetFramework>
    <AssemblyName>MyCustomApp</AssemblyName>
    <UseWPF>true</UseWPF>
  </PropertyGroup>
</Project>
"@
            $projectPath = Join-Path $script:TestDir "TestApp.csproj"
            Set-Content -Path $projectPath -Value $projectContent

            # Act
            $result = Get-AssemblyNameOrExit -ProjectPath $projectPath -ThrowOnError

            # Assert
            $result | Should -Be "MyCustomApp"
        }

        It "Returns project filename when no explicit AssemblyName" {
            # Arrange
            $projectContent = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net9.0-windows</TargetFramework>
    <UseWPF>true</UseWPF>
  </PropertyGroup>
</Project>
"@
            $projectPath = Join-Path $script:TestDir "SampleWpfApp.csproj"
            Set-Content -Path $projectPath -Value $projectContent

            # Act
            $result = Get-AssemblyNameOrExit -ProjectPath $projectPath -ThrowOnError

            # Assert
            $result | Should -Be "SampleWpfApp"
        }
    }

    Context "Error scenarios" {
        It "Throws exception for any file access/parsing error when ThrowOnError is specified" {
            # Test multiple error scenarios to ensure they all throw exceptions

            # Non-existent file
            $nonExistentPath = Join-Path $script:TestDir "NonExistent.csproj"
            {
                Get-AssemblyNameOrExit -ProjectPath $nonExistentPath -ThrowOnError
            } | Should -Throw "*does not exist*"

            # Empty file
            $emptyPath = Join-Path $script:TestDir "Empty.csproj"
            Set-Content -Path $emptyPath -Value ""
            {
                Get-AssemblyNameOrExit -ProjectPath $emptyPath -ThrowOnError
            } | Should -Throw "*empty or contains only whitespace*"

            # Invalid XML
            $invalidXmlPath = Join-Path $script:TestDir "InvalidXml.csproj"
            $invalidXmlContent = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <AssemblyName>InvalidXmlApp
  </PropertyGroup>
</Project>
"@
            Set-Content -Path $invalidXmlPath -Value $invalidXmlContent
            {
                Get-AssemblyNameOrExit -ProjectPath $invalidXmlPath -ThrowOnError
            } | Should -Throw "*contains invalid XML*"

            # Empty AssemblyName element
            $emptyAssemblyNamePath = Join-Path $script:TestDir "EmptyAssemblyName.csproj"
            $emptyAssemblyNameContent = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <AssemblyName></AssemblyName>
  </PropertyGroup>
</Project>
"@
            Set-Content -Path $emptyAssemblyNamePath -Value $emptyAssemblyNameContent
            {
                Get-AssemblyNameOrExit -ProjectPath $emptyAssemblyNamePath -ThrowOnError
            } | Should -Throw "*AssemblyName element*is empty*"
        }
    }
}


Describe "Get-AssemblyNameOrExit Exit Code Tests" {
    BeforeAll {
        # Create wrapper script for testing exit codes
        $script:WrapperScript = @"
param([string]`$ProjectPath)
Import-Module "`$PSScriptRoot\..\pwsh\Get-AssemblyNameOrExit.psm1" -Force
Get-AssemblyNameOrExit -ProjectPath `$ProjectPath
"@
        $script:WrapperPath = Join-Path $PSScriptRoot "Get-AssemblyNameOrExit-Wrapper.ps1"
        Set-Content -Path $script:WrapperPath -Value $script:WrapperScript
    }

    AfterAll {
        # Clean up wrapper script
        if (Test-Path $script:WrapperPath) {
            Remove-Item $script:WrapperPath -Force
        }
    }

    BeforeEach {
        # Create a temporary directory for test files
        $script:TestDir = New-Item -ItemType Directory -Path "$env:TEMP\Get-AssemblyNameOrExit-ExitTests-$(Get-Date -Format 'yyyyMMdd-HHmmss')" -Force
    }

    AfterEach {
        # Clean up test files
        if (Test-Path $script:TestDir) {
            Remove-Item $script:TestDir -Recurse -Force
        }
    }

    It "Exits with code 1 for any error condition in normal operation" {
        # Arrange - Test with non-existent file as representative error case
        $nonExistentPath = Join-Path $script:TestDir "NonExistent.csproj"

        # Act
        pwsh -NoProfile -Command "& '$script:WrapperPath' -ProjectPath '$nonExistentPath'; exit `$LASTEXITCODE"

        # Assert
        $LASTEXITCODE | Should -Be 1
    }

    It "Exits with code 0 for successful operation" {
        # Arrange
        $projectContent = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net9.0-windows</TargetFramework>
    <AssemblyName>ValidApp</AssemblyName>
    <UseWPF>true</UseWPF>
  </PropertyGroup>
</Project>
"@
        $projectPath = Join-Path $script:TestDir "ValidApp.csproj"
        Set-Content -Path $projectPath -Value $projectContent

        # Act
        pwsh -NoProfile -Command "& '$script:WrapperPath' -ProjectPath '$projectPath'; exit `$LASTEXITCODE"

        # Assert
        $LASTEXITCODE | Should -Be 0
    }
}
