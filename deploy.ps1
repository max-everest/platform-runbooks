# PowerShell Deployment Script for MkDocs

# --- Configuration ---
$SiteUrl = "https://max-everest.github.io/platform-runbooks/"
$VenvPath = ".\.venv"
$PythonExecutable = Join-Path -Path $VenvPath -ChildPath "Scripts\python.exe"

# --- Script ---

# 1. Check for Virtual Environment
if (-not (Test-Path $PythonExecutable)) {
    Write-Host "ERROR: Python virtual environment not found at '$PythonExecutable'."
    Write-Host "Please run 'python -m venv .venv' to create it."
    exit 1
}

Write-Host "Virtual environment found. Starting deployment..."

# 2. Deploy the site using the venv Python
# We use --clean to ensure a fresh build and provide a clear commit message.
$deploymentCmd = "& `"$PythonExecutable`" -m mkdocs gh-deploy --clean --message 'Automated deployment via deploy.ps1'"
Invoke-Expression -Command $deploymentCmd

# Check the exit code of the deployment command
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: MkDocs deployment failed. Please check the output above for errors."
    exit 1
}

Write-Host "Deployment command executed successfully. Waiting for GitHub Pages to update..."

# 3. Wait for GitHub Pages to update (can take a minute)
Start-Sleep -Seconds 30

# 4. Inspect and Validate the live site
Write-Host "Inspecting live site at $SiteUrl..."

$validationPassed = $true
$logoUrl = "$($SiteUrl)assets/images/RSM_Standard_White_Logo.png"
$assetUrls = @(
    $logoUrl
)

try {
    $response = Invoke-WebRequest -Uri $SiteUrl -UseBasicParsing -ErrorAction Stop
    if ($response.StatusCode -ne 200) {
        Write-Host "ERROR: Main site URL responded with status code $($response.StatusCode)."
        $validationPassed = $false
    } else {
        Write-Host "SUCCESS: Main site URL is live (Status 200 OK)."
    }
} catch {
    Write-Host "ERROR: Failed to connect to the main site URL at $SiteUrl."
    $validationPassed = $false
}

# Test critical asset URLs
foreach ($url in $assetUrls) {
    try {
        $assetResponse = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
        if ($assetResponse.StatusCode -ne 200) {
            Write-Host "ERROR: Asset at $url responded with status code $($assetResponse.StatusCode)."
            $validationPassed = $false
        } else {
            Write-Host "SUCCESS: Asset at $url is live (Status 200 OK)."
        }
    } catch {
        Write-Host "ERROR: Failed to load asset at $url. It returned a 404 or other connection error."
        $validationPassed = $false
    }
}

if ($validationPassed) {
    Write-Host "--------------------------------------------------"
    Write-Host "SUCCESS: All deployment validations passed."
    Write-Host "You can view the site at: $SiteUrl"
} else {
    Write-Host "--------------------------------------------------"
    Write-Host "ERROR: One or more deployment validations failed. Please review the errors above."
    exit 1
}
