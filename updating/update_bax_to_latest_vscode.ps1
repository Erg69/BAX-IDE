# BAX-IDE VSCode Update Script (PowerShell version)
# 
# This script automatically:
# 1. Fetches the latest VSCode version from Microsoft's update API
# 2. Downloads and updates the VSCode source code
# 3. Applies all BAX branding (text and icons)
# 4. Cleans build outputs to ensure fresh compilation
#
# Usage: .\updating\update_bax_to_latest_vscode.ps1 [options]
#
# Parameters:
#   -Insider      Update to VSCode Insider builds instead of stable
#   -Force        Force update even if already at latest version
#   -SkipIcons    Skip icon branding (faster for text-only updates)
#   -Build        Automatically start build after update
#   -Help         Show this help message
#
# Requirements:
#   - Git for Windows
#   - PowerShell 5.0+
#   - curl (included in Windows 10+)
#   - ImageMagick for icon generation
#
# Author: BAX-IDE Project
# License: MIT

[CmdletBinding()]
param(
    [switch]$Insider,
    [switch]$Force,
    [switch]$SkipIcons,
    [switch]$Build,
    [switch]$Help
)

# Colors for output (Windows compatible)
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Bold = "`e[1m"
$Reset = "`e[0m"

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir
$VsCodeQuality = if ($Insider) { "insider" } else { "stable" }

# BAX Configuration
$env:APP_NAME = "BAX"
$env:APP_NAME_LC = "bax"
$env:ASSETS_REPOSITORY = if ($Insider) { "Erg69/BAX-IDE-insiders" } else { "Erg69/BAX-IDE" }
$env:BINARY_NAME = if ($Insider) { "bax-insiders" } else { "bax" }
$env:GH_REPO_PATH = "Erg69/BAX-IDE"
$env:ORG_NAME = "BAX"
$env:CI_BUILD = "no"
$env:SHOULD_BUILD = "yes"
$env:SKIP_ASSETS = "yes"
$env:SKIP_SOURCE = "no"
$env:VSCODE_LATEST = "yes"
$env:VSCODE_SKIP_NODE_VERSION_CHECK = "yes"
$env:OS_NAME = "windows"
$env:VSCODE_ARCH = "x64"  # Default for Windows
$env:VSCODE_QUALITY = $VsCodeQuality

function Show-Help {
    Write-Host "${Bold}${Blue}BAX-IDE VSCode Update Script (PowerShell)${Reset}"
    Write-Host "${Blue}============================================${Reset}"
    Write-Host ""
    Write-Host "${Bold}DESCRIPTION:${Reset}"
    Write-Host "  Automatically updates BAX-IDE to the latest VSCode version while preserving BAX branding."
    Write-Host ""
    Write-Host "${Bold}USAGE:${Reset}"
    Write-Host "  .\updating\update_bax_to_latest_vscode.ps1 [parameters]"
    Write-Host ""
    Write-Host "${Bold}PARAMETERS:${Reset}"
    Write-Host "  -Insider      Update to VSCode Insider builds instead of stable"
    Write-Host "  -Force        Force update even if already at latest version"
    Write-Host "  -SkipIcons    Skip icon branding (faster for text-only updates)"
    Write-Host "  -Build        Automatically start build after update"
    Write-Host "  -Help         Show this help message"
    Write-Host ""
    Write-Host "${Bold}EXAMPLES:${Reset}"
    Write-Host "  .\updating\update_bax_to_latest_vscode.ps1"
    Write-Host "  .\updating\update_bax_to_latest_vscode.ps1 -Insider -Build"
    Write-Host "  .\updating\update_bax_to_latest_vscode.ps1 -Force -SkipIcons"
    Write-Host ""
    Write-Host "${Bold}REQUIREMENTS:${Reset}"
    Write-Host "  - Git for Windows"
    Write-Host "  - PowerShell 5.0+"
    Write-Host "  - ImageMagick (for icon generation)"
}

function Test-Prerequisites {
    Write-Host "${Blue}🔍 Checking prerequisites...${Reset}"
    
    $MissingTools = @()
    
    # Check for Git
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        $MissingTools += "git"
    }
    
    # Check for curl (should be available in Windows 10+)
    if (-not (Get-Command curl -ErrorAction SilentlyContinue)) {
        $MissingTools += "curl"
    }
    
    # Check for ImageMagick if not skipping icons
    if (-not $SkipIcons) {
        if (-not (Get-Command convert -ErrorAction SilentlyContinue) -and -not (Get-Command magick -ErrorAction SilentlyContinue)) {
            $MissingTools += "ImageMagick (convert or magick command)"
        }
    }
    
    if ($MissingTools.Count -gt 0) {
        Write-Host "${Red}Missing required tools:${Reset}"
        foreach ($tool in $MissingTools) {
            Write-Host "  - $tool"
        }
        Write-Host ""
        Write-Host "${Yellow}Please install the missing tools and try again.${Reset}"
        exit 1
    }
    
    Write-Host "${Green}All prerequisites satisfied${Reset}"
}

