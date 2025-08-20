# BAX-IDE VSCode Update Script (PowerShell version - ASCII only)
# 
# This script automatically:
# 1. Fetches the latest VSCode version from Microsoft's update API
# 2. Downloads and updates the VSCode source code
# 3. Applies all BAX branding (text and icons)
# 4. Cleans build outputs to ensure fresh compilation
#
# Usage: .\updating\update_bax_to_latest_vscode_simple.ps1 [options]
#
# Parameters:
#   -Insider        Update to VSCode Insider builds instead of stable
#   -Force          Force update even if already at latest version
#   -SkipIcons      Skip icon branding (faster for text-only updates)
#   -SkipVSCodium   Skip VSCodium patches update (VSCode only)
#   -Build          Automatically start build after update
#   -Help           Show this help message

[CmdletBinding()]
param(
    [switch]$Insider,
    [switch]$Force,
    [switch]$SkipIcons,
    [switch]$SkipVSCodium,
    [switch]$Build,
    [switch]$Help
)

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$VsCodeQuality = if ($Insider) { "insider" } else { "stable" }

# BAX Configuration
$env:APP_NAME = "BAX"
$env:BINARY_NAME = if ($Insider) { "bax-insiders" } else { "bax" }
$env:VSCODE_QUALITY = $VsCodeQuality
$env:OS_NAME = "windows"
$env:VSCODE_ARCH = "x64"

function Show-Help {
    Write-Host "BAX-IDE VSCode Update Script (PowerShell)"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "DESCRIPTION:"
    Write-Host "  Automatically updates BAX-IDE to the latest VSCode version while preserving BAX branding."
    Write-Host ""
    Write-Host "USAGE:"
    Write-Host "  .\updating\update_bax_to_latest_vscode_simple.ps1 [parameters]"
    Write-Host ""
    Write-Host "PARAMETERS:"
    Write-Host "  -Insider        Update to VSCode Insider builds instead of stable"
    Write-Host "  -Force          Force update even if already at latest version"
    Write-Host "  -SkipIcons      Skip icon branding (faster for text-only updates)"
    Write-Host "  -SkipVSCodium   Skip VSCodium patches update (VSCode only)"
    Write-Host "  -Build          Automatically start build after update"
    Write-Host "  -Help           Show this help message"
    Write-Host ""
    Write-Host "EXAMPLES:"
    Write-Host "  .\updating\update_bax_to_latest_vscode_simple.ps1"
    Write-Host "  .\updating\update_bax_to_latest_vscode_simple.ps1 -Insider -Build"
    Write-Host "  .\updating\update_bax_to_latest_vscode_simple.ps1 -Force -SkipIcons"
    Write-Host ""
    Write-Host "REQUIREMENTS:"
    Write-Host "  - Git for Windows"
    Write-Host "  - PowerShell 5.0+"
    Write-Host "  - ImageMagick (for icon generation)"
}

function Test-Prerequisites {
    Write-Host "Checking prerequisites..."
    
    $MissingTools = @()
    
    # Check for Git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        $MissingTools += "git"
    }
    
    # Check for curl (should be available in Windows 10+)
    if (-not (Get-Command curl -ErrorAction SilentlyContinue)) {
        $MissingTools += "curl"
    }
    
    if ($MissingTools.Count -gt 0) {
        Write-Host "Missing required tools:" -ForegroundColor Red
        foreach ($tool in $MissingTools) {
            Write-Host "  - $tool"
        }
        Write-Host ""
        Write-Host "Please install the missing tools and try again." -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "All prerequisites satisfied" -ForegroundColor Green
}

function Get-CurrentVersion {
    Write-Host "Getting current version information..."
    
    $VersionFile = Join-Path $RootDir "upstream\$VsCodeQuality.json"
    
    if (Test-Path $VersionFile) {
        try {
            $VersionInfo = Get-Content $VersionFile | ConvertFrom-Json
            $script:CurrentCommit = $VersionInfo.commit
            $script:CurrentTag = $VersionInfo.tag
            Write-Host "  Current commit: $CurrentCommit" -ForegroundColor Yellow
            Write-Host "  Current tag: $CurrentTag" -ForegroundColor Yellow
        }
        catch {
            Write-Host "  Error reading version file, assuming no current version" -ForegroundColor Yellow
            $script:CurrentCommit = "unknown"
            $script:CurrentTag = "unknown"
        }
    }
    else {
        Write-Host "  No current version information found" -ForegroundColor Yellow
        $script:CurrentCommit = "unknown"
        $script:CurrentTag = "unknown"
    }
}

