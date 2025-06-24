param (
    [string]$json_input  # JSON input dynamically provided from upstream
)

# Convert JSON input
$json_data = $json_input | ConvertFrom-Json
$forensic_analysis_path = $json_data.forensic_analysis_path
$forensic_tool_path = $json_data.forensic_tool_path
$output_format = $json_data.output_format
$selected_browser = $json_data.selected_browser
$system_hostname = $json_data.system_hostname
# ======================================================
# Initialize essential variables for script execution
# ======================================================
$browser_profile_names = @() 
$browser_profile_paths = @() 
$resolved_user_data_path = $null  
$analysis_timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH-mm")
$forensic_results = @() 

# Initialize error tracking
$has_processing_errors = $false
$exception_messages = @()

# ======================================================
# Define the standard locations for browser user data
# ======================================================
$browser_paths = @{
    "Google Chrome" = "AppData\Local\Google\Chrome\User Data"
    "Microsoft Edge" = "AppData\Local\Microsoft\Edge\User Data"
    "Brave" = "AppData\Local\BraveSoftware\Brave-Browser\User Data"
}

# ======================================================
# Identify the currently logged-in user and retrieve their profile path
# ======================================================
try {
    $current_user = (Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).UserName -replace '^.+\\', ''
    $user_profile_path = (Get-CimInstance Win32_UserProfile -ErrorAction Stop | Where-Object { $_.LocalPath -like "*\$current_user" }).LocalPath

    # Validate that the retrieved profile path exists on the system
    if (-not (Test-Path $user_profile_path)) { 
        throw "The user's local profile path does not exist: $user_profile_path"
    }
} catch {
    # Capture the error message and store it for logging
    $exception_messages += $_.Exception.Message
}

# ======================================================
# Evaluate existing errors before proceeding with browser data path resolution
# ======================================================
$has_processing_errors = [bool]($exception_messages.Count)  # Boolean flag indicating if errors exist

# ======================================================
# Locate the browser's user data storage directory, ensuring no previous errors exist
# ======================================================
if (-not $has_processing_errors) {
    try {
        $browser_user_data_path = Join-Path -Path $user_profile_path -ChildPath $browser_paths[$selected_browser]

        # Check whether the browser data directory exists in the expected location
        if (-not (Test-Path $browser_user_data_path)) { 
            throw "The selected browser's data path does not exist: $browser_user_data_path"
        }
        $resolved_user_data_path = $browser_user_data_path  # Assign the resolved path for further processing
    } catch {
        # Capture the error message and store it for logging
        $exception_messages +="An error occurred when checking the browser profiel path $_.Exception.Message"
    }
}

# ======================================================
# Recalculate error status before moving to profile detection
# ======================================================
$has_processing_errors = [bool]($exception_messages.Count)

# ======================================================
# Scan for existing browser profiles only if prior steps were successful
# ======================================================
if (-not $has_processing_errors) {
    try {
        # Retrieve directories corresponding to browser profiles within the identified data path
        $detected_profiles = Get-ChildItem -Path $resolved_user_data_path -Directory | Where-Object { $_.Name -match '^Default$|^Profile\s\d+$' }

        # Store detected profiles as flat arrays
        foreach ($profile_entry in $detected_profiles) {
            $browser_profile_names += $profile_entry.Name
            $browser_profile_paths += $profile_entry.FullName
        }
    } catch {
        # Capture the error message and store it for logging
        $exception_messages += "An error ocurred when attempting to the browser profile path $_.Exception.Message"
    }
}

# ======================================================
# Proceed with hindsight processing only if no errors exist
# ======================================================
$has_processing_errors = [bool]($exception_messages.Count)
if (-not $has_processing_errors) {
    foreach ($index in 0..($browser_profile_names.Count - 1)) {
        # Extract the source profile path and apply standardized naming conventions
        $source_profile_path = $browser_profile_paths[$index]
        $cleaned_profile_name = $browser_profile_names[$index] -replace "\s", "-"
        $cleaned_browser_name = $selected_browser -replace "\s", "-"
        $cleaned_forensic_tool_path = $forensic_tool_path -replace "/", "\"

        # Construct the output file path with the hostname prepended
        $forensic_output_base = Join-Path $forensic_analysis_path "${system_hostname}-${cleaned_browser_name}-${cleaned_profile_name}-${analysis_timestamp}"
        $forensic_output_path = "$forensic_output_base.$output_format"

        try {
            # Execute hindsight forensic analysis on the browser profile
            Start-Process -FilePath $cleaned_forensic_tool_path `
                -ArgumentList "-i `"$source_profile_path`" -o `"$forensic_output_base`" -f $output_format -t UTC" `
                -NoNewWindow 

            # Store only the generated forensic output file path
            $forensic_results += $forensic_output_path
        } catch {
            # Capture the error message and store it for logging
            $exception_messages += $_.Exception.Message
        }
    }
}

# ======================================================
# Recalculate error status before assembling final output
# ======================================================
$has_processing_errors = [bool]($exception_messages.Count)

# ======================================================
# Construct JSON output dynamically based on error status
# ======================================================
if ($has_processing_errors) {
    # If errors are present, only include error-related fields
    $json_output = [PSCustomObject]@{
        "has_processing_errors" = $has_processing_errors
        "exception_messages" = $exception_messages
    }
} else {
    # If no errors, include browser profile data as well
    $json_output = [PSCustomObject]@{
        "has_processing_errors" = $has_processing_errors
        "user_data_path" = $resolved_user_data_path
        "browser_profile_names" = $browser_profile_names
        "browser_profile_paths" = $browser_profile_paths
        "forensic_results" = $forensic_results
		"analysis_timestamp" = $analysis_timestamp
    }
}

$json_output | ConvertTo-Json -Depth 2