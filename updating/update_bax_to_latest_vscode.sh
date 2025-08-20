#!/usr/bin/env bash
# BAX-IDE VSCode Update Script
# 
# This script automatically:
# 1. Fetches the latest VSCode version from Microsoft's update API
# 2. Downloads and updates the VSCode source code
# 3. Applies all BAX branding (text and icons)
# 4. Cleans build outputs to ensure fresh compilation
#
# Usage: bash updating/update_bax_to_latest_vscode.sh [options]
#
# Options:
#   -i, --insider       Update to VSCode Insider builds instead of stable
#   -f, --force         Force update even if already at latest version
#   -s, --skip-icons    Skip icon branding (faster for text-only updates)
#   -v, --skip-vscodium Skip VSCodium patches update (VSCode only)
#   -b, --build         Automatically start build after update
#   -h, --help          Show this help message
#
# Requirements:
#   - git
#   - curl
#   - jq
#   - ImageMagick (convert command) for icon generation
#
# Author: BAX-IDE Project
# License: MIT

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VSCODE_QUALITY="stable"
SKIP_ICONS="no"
SKIP_VSCODIUM="no"
FORCE_UPDATE="no"
AUTO_BUILD="no"

# BAX Configuration (matches branding scripts)
export APP_NAME="BAX"
export APP_NAME_LC="bax"
export ASSETS_REPOSITORY="Erg69/BAX-IDE"
export BINARY_NAME="bax"
export GH_REPO_PATH="Erg69/BAX-IDE"
export ORG_NAME="BAX"
export CI_BUILD="no"
export SHOULD_BUILD="yes"
export SKIP_ASSETS="yes"
export SKIP_SOURCE="no"
export VSCODE_LATEST="yes"
export VSCODE_SKIP_NODE_VERSION_CHECK="yes"

# Platform detection (matches dev/build.sh)
case "${OSTYPE}" in
  darwin*)
    export OS_NAME="osx"
    ;;
  msys* | cygwin*)
    export OS_NAME="windows"
    ;;
  *)
    export OS_NAME="linux"
    ;;
esac

# Architecture detection
UNAME_ARCH=$( uname -m )
if [[ "${UNAME_ARCH}" == "aarch64" || "${UNAME_ARCH}" == "arm64" ]]; then
  export VSCODE_ARCH="arm64"
elif [[ "${UNAME_ARCH}" == "ppc64le" ]]; then
  export VSCODE_ARCH="ppc64le"
elif [[ "${UNAME_ARCH}" == "riscv64" ]]; then
  export VSCODE_ARCH="riscv64"
elif [[ "${UNAME_ARCH}" == "loongarch64" ]]; then
  export VSCODE_ARCH="loong64"
elif [[ "${UNAME_ARCH}" == "s390x" ]]; then
  export VSCODE_ARCH="s390x"
else
  export VSCODE_ARCH="x64"
fi

# Function to show help
show_help() {
    echo -e "${BOLD}${BLUE}BAX-IDE VSCode Update Script${NC}"
    echo -e "${BLUE}==============================${NC}"
    echo ""
    echo -e "${BOLD}DESCRIPTION:${NC}"
    echo "  Automatically updates BAX-IDE to the latest VSCode version while preserving BAX branding."
    echo ""
    echo -e "${BOLD}USAGE:${NC}"
    echo "  bash updating/update_bax_to_latest_vscode.sh [options]"
    echo ""
    echo -e "${BOLD}OPTIONS:${NC}"
    echo "  -i, --insider       Update to VSCode Insider builds instead of stable"
    echo "  -f, --force         Force update even if already at latest version"
    echo "  -s, --skip-icons    Skip icon branding (faster for text-only updates)"
    echo "  -v, --skip-vscodium Skip VSCodium patches update (VSCode only)"
    echo "  -b, --build         Automatically start build after update"
    echo "  -h, --help          Show this help message"
    echo ""
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo "  bash updating/update_bax_to_latest_vscode.sh"
    echo "  bash updating/update_bax_to_latest_vscode.sh --insider --build"
    echo "  bash updating/update_bax_to_latest_vscode.sh --force --skip-icons"
    echo ""
    echo -e "${BOLD}REQUIREMENTS:${NC}"
    echo "  - git, curl, jq (for VSCode API)"
    echo "  - ImageMagick (convert command) for icon generation"
    echo "  - Sufficient disk space for VSCode source download"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--insider)
            VSCODE_QUALITY="insider"
            export ASSETS_REPOSITORY="Erg69/BAX-IDE-insiders"
            export BINARY_NAME="bax-insiders"
            shift
            ;;
        -f|--force)
            FORCE_UPDATE="yes"
            shift
            ;;
        -s|--skip-icons)
            SKIP_ICONS="yes"
            shift
            ;;
        -v|--skip-vscodium)
            SKIP_VSCODIUM="yes"
            shift
            ;;
        -b|--build)
            AUTO_BUILD="yes"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