function Get-CurrentVersion {
    Write-Host "${Blue}📋 Getting current version information...${Reset}"
    
    $VersionFile = Join-Path $RootDir "upstream\$VsCodeQuality.json"
    
    if (Test-Path $VersionFile) {
        try {
            $VersionInfo = Get-Content $VersionFile | ConvertFrom-Json
            $script:CurrentCommit = $VersionInfo.commit
            $script:CurrentTag = $VersionInfo.tag
            Write-Host "  Current commit: ${Yellow}$CurrentCommit${Reset}"
            Write-Host "  Current tag: ${Yellow}$CurrentTag${Reset}"
        }
        catch {
            Write-Host "${Yellow}  Error reading version file, assuming no current version${Reset}"
            $script:CurrentCommit = "unknown"
            $script:CurrentTag = "unknown"
        }
    }
    else {
        Write-Host "${Yellow}  No current version information found${Reset}"
        $script:CurrentCommit = "unknown"
        $script:CurrentTag = "unknown"
    }
}

function Get-LatestVersion {
    Write-Host "${Blue}🌐 Fetching latest VSCode $VsCodeQuality version...${Reset}"
    
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
        
        Write-Host "  Latest commit: ${Green}$MsCommit${Reset}"
        Write-Host "  Latest tag: ${Green}$MsTag${Reset}"
        Write-Host "  BAX release version: ${Green}$ReleaseVersion${Reset}"
    }
    catch {
        Write-Host "${Red}❌ Failed to fetch version information from Microsoft's API${Reset}"
        Write-Host "Error: $($_.Exception.Message)"
        exit 1
    }
}

function Test-UpdateNeeded {
    Write-Host "${Blue}🔄 Checking if update is needed...${Reset}"
    
    if ($Force) {
        Write-Host "${Yellow}  Force update requested - proceeding regardless of version${Reset}"
        return $true
    }
    
    if ($CurrentCommit -eq $MsCommit) {
        Write-Host "${Green}✅ Already at latest version ($MsCommit)${Reset}"
        Write-Host "${Blue}  Use -Force to update anyway${Reset}"
        return $false
    }
    
    Write-Host "${Green}✅ Update available: $CurrentCommit → $MsCommit${Reset}"
    return $true
}

function New-Backup {
    Write-Host "${Blue}💾 Creating backup of current state...${Reset}"
    
    # Create backup directory with timestamp
    $BackupDir = Join-Path $RootDir "updating\backups\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    
    # Backup important files
    $VersionFile = Join-Path $RootDir "upstream\$VsCodeQuality.json"
    if (Test-Path $VersionFile) {
        Copy-Item $VersionFile $BackupDir
        Write-Host "  ${Green}✓${Reset} Backed up upstream version info"
    }
    
    $VsCodeDir = Join-Path $RootDir "vscode"
    if (Test-Path $VsCodeDir) {
        Write-Host "  ${Yellow}⚠️${Reset} VSCode source directory exists - will be replaced"
    }
    
    Write-Host "  ${Green}✓${Reset} Backup created at: ${Yellow}$BackupDir${Reset}"
}

function Get-VsCodeSource {
    Write-Host "${Blue}⬇️ Downloading latest VSCode source...${Reset}"
    
    Set-Location $RootDir
    
    # Remove existing vscode directory
    $VsCodeDir = Join-Path $RootDir "vscode"
    if (Test-Path $VsCodeDir) {
        Write-Host "  ${Yellow}🗑️${Reset} Removing existing VSCode source..."
        Remove-Item $VsCodeDir -Recurse -Force
    }
    
    # Create vscode directory and initialize git repo
    New-Item -ItemType Directory -Path $VsCodeDir | Out-Null
    Set-Location $VsCodeDir
    
    Write-Host "  ${Blue}📦${Reset} Initializing git repository..."
    git init -q
    git remote add origin https://github.com/Microsoft/vscode.git
    
    Write-Host "  ${Blue}📥${Reset} Fetching VSCode source (commit: $MsCommit)..."
    git fetch --depth 1 origin $MsCommit
    git checkout FETCH_HEAD
    
    Write-Host "  ${Green}✅${Reset} VSCode source downloaded successfully"
    
    Set-Location $RootDir
}

