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

    Context "When project file has explicit AssemblyName" {
        It "Returns the explicit AssemblyName" {
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

        It "Handles AssemblyName with whitespace" {
            # Arrange
            $projectContent = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <AssemblyName>  WhitespaceApp  </AssemblyName>
  </PropertyGroup>
</Project>
"@
            $projectPath = Join-Path $script:TestDir "TestApp.csproj"
            Set-Content -Path $projectPath -Value $projectContent

            # Act
            $result = Get-AssemblyNameOrExit -ProjectPath $projectPath -ThrowOnError

            # Assert
            $result | Should -Be "WhitespaceApp"
        }
    }

    Context "When project file has no explicit AssemblyName" {
        It "Returns the project filename without extension" {
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

    Context "When project file does not exist" {
        It "Throws exception when ThrowOnError is specified" {
            # Arrange
            $nonExistentPath = Join-Path $script:TestDir "NonExistent.csproj"

            # Act & Assert
            {
                Get-AssemblyNameOrExit -ProjectPath $nonExistentPath -ThrowOnError
            } | Should -Throw "The project file '*NonExistent.csproj*' does not exist."
        }
    }

    Context "When project file is empty" {
        It "Throws exception when ThrowOnError is specified" {
            # Arrange
            $projectPath = Join-Path $script:TestDir "Empty.csproj"
            Set-Content -Path $projectPath -Value ""

            # Act & Assert
            {
                Get-AssemblyNameOrExit -ProjectPath $projectPath -ThrowOnError
            } | Should -Throw "The project file '*Empty.csproj*' is empty or contains only whitespace."
        }

        It "Throws exception for whitespace-only file when ThrowOnError is specified" {
            # Arrange
            $projectPath = Join-Path $script:TestDir "WhitespaceOnly.csproj"
            Set-Content -Path $projectPath -Value "   `n   `t   `n   "

            # Act & Assert
            {
                Get-AssemblyNameOrExit -ProjectPath $projectPath -ThrowOnError
            } | Should -Throw "The project file '*WhitespaceOnly.csproj*' is empty or contains only whitespace."
        }
    }

    Context "When project file has invalid XML" {
        It "Throws exception when ThrowOnError is specified" {
            # Arrange
            $projectContent = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net9.0-windows</TargetFramework>
    <AssemblyName>InvalidXmlApp
  </PropertyGroup>
</Project>
"@
            $projectPath = Join-Path $script:TestDir "InvalidXml.csproj"
            Set-Content -Path $projectPath -Value $projectContent

            # Act & Assert
            {
                Get-AssemblyNameOrExit -ProjectPath $projectPath -ThrowOnError
            } | Should -Throw "The project file '*InvalidXml.csproj*' contains invalid XML*"
        }
    }

    Context "When project file has empty AssemblyName element" {
        It "Throws exception when ThrowOnError is specified" {
            # Arrange
            $projectContent = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net9.0-windows</TargetFramework>
    <AssemblyName></AssemblyName>
    <UseWPF>true</UseWPF>
  </PropertyGroup>
</Project>
"@
            $projectPath = Join-Path $script:TestDir "EmptyAssemblyName.csproj"
            Set-Content -Path $projectPath -Value $projectContent

            # Act & Assert
            {
                Get-AssemblyNameOrExit -ProjectPath $projectPath -ThrowOnError
            } | Should -Throw "The AssemblyName element in project file '*EmptyAssemblyName.csproj*' is empty."
        }

        It "Throws exception for whitespace-only AssemblyName when ThrowOnError is specified" {
            # Arrange
            $projectContent = @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <AssemblyName>   </AssemblyName>
  </PropertyGroup>
</Project>
"@
            $projectPath = Join-Path $script:TestDir "WhitespaceAssemblyName.csproj"
            Set-Content -Path $projectPath -Value $projectContent

            # Act & Assert
            {
                Get-AssemblyNameOrExit -ProjectPath $projectPath -ThrowOnError
            } | Should -Throw "The AssemblyName element in project file '*WhitespaceAssemblyName.csproj*' is empty."
        }
    }

    Context "When file cannot be read" {
        It "Throws exception when ThrowOnError is specified" {
            # This test is challenging to create reliably across different systems
            # We'll skip it for now as it would require creating a file with restricted permissions
            # which can be platform-specific
            Set-ItResult -Skipped -Because "Requires platform-specific file permission setup"
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

    It "Returns exit code 1 when project file does not exist" {
        # Arrange
        $nonExistentPath = Join-Path $script:TestDir "NonExistent.csproj"

        # Act
        pwsh -NoProfile -Command "& '$script:WrapperPath' -ProjectPath '$nonExistentPath'; exit `$LASTEXITCODE"

        # Assert
        $LASTEXITCODE | Should -Be 1
    }

    It "Returns exit code 1 when project file is empty" {
        # Arrange
        $projectPath = Join-Path $script:TestDir "Empty.csproj"
        Set-Content -Path $projectPath -Value ""

        # Act
        pwsh -NoProfile -Command "& '$script:WrapperPath' -ProjectPath '$projectPath'; exit `$LASTEXITCODE"

        # Assert
        $LASTEXITCODE | Should -Be 1
    }

    It "Returns exit code 0 when project file is valid" {
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
