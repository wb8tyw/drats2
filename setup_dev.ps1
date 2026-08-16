# setup_dev.ps1 -> Run via: . .\setup_dev.ps1

# 1. Clear previous session state and grab lowercase short hostname
$env:PYTHONPATH = $null
$env:DRATS_DEV_HOME = $null
$ShortHost = $env:COMPUTERNAME.Split('.').ToLower()

Write-Host "[INFO] Initializing / Resuming environment for host: [$ShortHost]"

# 2. Establish monorepo base locations
$RepoRoot = Get-Location
$DevLocalDir = "$RepoRoot/local/$ShortHost"
$DevLibs = "$DevLocalDir/libs"
$DevHome = "$DevLocalDir/home"

# 3. Auto-heal folders if missing
if (-not (Test-Path $DevLibs)) {
    New-Item -ItemType Directory -Force -Path $DevLibs | Out-Null }
if (-not (Test-Path $DevHome)) {
    New-Item -ItemType Directory -Force -Path $DevHome | Out-Null }

# 4. Determine platform requirements track
$ReqFile = "./windows/development/requirements.txt"
if (-not (Test-Path $ReqFile)) { $ReqFile = "./windows/requirements.txt" }

if (Test-Path $ReqFile) {
    $LibCount = (Get-ChildItem $DevLibs).Count
    if ($LibCount -eq 0 -or $null -eq $LibCount) {
        $Msg = "[SETUP] Cache empty. Installing from $ReqFile..."
        Write-Host $Msg
        pip install --target=$DevLibs --upgrade -r $ReqFile
    } else {
        Write-Host "[SUCCESS] PyPI dependencies present in $DevLibs."
    }
}

# 5. Build dynamic PYTHONPATH tracking arrays
$PathsToInject = @()

if (Test-Path "$RepoRoot/libs") {
    foreach ($Lib in Get-ChildItem "$RepoRoot/libs") {
        if ($Lib.PSIsContainer) { $PathsToInject += $Lib.FullName }
    }
}
$PathsToInject += $DevLibs
$PathsToInject += $RepoRoot

# 6. Export variables to the live terminal session
$env:DRATS_DEV_HOME = $DevHome
$env:PYTHONPATH = $PathsToInject -join ";"

Write-Host "[READY] Environment variables bound. Ready to manually run tests."
Write-Host "   -> Config Home:  $env:DRATS_DEV_HOME"
Write-Host "   -> Example run:  python -m apps.gui.hello_world_kivy"