function Update-VersionTracking {
    Write-Host "${Blue}📝 Updating version tracking...${Reset}"
    
    # Create upstream directory if it doesn't exist
    $UpstreamDir = Join-Path $RootDir "upstream"
    if (-not (Test-Path $UpstreamDir)) {
        New-Item -ItemType Directory -Path $UpstreamDir | Out-Null
    }
    
    # Update upstream version file
    $VersionData = @{
        tag = $MsTag
        commit = $MsCommit
    }
    
    $VersionFile = Join-Path $UpstreamDir "$VsCodeQuality.json"
    $VersionData | ConvertTo-Json | Set-Content $VersionFile
    
    Write-Host "  ${Green}✓${Reset} Updated upstream\$VsCodeQuality.json"
}

function Invoke-BaxBranding {
    Write-Host "${Blue}🎨 Applying BAX branding...${Reset}"
    
    Set-Location $RootDir
    
    # Apply text branding using Git Bash (since the script is in bash)
    Write-Host "  ${Blue}📝${Reset} Applying text branding..."
    $BrandingScript = Join-Path $RootDir "branding\apply_bax_branding.sh"
    if (Test-Path $BrandingScript) {
        try {
            # Use Git Bash to run the script
            $result = & "C:\Program Files\Git\bin\bash.exe" $BrandingScript 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ${Green}✅${Reset} Text branding applied successfully"
            }
            else {
                Write-Host "  ${Yellow}⚠️${Reset} Text branding script had issues, but continuing..."
                Write-Host "  Output: $result"
            }
        }
        catch {
            Write-Host "  ${Yellow}⚠️${Reset} Error running text branding script: $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "  ${Yellow}⚠️${Reset} Text branding script not found, skipping..."
    }
    
    # Apply icon branding if not skipped
    if (-not $SkipIcons) {
        Write-Host "  ${Blue}🖼️${Reset} Applying icon branding..."
        $IconScript = Join-Path $RootDir "branding\apply_bax_icons.sh"
        if (Test-Path $IconScript) {
            try {
                $result = & "C:\Program Files\Git\bin\bash.exe" $IconScript 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ${Green}✅${Reset} Icon branding applied successfully"
                }
                else {
                    Write-Host "  ${Yellow}⚠️${Reset} Icon branding script had issues, but continuing..."
                    Write-Host "  Output: $result"
                }
            }
            catch {
                Write-Host "  ${Yellow}⚠️${Reset} Error running icon branding script: $($_.Exception.Message)"
            }
        }
        else {
            Write-Host "  ${Yellow}⚠️${Reset} Icon branding script not found, skipping..."
        }
    }
    else {
        Write-Host "  ${Blue}⏭️${Reset} Skipping icon branding (-SkipIcons specified)"
    }
    
    # Run prepare_vscode.sh
    Write-Host "  ${Blue}🔧${Reset} Preparing VSCode with BAX patches..."
    $PrepareScript = Join-Path $RootDir "prepare_vscode.sh"
    if (Test-Path $PrepareScript) {
        try {
            $result = & "C:\Program Files\Git\bin\bash.exe" $PrepareScript 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ${Green}✅${Reset} VSCode preparation completed"
            }
            else {
                Write-Host "  ${Red}❌${Reset} VSCode preparation failed"
                Write-Host "  Output: $result"
                return
            }
        }
        catch {
            Write-Host "  ${Red}❌${Reset} Error running prepare_vscode.sh: $($_.Exception.Message)"
            return
        }
    }
    else {
        Write-Host "  ${Yellow}⚠️${Reset} prepare_vscode.sh not found, skipping patch application..."
    }
    
    # Apply final branding
    Write-Host "  ${Blue}🎯${Reset} Applying critical final branding..."
    try {
        $finalBrandingCmd = "source branding/apply_bax_branding.sh && apply_final_branding"
        $result = & "C:\Program Files\Git\bin\bash.exe" -c $finalBrandingCmd 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ${Green}✅${Reset} Final branding applied successfully"
        }
        else {
            Write-Host "  ${Yellow}⚠️${Reset} Final branding had issues, but continuing..."
        }
    }
    catch {
        Write-Host "  ${Yellow}⚠️${Reset} Error applying final branding: $($_.Exception.Message)"
    }
}

