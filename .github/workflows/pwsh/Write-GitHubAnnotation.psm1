function Write-GitHubAnnotation {
    <#
    .SYNOPSIS
    Writes GitHub Actions workflow commands for error, warning, and notice annotations.

    .DESCRIPTION
    This function outputs GitHub Actions workflow commands in the proper format.
    Supports error, warning, and notice types with optional titles.
    Includes a Prefix parameter for testing scenarios to avoid triggering actual annotations.

    .PARAMETER Type
    The type of annotation: 'error', 'warning', or 'notice'.

    .PARAMETER Message
    The message content for the annotation.

    .PARAMETER Title
    Optional title for the annotation. When provided, formats as "::type title=Title::Message".
    When omitted, formats as "::type::Message".

    .PARAMETER Prefix
    Optional prefix to use instead of the default "::". Useful for testing scenarios.
    When specified, uses the custom prefix instead of "::".

    .EXAMPLE
    Write-GitHubAnnotation -Type "error" -Title "Build Failed" -Message "Compilation error in file.cs"
    # Outputs: ::error title=Build Failed::Compilation error in file.cs

    .EXAMPLE
    Write-GitHubAnnotation -Type "warning" -Message "Deprecated function used"
    # Outputs: ::warning::Deprecated function used

    .EXAMPLE
    # For testing without triggering annotations
    Write-GitHubAnnotation -Type "error" -Title "Test Error" -Message "Test message" -Prefix "TEST::"
    # Outputs: TEST::error title=Test Error::Test message
    #>
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("error", "warning", "notice")]
        [string]$Type,

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [string]$Title,

        [Parameter(Mandatory = $false)]
        [string]$Prefix = "::"
    )

    # Build the workflow command format
    if (-not [string]::IsNullOrWhiteSpace($Title)) {
        $output = "${Prefix}${Type} title=${Title}::${Message}"
    }
    else {
        $output = "${Prefix}${Type}::${Message}"
    }

    # Output the workflow command
    Write-Host $output
}

Export-ModuleMember -Function Write-GitHubAnnotation