done

export VSCODE_QUALITY

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    local missing_tools=()
    
    # Check for required tools
    for tool in git curl jq; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    # Check for ImageMagick if not skipping icons
    if [[ "$SKIP_ICONS" != "yes" ]]; then
        if ! command -v convert &> /dev/null && ! command -v magick &> /dev/null; then
            missing_tools+=("imagemagick (convert or magick command)")
        fi
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Missing required tools:${NC}"
        for tool in "${missing_tools[@]}"; do
            echo -e "  - $tool"
        done
        echo ""
        echo -e "${YELLOW}Please install the missing tools and try again.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All prerequisites satisfied${NC}"
}

# Function to get current version info
get_current_version() {
    echo -e "${BLUE}📋 Getting current version information...${NC}"
    
    if [[ -f "$ROOT_DIR/upstream/${VSCODE_QUALITY}.json" ]]; then
        CURRENT_COMMIT=$(jq -r '.commit' "$ROOT_DIR/upstream/${VSCODE_QUALITY}.json" 2>/dev/null || echo "unknown")
        CURRENT_TAG=$(jq -r '.tag' "$ROOT_DIR/upstream/${VSCODE_QUALITY}.json" 2>/dev/null || echo "unknown")
        echo -e "  Current commit: ${YELLOW}${CURRENT_COMMIT}${NC}"
        echo -e "  Current tag: ${YELLOW}${CURRENT_TAG}${NC}"
    else
        echo -e "${YELLOW}  No current version information found${NC}"
        CURRENT_COMMIT="unknown"
        CURRENT_TAG="unknown"
    fi
}

# Function to get latest VSCode version
get_latest_version() {
    echo -e "${BLUE}🌐 Fetching latest VSCode ${VSCODE_QUALITY} version...${NC}"
    
    # Use Microsoft's update API to get latest version info
    UPDATE_INFO=$(curl --silent --fail "https://update.code.visualstudio.com/api/update/darwin/${VSCODE_QUALITY}/0000000000000000000000000000000000000000" 2>/dev/null)
    
    if [[ -z "$UPDATE_INFO" ]]; then
        echo -e "${RED}❌ Failed to fetch version information from Microsoft's API${NC}"
        exit 1
    fi
    
    export MS_COMMIT=$(echo "$UPDATE_INFO" | jq -r '.version')
    export MS_TAG=$(echo "$UPDATE_INFO" | jq -r '.name')
    
    # Clean up insider tag
    if [[ "$VSCODE_QUALITY" == "insider" ]]; then
        MS_TAG="${MS_TAG/-insider/}"
    fi
    
    # Generate BAX release version with timestamp
    TIME_PATCH=$(printf "%04d" $(($(date +%-j) * 24 + $(date +%-H))))
    if [[ "$VSCODE_QUALITY" == "insider" ]]; then
        export RELEASE_VERSION="${MS_TAG}${TIME_PATCH}-insider"
    else
        export RELEASE_VERSION="${MS_TAG}${TIME_PATCH}"
    fi
    
    echo -e "  Latest commit: ${GREEN}${MS_COMMIT}${NC}"
    echo -e "  Latest tag: ${GREEN}${MS_TAG}${NC}"
    echo -e "  BAX release version: ${GREEN}${RELEASE_VERSION}${NC}"
}

# Function to check if update is needed
check_update_needed() {
    echo -e "${BLUE}🔄 Checking if update is needed...${NC}"
    
    if [[ "$FORCE_UPDATE" == "yes" ]]; then
        echo -e "${YELLOW}  Force update requested - proceeding regardless of version${NC}"
        return 0
    fi
    
    if [[ "$CURRENT_COMMIT" == "$MS_COMMIT" ]]; then
        echo -e "${GREEN}✅ Already at latest version (${MS_COMMIT})${NC}"
        echo -e "${BLUE}  Use --force to update anyway${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Update available: ${CURRENT_COMMIT} → ${MS_COMMIT}${NC}"
    return 0
}

