param (
    [string]$json_input  # JSON input dynamically provided from upstream
)

# Convert JSON input
$json_data = $json_input | ConvertFrom-Json
$forensic_analysis_path = $json_data.forensic_analysis_path

# Initialize error tracking
$has_processing_errors = $false
$exception_messages = @()

try {
    # Ensure the forensic analysis directory is clean and exists
    if (Test-Path -Path $forensic_analysis_path) {
        Remove-Item -Path $forensic_analysis_path -Recurse -Force -ErrorAction Stop
    }
    New-Item -Path $forensic_analysis_path -ItemType Directory -Force | Out-Null
} catch {
    $exception_messages += $_.Exception.Message
}

# Validate the forensic analysis directory exists
$has_processing_errors = [bool]($exception_messages.Count)
if ($has_processing_errors) {
    $json_output = [PSCustomObject]@{
        "has_processing_errors" = $has_processing_errors
        "exception_messages" = $exception_messages
    }
} else {
    $json_output = [PSCustomObject]@{
        "has_processing_errors" = $has_processing_errors
        "forensic_analysis_path" = $forensic_analysis_path
    }
}
$json_output | ConvertTo-Json -Depth 2