BeforeAll {
    # Import the module
    Import-Module "$PSScriptRoot\..\pwsh\Write-GitHubAnnotation.psm1" -Force
}

Describe "Write-GitHubAnnotation" {

    # IMPORTANT: All tests should include a -Prefix parameter so that they do not trigger
    # actual GitHub annotations when these tests are run within a GitHub Actions workflow.
    # The implementation of Write-GitHubAnnotation is such that there is low risk of the
    # default prefix (::) not being used when the -Prefix parameter is not specified.

    Context "Type behavior" {

        It "Outputs error" {
            # Arrange
            $type = "error"
            $title = "Build Failed"
            $message = "Some error message"
            $prefix = "TEST::"

            # Act & Assert
            $output = Write-GitHubAnnotation -Type $type -Title $title -Message $message -Prefix $prefix 6>&1
            $output | Should -Be "TEST::error title=Build Failed::Some error message"
        }

        It "Outputs notice" {
            # Arrange
            $type = "notice"
            $message = "Simple notice message"
            $prefix = "TEST::"

            # Act & Assert
            $output = Write-GitHubAnnotation -Type $type -Message $message -Prefix $prefix 6>&1
            $output | Should -Be "TEST::notice::Simple notice message"
        }

        It "Outputs warning" {
            # Arrange
            $type = "warning"
            $message = "Just a warning message"
            $prefix = "TEST::"

            # Act & Assert
            $output = Write-GitHubAnnotation -Type $type -Message $message -Prefix $prefix 6>&1
            $output | Should -Be "TEST::warning::Just a warning message"
        }
    }

    Context "Custom prefix behavior" {

        It "Uses custom prefix with title" {
            # Arrange
            $type = "error"
            $title = "Test Error"
            $message = "Test message"
            $prefix = "TEST::"

            # Act & Assert
            $output = Write-GitHubAnnotation -Type $type -Title $title -Message $message -Prefix $prefix 6>&1
            $output | Should -Be "TEST::error title=Test Error::Test message"
        }

        It "Uses custom prefix without title" {
            # Arrange
            $type = "warning"
            $message = "Test warning"
            $prefix = "DEBUG::"

            # Act & Assert
            $output = Write-GitHubAnnotation -Type $type -Message $message -Prefix $prefix 6>&1
            $output | Should -Be "DEBUG::warning::Test warning"
        }

        It "Uses empty prefix" {
            # Arrange
            $type = "notice"
            $message = "No prefix message"
            $prefix = ""

            # Act & Assert
            $output = Write-GitHubAnnotation -Type $type -Message $message -Prefix $prefix 6>&1
            $output | Should -Be "notice::No prefix message"
        }
    }

    Context "Parameter validation" {

        It "Rejects invalid type" {
            # Act & Assert
            { Write-GitHubAnnotation -Type "invalid" -Message "test" -Prefix "TEST::" } | Should -Throw
        }

        It "Accepts empty title (treated as no title)" {
            # Arrange
            $type = "error"
            $title = ""
            $message = "Message with empty title"
            $prefix = "TEST::"

            # Act & Assert
            $output = Write-GitHubAnnotation -Type $type -Title $title -Message $message -Prefix $prefix 6>&1
            $output | Should -Be "TEST::error::Message with empty title"
        }

        It "Accepts whitespace-only title (treated as no title)" {
            # Arrange
            $type = "warning"
            $title = "   "
            $message = "Message with whitespace title"
            $prefix = "TEST::"

            # Act & Assert
            $output = Write-GitHubAnnotation -Type $type -Title $title -Message $message -Prefix $prefix 6>&1
            $output | Should -Be "TEST::warning::Message with whitespace title"
        }
    }
}