# Function to backup current state
backup_current_state() {
    echo -e "${BLUE}💾 Creating backup of current state...${NC}"
    
    # Create backup directory with timestamp
    BACKUP_DIR="$ROOT_DIR/updating/backups/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup important files
    if [[ -f "$ROOT_DIR/upstream/${VSCODE_QUALITY}.json" ]]; then
        cp "$ROOT_DIR/upstream/${VSCODE_QUALITY}.json" "$BACKUP_DIR/"
        echo -e "  ${GREEN}✓${NC} Backed up upstream version info"
    fi
    
    if [[ -d "$ROOT_DIR/vscode" ]]; then
        echo -e "  ${YELLOW}⚠️${NC} VSCode source directory exists - will be replaced"
    fi
    
    echo -e "  ${GREEN}✓${NC} Backup created at: ${YELLOW}${BACKUP_DIR}${NC}"
}

# Function to update VSCodium patches and customizations
update_vscodium_patches() {
    echo -e "${BLUE}🔄 Updating VSCodium patches and customizations...${NC}"
    
    cd "$ROOT_DIR"
    
    # Create a temporary directory for VSCodium updates
    TEMP_VSCODIUM_DIR="temp_vscodium_update"
    
    if [[ -d "$TEMP_VSCODIUM_DIR" ]]; then
        rm -rf "$TEMP_VSCODIUM_DIR"
    fi
    
    echo -e "  ${BLUE}📥${NC} Fetching latest VSCodium patches..."
    git clone --depth 1 https://github.com/VSCodium/vscodium.git "$TEMP_VSCODIUM_DIR"
    
    # Update patches (preserve user patches)
    echo -e "  ${BLUE}🔧${NC} Updating VSCodium patches..."
    if [[ -d "$TEMP_VSCODIUM_DIR/patches" ]]; then
        # Backup user patches
        if [[ -d "patches/user" ]]; then
            echo -e "    ${GREEN}💾${NC} Backing up user patches..."
            cp -r "patches/user" "/tmp/bax_user_patches_backup" 2>/dev/null || true
        fi
        
        # Update core patches from VSCodium
        echo -e "    ${GREEN}✓${NC} Updating core patches from VSCodium..."
        cp -r "$TEMP_VSCODIUM_DIR/patches"/* "patches/" 2>/dev/null || true
        
        # Restore user patches
        if [[ -d "/tmp/bax_user_patches_backup" ]]; then
            echo -e "    ${GREEN}✓${NC} Restoring user patches..."
            mkdir -p "patches/user"
            cp -r "/tmp/bax_user_patches_backup"/* "patches/user/" 2>/dev/null || true
            rm -rf "/tmp/bax_user_patches_backup"
        fi
    fi
    
    # Update other VSCodium files that might have changed
    echo -e "  ${BLUE}📋${NC} Updating VSCodium configuration files..."
    
    # Update npmrc if it exists
    if [[ -f "$TEMP_VSCODIUM_DIR/npmrc" ]]; then
        echo -e "    ${GREEN}✓${NC} Updating npmrc..."
        cp "$TEMP_VSCODIUM_DIR/npmrc" "npmrc"
    fi
    
    # Update prepare_vscode.sh (but preserve BAX customizations)
    if [[ -f "$TEMP_VSCODIUM_DIR/prepare_vscode.sh" ]]; then
        echo -e "    ${GREEN}✓${NC} Updating prepare_vscode.sh..."
        cp "$TEMP_VSCODIUM_DIR/prepare_vscode.sh" "prepare_vscode.sh"
    fi
    
    # Update build scripts (preserve BAX-specific settings)
    for script in "build.sh" "build_cli.sh" "get_repo.sh" "update_settings.sh"; do
        if [[ -f "$TEMP_VSCODIUM_DIR/$script" ]]; then
            echo -e "    ${GREEN}✓${NC} Updating $script..."
            cp "$TEMP_VSCODIUM_DIR/$script" "$script"
        fi
    done
    
    # Update dev scripts
    if [[ -d "$TEMP_VSCODIUM_DIR/dev" ]]; then
        echo -e "    ${GREEN}✓${NC} Updating dev scripts..."
        for dev_script in "$TEMP_VSCODIUM_DIR/dev"/*.sh; do
            if [[ -f "$dev_script" ]]; then
                script_name=$(basename "$dev_script")
                # Skip build.sh to avoid overwriting BAX-specific settings
                if [[ "$script_name" != "build.sh" ]]; then
                    cp "$dev_script" "dev/$script_name"
                fi
            fi
        done
    fi
    
    # Clean up
    rm -rf "$TEMP_VSCODIUM_DIR"
    
    echo -e "  ${GREEN}✅${NC} VSCodium patches and customizations updated successfully"
}

# Function to download latest VSCode source
download_vscode_source() {
    echo -e "${BLUE}⬇️ Downloading latest VSCode source...${NC}"
    
    cd "$ROOT_DIR"
    
    # Remove existing vscode directory
    if [[ -d "vscode" ]]; then
        echo -e "  ${YELLOW}🗑️${NC} Removing existing VSCode source..."
        rm -rf vscode
    fi
    
    # Use the existing get_repo.sh script which handles this properly
    echo -e "  ${BLUE}📦${NC} Using get_repo.sh to download VSCode source..."
    if bash get_repo.sh; then
        echo -e "  ${GREEN}✅${NC} VSCode source downloaded successfully"
    else
        echo -e "  ${RED}❌${NC} Failed to download VSCode source"
        exit 1
    fi
}

# Function to update version tracking
update_version_tracking() {
    echo -e "${BLUE}📝 Updating version tracking...${NC}"
    
    # Update upstream version file
    mkdir -p "$ROOT_DIR/upstream"
    
    cat > "$ROOT_DIR/upstream/${VSCODE_QUALITY}.json" << EOF
{
  "tag": "${MS_TAG}",
  "commit": "${MS_COMMIT}"
}
EOF
    
    echo -e "  ${GREEN}✓${NC} Updated upstream/${VSCODE_QUALITY}.json"
    
    # Export variables for other scripts
    export MS_TAG
    export MS_COMMIT
    export RELEASE_VERSION
}

# Function to apply BAX branding
apply_bax_branding() {
    echo -e "${BLUE}🎨 Applying BAX branding...${NC}"
    
    cd "$ROOT_DIR"
    
    # First apply text branding
    echo -e "  ${BLUE}📝${NC} Applying text branding..."
    if [[ -f "branding/apply_bax_branding.sh" ]]; then
        if bash branding/apply_bax_branding.sh; then
            echo -e "  ${GREEN}✅${NC} Text branding applied successfully"
        else
            echo -e "  ${YELLOW}⚠️${NC} Text branding script had issues, but continuing..."
        fi
    else
        echo -e "  ${YELLOW}⚠️${NC} Text branding script not found, skipping..."
    fi
    
    # Apply icon branding if not skipped
    if [[ "$SKIP_ICONS" != "yes" ]]; then
        echo -e "  ${BLUE}🖼️${NC} Applying icon branding..."
        if [[ -f "branding/apply_bax_icons.sh" ]]; then
            if bash branding/apply_bax_icons.sh; then
                echo -e "  ${GREEN}✅${NC} Icon branding applied successfully"
            else
                echo -e "  ${YELLOW}⚠️${NC} Icon branding script had issues, but continuing..."
            fi
        else
            echo -e "  ${YELLOW}⚠️${NC} Icon branding script not found, skipping..."
        fi
    else
        echo -e "  ${BLUE}⏭️${NC} Skipping icon branding (--skip-icons specified)"
    fi
    
    # Run prepare_vscode.sh to apply patches and configuration
    echo -e "  ${BLUE}🔧${NC} Preparing VSCode with BAX patches..."
    if [[ -f "prepare_vscode.sh" ]]; then
        if bash prepare_vscode.sh; then
            echo -e "  ${GREEN}✅${NC} VSCode preparation completed"
        else
            echo -e "  ${RED}❌${NC} VSCode preparation failed"
            return 1
        fi
    else
        echo -e "  ${YELLOW}⚠️${NC} prepare_vscode.sh not found, skipping patch application..."
    fi
    
    # Apply final branding after prepare_vscode.sh (critical for product.json)
    echo -e "  ${BLUE}🎯${NC} Applying critical final branding..."
    if [[ -f "branding/apply_bax_branding.sh" ]]; then
        # Source the branding script and call the final branding function
        source branding/apply_bax_branding.sh
        if declare -f apply_final_branding > /dev/null; then
            if apply_final_branding; then
                echo -e "  ${GREEN}✅${NC} Final branding applied successfully"
            else
                echo -e "  ${YELLOW}⚠️${NC} Final branding had issues, but continuing..."
            fi
        else
            echo -e "  ${YELLOW}⚠️${NC} apply_final_branding function not found, skipping..."
        fi
    fi
}

# Function to clean build outputs
clean_build_outputs() {
    echo -e "${BLUE}🧹 Cleaning build outputs for fresh compilation...${NC}"
    
    cd "$ROOT_DIR"
    
    local cleaned_dirs=()
    
    # Remove VSCode build directories
    for build_dir in VSCode-* vscode-reh-*; do
        if [[ -d "$build_dir" ]]; then
            echo -e "  ${GREEN}🗑️${NC} Removing ${YELLOW}$build_dir${NC}"
            rm -rf "$build_dir"
            cleaned_dirs+=("$build_dir")
        fi
    done
    
    # Clean vscode/out directory if it exists
    if [[ -d "vscode/out" ]]; then
        echo -e "  ${GREEN}🗑️${NC} Cleaning vscode/out directory"
        rm -rf "vscode/out"
        cleaned_dirs+=("vscode/out")
    fi
    
    # Clean node_modules to force fresh npm install
    if [[ -d "vscode/node_modules" ]]; then
        echo -e "  ${GREEN}🗑️${NC} Cleaning vscode/node_modules for fresh dependencies"
        rm -rf "vscode/node_modules"
        cleaned_dirs+=("vscode/node_modules")
    fi
    
    if [[ ${#cleaned_dirs[@]} -gt 0 ]]; then
        echo -e "  ${GREEN}✅${NC} Cleaned ${#cleaned_dirs[@]} directories - next build will be fresh"
    else
        echo -e "  ${BLUE}ℹ️${NC} No build outputs to clean"
    fi
}

# Function to start build if requested
start_build() {
    if [[ "$AUTO_BUILD" == "yes" ]]; then
        echo -e "${BLUE}🔨 Starting automatic build...${NC}"
        
        if [[ -f "$ROOT_DIR/dev/build.sh" ]]; then
            echo -e "  ${BLUE}🚀${NC} Running build script..."
            cd "$ROOT_DIR"
            bash dev/build.sh
        else
            echo -e "  ${RED}❌${NC} Build script not found at dev/build.sh"
            return 1
        fi
    fi
}

# Function to show completion summary
show_completion_summary() {
    echo ""
    echo -e "${BOLD}${GREEN}🎉 BAX-IDE Update Complete!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    echo -e "${BOLD}UPDATE SUMMARY:${NC}"
    echo -e "  ${BLUE}From:${NC} ${CURRENT_TAG} (${CURRENT_COMMIT:0:8})"
    echo -e "  ${BLUE}To:${NC}   ${MS_TAG} (${MS_COMMIT:0:8})"
    echo -e "  ${BLUE}Quality:${NC} ${VSCODE_QUALITY}"
    echo -e "  ${BLUE}BAX Version:${NC} ${RELEASE_VERSION}"
    echo ""
    
    if [[ "$AUTO_BUILD" != "yes" ]]; then
        echo -e "${BOLD}NEXT STEPS:${NC}"
        echo -e "  1. ${YELLOW}Review changes:${NC} git diff"
        echo -e "  2. ${YELLOW}Build BAX-IDE:${NC} bash dev/build.sh"
        echo -e "  3. ${YELLOW}Test the build:${NC} Run the generated binary"
        echo -e "  4. ${YELLOW}Commit changes:${NC} git add . && git commit -m 'Update to VSCode ${MS_TAG}'"
        echo ""
        echo -e "${BLUE}💡 TIP:${NC} Use ${YELLOW}--build${NC} flag next time to automatically start building"
    fi
    
    echo -e "${BLUE}📁 Backup location:${NC} updating/backups/"
    echo -e "${BLUE}🔗 For issues:${NC} https://github.com/Erg69/BAX-IDE/issues"
}

# Main execution
main() {
    echo -e "${BOLD}${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                   BAX-IDE Update Script                     ║"
    echo "║              Keep BAX-IDE up to date with VSCode            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${BLUE}Updating to VSCode ${VSCODE_QUALITY} with BAX branding${NC}"
    echo -e "${BLUE}OS: ${YELLOW}${OS_NAME}${NC} | Arch: ${YELLOW}${VSCODE_ARCH}${NC}"
    echo ""
    
    # Change to root directory
    cd "$ROOT_DIR"
    
    # Execute update steps
    check_prerequisites
    get_current_version
    get_latest_version
    
    if ! check_update_needed; then
        exit 0
    fi
    
    backup_current_state
    
    if [[ "$SKIP_VSCODIUM" != "yes" ]]; then
        update_vscodium_patches
    else
        echo -e "${BLUE}⏭️ Skipping VSCodium patches update (--skip-vscodium specified)${NC}"
    fi
    
    download_vscode_source
    update_version_tracking
    apply_bax_branding
    clean_build_outputs
    start_build
    show_completion_summary
}

# Handle script interruption
trap 'echo -e "\n${RED}❌ Update interrupted by user${NC}"; exit 1' INT TERM

# Run main function
main "$@"