function Get-LatestVersion {
    Write-Host "Fetching latest VSCode $VsCodeQuality version..."
    
    try {
        # Use Microsoft's update API
        $UpdateInfo = Invoke-RestMethod -Uri "https://update.code.visualstudio.com/api/update/darwin/$VsCodeQuality/0000000000000000000000000000000000000000" -ErrorAction Stop
        
        $script:MsCommit = $UpdateInfo.version
        $script:MsTag = $UpdateInfo.name
        
        # Clean up insider tag
        if ($VsCodeQuality -eq "insider") {
            $script:MsTag = $MsTag -replace "-insider", ""
        }
        
        # Generate BAX release version with timestamp
        $TimePatch = "{0:D4}" -f ((Get-Date).DayOfYear * 24 + (Get-Date).Hour)
        if ($VsCodeQuality -eq "insider") {
            $script:ReleaseVersion = "$MsTag$TimePatch-insider"
        }
        else {
            $script:ReleaseVersion = "$MsTag$TimePatch"
        }
        
        $env:MS_COMMIT = $MsCommit
        $env:MS_TAG = $MsTag
        $env:RELEASE_VERSION = $ReleaseVersion
        
        Write-Host "  Latest commit: $MsCommit" -ForegroundColor Green
        Write-Host "  Latest tag: $MsTag" -ForegroundColor Green
        Write-Host "  BAX release version: $ReleaseVersion" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to fetch version information from Microsoft's API" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)"
        exit 1
    }
}

function Test-UpdateNeeded {
    Write-Host "Checking if update is needed..."
    
    if ($Force) {
        Write-Host "  Force update requested - proceeding regardless of version" -ForegroundColor Yellow
        return $true
    }
    
    if ($CurrentCommit -eq $MsCommit) {
        Write-Host "Already at latest version ($MsCommit)" -ForegroundColor Green
        Write-Host "  Use -Force to update anyway" -ForegroundColor Cyan
        return $false
    }
    
    Write-Host "Update available: $CurrentCommit -> $MsCommit" -ForegroundColor Green
    return $true
}

function Update-VSCodiumPatches {
    Write-Host "Updating VSCodium patches and customizations..."
    
    # Create temporary directory for VSCodium updates
    $TempVSCodiumDir = Join-Path $RootDir "temp_vscodium_update"
    
    if (Test-Path $TempVSCodiumDir) {
        Remove-Item $TempVSCodiumDir -Recurse -Force
    }
    
    Write-Host "  Fetching latest VSCodium patches..." -ForegroundColor Cyan
    try {
        git clone --depth 1 https://github.com/VSCodium/vscodium.git $TempVSCodiumDir
        
        # Update patches (preserve user patches)
        Write-Host "  Updating VSCodium patches..." -ForegroundColor Cyan
        $VSCodiumPatchesDir = Join-Path $TempVSCodiumDir "patches"
        if (Test-Path $VSCodiumPatchesDir) {
            # Backup user patches
            $UserPatchesDir = Join-Path $RootDir "patches\user"
            $BackupUserPatches = Join-Path $env:TEMP "bax_user_patches_backup"
            
            if (Test-Path $UserPatchesDir) {
                Write-Host "    Backing up user patches..." -ForegroundColor Green
                if (Test-Path $BackupUserPatches) {
                    Remove-Item $BackupUserPatches -Recurse -Force
                }
                Copy-Item $UserPatchesDir $BackupUserPatches -Recurse -Force
            }
            
            # Update core patches from VSCodium
            Write-Host "    Updating core patches from VSCodium..." -ForegroundColor Green
            $PatchesDestDir = Join-Path $RootDir "patches"
            Copy-Item "$VSCodiumPatchesDir\*" $PatchesDestDir -Recurse -Force
            
            # Restore user patches
            if (Test-Path $BackupUserPatches) {
                Write-Host "    Restoring user patches..." -ForegroundColor Green
                New-Item -ItemType Directory -Path $UserPatchesDir -Force | Out-Null
                Copy-Item "$BackupUserPatches\*" $UserPatchesDir -Recurse -Force
                Remove-Item $BackupUserPatches -Recurse -Force
            }
        }
        
        # Update other VSCodium files
        Write-Host "  Updating VSCodium configuration files..." -ForegroundColor Cyan
        
        # Update key files that might have changed
        $FilesToUpdate = @("npmrc", "prepare_vscode.sh", "build.sh", "build_cli.sh", "get_repo.sh", "update_settings.sh")
        foreach ($file in $FilesToUpdate) {
            $sourceFile = Join-Path $TempVSCodiumDir $file
            $destFile = Join-Path $RootDir $file
            if (Test-Path $sourceFile) {
                Write-Host "    Updating $file..." -ForegroundColor Green
                Copy-Item $sourceFile $destFile -Force
            }
        }
        
        # Update dev scripts (except build.sh to preserve BAX settings)
        $DevSourceDir = Join-Path $TempVSCodiumDir "dev"
        $DevDestDir = Join-Path $RootDir "dev"
        if (Test-Path $DevSourceDir) {
            Write-Host "    Updating dev scripts..." -ForegroundColor Green
            $DevScripts = Get-ChildItem "$DevSourceDir\*.sh"
            foreach ($script in $DevScripts) {
                if ($script.Name -ne "build.sh") {  # Skip build.sh to preserve BAX settings
                    $destScript = Join-Path $DevDestDir $script.Name
                    Copy-Item $script.FullName $destScript -Force
                }
            }
        }
        
        Write-Host "VSCodium patches and customizations updated successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Error updating VSCodium patches: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "Continuing with VSCode update..." -ForegroundColor Yellow
    }
    finally {
        # Clean up
        if (Test-Path $TempVSCodiumDir) {
            Remove-Item $TempVSCodiumDir -Recurse -Force
        }
    }
}