function Clear-BuildOutputs {
    Write-Host "${Blue}🧹 Cleaning build outputs for fresh compilation...${Reset}"
    
    Set-Location $RootDir
    
    $CleanedDirs = @()
    
    # Remove VSCode build directories
    $BuildDirs = Get-ChildItem -Directory -Name "VSCode-*", "vscode-reh-*" -ErrorAction SilentlyContinue
    foreach ($dir in $BuildDirs) {
        Write-Host "  ${Green}🗑️${Reset} Removing ${Yellow}$dir${Reset}"
        Remove-Item $dir -Recurse -Force
        $CleanedDirs += $dir
    }
    
    # Clean vscode/out directory
    $OutDir = Join-Path $RootDir "vscode\out"
    if (Test-Path $OutDir) {
        Write-Host "  ${Green}🗑️${Reset} Cleaning vscode\out directory"
        Remove-Item $OutDir -Recurse -Force
        $CleanedDirs += "vscode\out"
    }
    
    # Clean node_modules
    $NodeModules = Join-Path $RootDir "vscode\node_modules"
    if (Test-Path $NodeModules) {
        Write-Host "  ${Green}🗑️${Reset} Cleaning vscode\node_modules for fresh dependencies"
        Remove-Item $NodeModules -Recurse -Force
        $CleanedDirs += "vscode\node_modules"
    }
    
    if ($CleanedDirs.Count -gt 0) {
        Write-Host "  ${Green}✅${Reset} Cleaned $($CleanedDirs.Count) directories - next build will be fresh"
    }
    else {
        Write-Host "  ${Blue}ℹ️${Reset} No build outputs to clean"
    }
}

function Start-AutoBuild {
    if ($Build) {
        Write-Host "${Blue}🔨 Starting automatic build...${Reset}"
        
        $BuildScript = Join-Path $RootDir "dev\build.sh"
        if (Test-Path $BuildScript) {
            Write-Host "  ${Blue}🚀${Reset} Running build script..."
            Set-Location $RootDir
            & "C:\Program Files\Git\bin\bash.exe" $BuildScript
        }
        else {
            Write-Host "  ${Red}❌${Reset} Build script not found at dev\build.sh"
        }
    }
}

function Show-CompletionSummary {
    Write-Host ""
    Write-Host "${Bold}${Green}🎉 BAX-IDE Update Complete!${Reset}"
    Write-Host "${Green}================================${Reset}"
    Write-Host ""
    Write-Host "${Bold}UPDATE SUMMARY:${Reset}"
    Write-Host "  ${Blue}From:${Reset} $CurrentTag ($($CurrentCommit.Substring(0,8)))"
    Write-Host "  ${Blue}To:${Reset}   $MsTag ($($MsCommit.Substring(0,8)))"
    Write-Host "  ${Blue}Quality:${Reset} $VsCodeQuality"
    Write-Host "  ${Blue}BAX Version:${Reset} $ReleaseVersion"
    Write-Host ""
    
    if (-not $Build) {
        Write-Host "${Bold}NEXT STEPS:${Reset}"
        Write-Host "  1. ${Yellow}Review changes:${Reset} git diff"
        Write-Host "  2. ${Yellow}Build BAX-IDE:${Reset} .\dev\build.ps1 or bash dev/build.sh"
        Write-Host "  3. ${Yellow}Test the build:${Reset} Run the generated binary"
        Write-Host "  4. ${Yellow}Commit changes:${Reset} git add . && git commit -m 'Update to VSCode $MsTag'"
        Write-Host ""
        Write-Host "${Blue}💡 TIP:${Reset} Use ${Yellow}-Build${Reset} parameter next time to automatically start building"
    }
    
    Write-Host "${Blue}📁 Backup location:${Reset} updating\backups\"
    Write-Host "${Blue}🔗 For issues:${Reset} https://github.com/Erg69/BAX-IDE/issues"
}

# Main execution
function Main {
    if ($Help) {
        Show-Help
        return
    }
    
    Write-Host "${Bold}${Blue}"
    Write-Host "╔══════════════════════════════════════════════════════════════╗"
    Write-Host "║                   BAX-IDE Update Script                     ║"
    Write-Host "║              Keep BAX-IDE up to date with VSCode            ║"
    Write-Host "║                    (PowerShell Version)                     ║"
    Write-Host "╚══════════════════════════════════════════════════════════════╝"
    Write-Host "${Reset}"
    Write-Host "${Blue}Updating to VSCode $VsCodeQuality with BAX branding${Reset}"
    Write-Host "${Blue}OS: ${Yellow}Windows${Reset} | Arch: ${Yellow}x64${Reset}"
    Write-Host ""
    
    # Change to root directory
    Set-Location $RootDir
    
    try {
        # Execute update steps
        Test-Prerequisites
        Get-CurrentVersion
        Get-LatestVersion
        
        if (-not (Test-UpdateNeeded)) {
            return
        }
        
        New-Backup
        Get-VsCodeSource
        Update-VersionTracking
        Invoke-BaxBranding
        Clear-BuildOutputs
        Start-AutoBuild
        Show-CompletionSummary
    }
    catch {
        Write-Host "${Red}❌ Update failed: $($_.Exception.Message)${Reset}"
        exit 1
    }
}

# Handle Ctrl+C gracefully
$null = Register-EngineEvent PowerShell.Exiting -Action {
    Write-Host "`n${Red}Update interrupted by user${Reset}"
}

# Run main function
Main
