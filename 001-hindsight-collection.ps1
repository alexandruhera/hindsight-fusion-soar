param (
    [string]$json_input  # JSON input dynamically provided from upstream
)

# Convert JSON input
$json_data = $json_input | ConvertFrom-Json
$forensic_results_files = $json_data.forensic_results  # Flat array of strings
$forensic_analysis_path = $json_data.forensic_analysis_path
$system_hostname = $json_data.system_hostname
$analysis_timestamp = $json_data.analysis_timestamp
$selected_browser = $json_data.selected_browser

# Initialize error tracking
$has_processing_errors = $false
$exception_messages = @()

# Validate forensic files exist and track missing ones using try-catch
foreach ($file in $forensic_results_files) {
    try {
        if (-not (Test-Path -Path $file)) {
            throw "Missing forensic result file: $file"
        }
    } catch {
        $exception_messages += $_.Exception.Message
    }
}

$has_processing_errors = [bool]($exception_messages.Count)
if (-not $has_processing_errors) {
    try {
        # Construct ZIP file name based on hostname, browser selection, and timestamp
        $cleaned_browser_name = $selected_browser -replace "\s", "-"
        $zip_file_name = "${system_hostname}-${cleaned_browser_name}-${analysis_timestamp}.zip"
        $zip_file_path = Join-Path -Path $forensic_analysis_path -ChildPath $zip_file_name

        # Compress forensic results into a ZIP archive
        Compress-Archive -Path $forensic_results_files -DestinationPath $zip_file_path -Force
    } catch {
        $exception_messages += $_.Exception.Message
    }
}

# Recalculate error status after attempting ZIP creation
$has_processing_errors = [bool]($exception_messages.Count)
if (-not $has_processing_errors) {
    try {
        if (-not (Test-Path -Path $zip_file_path)) {
            throw "ZIP file is missing after compression."
        }
    } catch {
        $exception_messages += $_.Exception.Message
    }
}

# Construct final output
if ($has_processing_errors) {
    $json_output = [PSCustomObject]@{
        "has_processing_errors" = $has_processing_errors
        "exception_messages" = $exception_messages
    }
} else {
    $json_output = [PSCustomObject]@{
        "has_processing_errors" = $has_processing_errors
        "zip_file_path" = $zip_file_path
    }
}

$json_output | ConvertTo-Json -Depth 2 | Out-String