function Invoke-UpdateProcess {
    Write-Host "Starting BAX-IDE update process..."
    Write-Host "Updating to VSCode $VsCodeQuality with BAX branding"
    Write-Host "OS: Windows | Arch: x64"
    Write-Host ""
    
    # Change to root directory
    Set-Location $RootDir
    
    # Create backup directory
    $BackupDir = Join-Path $RootDir "updating\backups\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    Write-Host "Backup created at: $BackupDir" -ForegroundColor Yellow
    
    # Update VSCodium patches if not skipped
    if (-not $SkipVSCodium) {
        Update-VSCodiumPatches
    }
    else {
        Write-Host "Skipping VSCodium patches update (-SkipVSCodium specified)" -ForegroundColor Cyan
    }
    
    # Remove existing vscode directory
    $VsCodeDir = Join-Path $RootDir "vscode"
    if (Test-Path $VsCodeDir) {
        Write-Host "Removing existing VSCode source..." -ForegroundColor Yellow
        Remove-Item $VsCodeDir -Recurse -Force
    }
    
    # Download VSCode source using Git Bash (reuses existing get_repo.sh logic)
    Write-Host "Downloading latest VSCode source..."
    try {
        $result = & "C:\Program Files\Git\bin\bash.exe" -c "cd '$RootDir' && VSCODE_QUALITY='$VsCodeQuality' VSCODE_LATEST='yes' bash get_repo.sh" 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to download VSCode source" -ForegroundColor Red
            Write-Host "Output: $result"
            exit 1
        }
        Write-Host "VSCode source downloaded successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Error downloading VSCode source: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
    
    # Update version tracking
    Write-Host "Updating version tracking..."
    $UpstreamDir = Join-Path $RootDir "upstream"
    if (-not (Test-Path $UpstreamDir)) {
        New-Item -ItemType Directory -Path $UpstreamDir | Out-Null
    }
    
    $VersionData = @{
        tag = $MsTag
        commit = $MsCommit
    }
    
    $VersionFile = Join-Path $UpstreamDir "$VsCodeQuality.json"
    $VersionData | ConvertTo-Json | Set-Content $VersionFile
    Write-Host "Updated upstream\$VsCodeQuality.json" -ForegroundColor Green
    
    # Apply BAX branding using existing scripts
    Write-Host "Applying BAX branding..."
    
    # Text branding
    Write-Host "  Applying text branding..."
    $BrandingScript = Join-Path $RootDir "branding\apply_bax_branding.sh"
    if (Test-Path $BrandingScript) {
        try {
            $result = & "C:\Program Files\Git\bin\bash.exe" -c "cd '$RootDir' && bash branding/apply_bax_branding.sh" 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  Text branding applied successfully" -ForegroundColor Green
            }
            else {
                Write-Host "  Text branding script had issues, but continuing..." -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "  Error running text branding script: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    # Icon branding
    if (-not $SkipIcons) {
        Write-Host "  Applying icon branding..."
        $IconScript = Join-Path $RootDir "branding\apply_bax_icons.sh"
        if (Test-Path $IconScript) {
            try {
                $result = & "C:\Program Files\Git\bin\bash.exe" -c "cd '$RootDir' && bash branding/apply_bax_icons.sh" 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  Icon branding applied successfully" -ForegroundColor Green
                }
                else {
                    Write-Host "  Icon branding script had issues, but continuing..." -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "  Error running icon branding script: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
    else {
        Write-Host "  Skipping icon branding (-SkipIcons specified)" -ForegroundColor Cyan
    }
    
    # Run prepare_vscode.sh
    Write-Host "  Preparing VSCode with BAX patches..."
    $PrepareScript = Join-Path $RootDir "prepare_vscode.sh"
    if (Test-Path $PrepareScript) {
        try {
            $result = & "C:\Program Files\Git\bin\bash.exe" -c "cd '$RootDir' && bash prepare_vscode.sh" 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  VSCode preparation completed" -ForegroundColor Green
            }
            else {
                Write-Host "  VSCode preparation failed" -ForegroundColor Red
                Write-Host "  Output: $result"
                return
            }
        }
        catch {
            Write-Host "  Error running prepare_vscode.sh: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    }
    
    # Clean build outputs
    Write-Host "Cleaning build outputs for fresh compilation..."
    $CleanedDirs = @()
    
    # Remove VSCode build directories
    $BuildDirs = Get-ChildItem -Directory -Name "VSCode-*", "vscode-reh-*" -ErrorAction SilentlyContinue
    foreach ($dir in $BuildDirs) {
        Write-Host "  Removing $dir" -ForegroundColor Yellow
        Remove-Item $dir -Recurse -Force
        $CleanedDirs += $dir
    }
    
    # Clean vscode/out and node_modules
    $OutDir = Join-Path $RootDir "vscode\out"
    if (Test-Path $OutDir) {
        Write-Host "  Cleaning vscode\out directory" -ForegroundColor Yellow
        Remove-Item $OutDir -Recurse -Force
        $CleanedDirs += "vscode\out"
    }
    
    $NodeModules = Join-Path $RootDir "vscode\node_modules"
    if (Test-Path $NodeModules) {
        Write-Host "  Cleaning vscode\node_modules for fresh dependencies" -ForegroundColor Yellow
        Remove-Item $NodeModules -Recurse -Force
        $CleanedDirs += "vscode\node_modules"
    }
    
    if ($CleanedDirs.Count -gt 0) {
        Write-Host "Cleaned $($CleanedDirs.Count) directories - next build will be fresh" -ForegroundColor Green
    }
    
    # Auto-build if requested
    if ($Build) {
        Write-Host "Starting automatic build..."
        $BuildScript = Join-Path $RootDir "dev\build.sh"
        if (Test-Path $BuildScript) {
            Write-Host "  Running build script..." -ForegroundColor Cyan
            & "C:\Program Files\Git\bin\bash.exe" -c "cd '$RootDir' && bash dev/build.sh"
        }
        else {
            Write-Host "  Build script not found at dev\build.sh" -ForegroundColor Red
        }
    }
    
    # Show completion summary
    Write-Host ""
    Write-Host "BAX-IDE Update Complete!" -ForegroundColor Green
    Write-Host "======================="
    Write-Host ""
    Write-Host "UPDATE SUMMARY:"
    Write-Host "  From: $CurrentTag ($($CurrentCommit.Substring(0,[Math]::Min(8,$CurrentCommit.Length))))"
    Write-Host "  To:   $MsTag ($($MsCommit.Substring(0,8)))"
    Write-Host "  Quality: $VsCodeQuality"
    Write-Host "  BAX Version: $ReleaseVersion"
    Write-Host ""
    
    if (-not $Build) {
        Write-Host "NEXT STEPS:"
        Write-Host "  1. Review changes: git diff" -ForegroundColor Yellow
        Write-Host "  2. Build BAX-IDE: .\dev\build.ps1 or bash dev/build.sh" -ForegroundColor Yellow
        Write-Host "  3. Test the build: Run the generated binary" -ForegroundColor Yellow
        Write-Host "  4. Commit changes: git add . && git commit -m 'Update to VSCode $MsTag'" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "TIP: Use -Build parameter next time to automatically start building" -ForegroundColor Cyan
    }
    
    Write-Host "Backup location: updating\backups\" -ForegroundColor Cyan
    Write-Host "For issues: https://github.com/Erg69/BAX-IDE/issues" -ForegroundColor Cyan
}

# Main execution
if ($Help) {
    Show-Help
    exit 0
}

try {
    Test-Prerequisites
    Get-CurrentVersion
    Get-LatestVersion
    
    if (Test-UpdateNeeded) {
        Invoke-UpdateProcess
    }
}
catch {
    Write-Host "Update failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
