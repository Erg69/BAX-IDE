#!/usr/bin/env bash
# BAX IDE Text Branding Replacement Script
# This script replaces all VSCodium text references with BAX branding
# Usage: bash branding/apply_bax_branding.sh

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

# BAX branding configuration
BAX_NAME="BAX"
BAX_LOWER="bax"
BAX_ORG="BAX"
BAX_REPO="Erg69/BAX-IDE"
BAX_INSIDERS_REPO="Erg69/BAX-IDE-insiders"
BAX_VERSIONS_REPO="Erg69/BAX-versions"
BAX_WEBSITE="https://your-bax-website.com"
BAX_EMAIL="support@bax-ide.com"

echo -e "${BOLD}${BLUE}🎨 BAX IDE Text Branding Replacement Script${NC}"
echo -e "${BLUE}=============================================${NC}"
echo -e "Converting all VSCodium references to BAX branding..."
echo -e "OS Type: ${YELLOW}$OSTYPE${NC}"
echo -e "Root Directory: ${YELLOW}$ROOT_DIR${NC}"
echo ""

# Function to create backup
create_backup() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "$file.bak.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Function to safely replace text in files (cross-platform)
safe_replace() {
    local file="$1"
    local search="$2"
    local replace="$3"
    local description="$4"
    
    if [[ -f "$file" ]]; then
        if grep -q "$search" "$file" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Updating ${YELLOW}$(basename "$file")${NC}: $description"
            
            # Create backup first
            create_backup "$file"
            
            # Use sed with proper escaping (avoid Perl on Windows)
            if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
                # Windows/Git Bash - use simple sed with different delimiter
                sed -i "s#$search#$replace#g" "$file"
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS sed requires different syntax
                sed -i '' "s#$search#$replace#g" "$file"
            else
                # Linux sed
                sed -i "s#$search#$replace#g" "$file"
            fi
        fi
    fi
}

# Function to replace in multiple files with pattern
batch_replace() {
    local pattern="$1"
    local search="$2"
    local replace="$3"
    local description="$4"
    
    echo -e "  ${BLUE}$description${NC}"
    
    # Find files and process them
    find "$ROOT_DIR" -type f -name "$pattern" -not -path "*/.*" -not -path "*/node_modules/*" -not -path "*/vscode/*" -not -path "*/VSCode*" 2>/dev/null | while read -r file; do
        if grep -q "$search" "$file" 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} ${YELLOW}$(basename "$file")${NC}"
            create_backup "$file"
            
            # Use sed with proper escaping (avoid Perl on Windows)
            if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
                # Windows/Git Bash - use simple sed with different delimiter
                sed -i "s#$search#$replace#g" "$file"
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS sed requires different syntax
                sed -i '' "s#$search#$replace#g" "$file"
            else
                # Linux sed
                sed -i "s#$search#$replace#g" "$file"
            fi
        fi
    done
}

# Change to root directory
cd "$ROOT_DIR"

echo -e "${BOLD}${BLUE}📋 Phase 1: Core Build Configuration${NC}"
echo "=================================================================="

# 1. Update main build scripts
echo -e "${BLUE}🔨 Updating main build scripts...${NC}"
safe_replace "dev/build.sh" 'export APP_NAME="VSCodium"' "export APP_NAME=\"$BAX_NAME\"" "Main app name"
safe_replace "dev/build.sh" 'export ASSETS_REPOSITORY="Erg69/BAX-IDE"' "export ASSETS_REPOSITORY=\"$BAX_REPO\"" "Assets repository"
safe_replace "dev/build.sh" 'export BINARY_NAME="codium"' "export BINARY_NAME=\"$BAX_LOWER\"" "Binary name"
safe_replace "dev/build.sh" 'export GH_REPO_PATH="Erg69/BAX-IDE"' "export GH_REPO_PATH=\"$BAX_REPO\"" "GitHub repo path"
safe_replace "dev/build.sh" 'export ORG_NAME="VSCodium"' "export ORG_NAME=\"$BAX_ORG\"" "Organization name"

# Update insider build options
safe_replace "dev/build.sh" 'export ASSETS_REPOSITORY="Erg69/BAX-IDE-insiders"' "export ASSETS_REPOSITORY=\"$BAX_INSIDERS_REPO\"" "Insider assets repository"
safe_replace "dev/build.sh" 'export BINARY_NAME="codium-insiders"' "export BINARY_NAME=\"$BAX_LOWER-insiders\"" "Insider binary name"

# 2. Update utils.sh defaults
echo -e "${BLUE}⚙️ Updating utils.sh defaults...${NC}"
safe_replace "utils.sh" 'APP_NAME="${APP_NAME:-VSCodium}"' 'APP_NAME="${APP_NAME:-BAX}"' "Default app name"
safe_replace "utils.sh" 'ASSETS_REPOSITORY="${ASSETS_REPOSITORY:-Erg69/BAX-IDE}"' 'ASSETS_REPOSITORY="${ASSETS_REPOSITORY:-Erg69/BAX-IDE}"' "Default assets repository"
safe_replace "utils.sh" 'BINARY_NAME="${BINARY_NAME:-codium}"' 'BINARY_NAME="${BINARY_NAME:-bax}"' "Default binary name"
safe_replace "utils.sh" 'GH_REPO_PATH="${GH_REPO_PATH:-Erg69/BAX-IDE}"' 'GH_REPO_PATH="${GH_REPO_PATH:-Erg69/BAX-IDE}"' "Default GitHub repo path"
safe_replace "utils.sh" 'ORG_NAME="${ORG_NAME:-VSCodium}"' 'ORG_NAME="${ORG_NAME:-BAX}"' "Default organization name"

# 3. Update CLI build script
echo -e "${BLUE}💻 Updating CLI build script...${NC}"
safe_replace "build_cli.sh" 'VSCodium/versions' "$BAX_VERSIONS_REPO" "CLI versions repository"
safe_replace "build_cli.sh" 'Erg69/BAX-IDE-insiders' "$BAX_INSIDERS_REPO" "CLI insider repository"
safe_replace "build_cli.sh" 'Erg69/BAX-IDE' "$BAX_REPO" "CLI repository"

echo ""
echo -e "${BOLD}${BLUE}🌐 Phase 2: GitHub Workflows & CI/CD${NC}"
echo "=================================================================="

# 4. Update GitHub workflow files
echo -e "${BLUE}📋 Updating GitHub workflows...${NC}"
if [[ -d ".github/workflows" ]]; then
    for workflow in .github/workflows/*.yml; do
        if [[ -f "$workflow" ]]; then
            echo -e "  Processing ${YELLOW}$(basename "$workflow")${NC}"
            safe_replace "$workflow" "APP_NAME: VSCodium" "APP_NAME: $BAX_NAME" "Workflow app name"
            safe_replace "$workflow" "VSCodium.VSCodium" "$BAX_NAME.$BAX_NAME" "Workflow app identifier"
            safe_replace "$workflow" "VSCodium.VSCodium.Insiders" "$BAX_NAME.$BAX_NAME.Insiders" "Workflow insider app identifier"
            safe_replace "$workflow" "vscodium-insiders" "$BAX_LOWER-insiders" "Workflow assets repository"
            safe_replace "$workflow" "Erg69/BAX-IDE" "$BAX_REPO" "Workflow repository reference"
            safe_replace "$workflow" "BAX/repositories-linux" "$BAX_ORG/repositories-linux" "Workflow Linux repository"
            safe_replace "$workflow" "bax/bax-linux-build-agent" "$BAX_LOWER/$BAX_LOWER-linux-build-agent" "Workflow Docker build agent"
        fi
    done
fi

echo ""
echo -e "${BOLD}${BLUE}📦 Phase 3: Package Managers & Stores${NC}"
echo "=================================================================="

# 5. Update Snapcraft configuration
echo -e "${BLUE}📦 Updating Snapcraft configuration...${NC}"
for snapcraft in stores/snapcraft/*/snap/snapcraft.yaml; do
    if [[ -f "$snapcraft" ]]; then
        echo -e "  Processing ${YELLOW}$(basename "$(dirname "$(dirname "$snapcraft")")")${NC} snapcraft"
        safe_replace "$snapcraft" "name: codium" "name: $BAX_LOWER" "Snap name"
        safe_replace "$snapcraft" "adopt-info: codium" "adopt-info: $BAX_LOWER" "Snap adopt info"
        safe_replace "$snapcraft" "Erg69/BAX-IDE" "$BAX_REPO" "Snap repository URL"
        safe_replace "$snapcraft" "Binary releases of Visual Studio Code without branding/telemetry/licensing" "$BAX_NAME - A powerful code editor built on Visual Studio Code" "Snap description"
    fi
done

# 6. Update WinGet configuration
echo -e "${BLUE}🪟 Updating WinGet configuration...${NC}"
batch_replace "*.yml" "VSCodium" "$BAX_NAME" "WinGet manifests"
batch_replace "*.yml" "vscodium" "$BAX_LOWER" "WinGet identifiers"

echo ""
echo -e "${BOLD}${BLUE}🖥️ Phase 4: Desktop & Resource Files${NC}"
echo "=================================================================="

# 7. Update Linux desktop files
echo -e "${BLUE}🐧 Updating Linux desktop files...${NC}"
for desktop in src/*/resources/linux/*.desktop; do
    if [[ -f "$desktop" ]]; then
        echo -e "  Processing ${YELLOW}$(basename "$desktop")${NC}"
        safe_replace "$desktop" "Keywords=vscodium;codium;vscode;" "Keywords=$BAX_LOWER;code;editor;ide;" "Desktop keywords"
    fi
done

# 8. Update Linux AppData files
echo -e "${BLUE}📱 Updating Linux AppData files...${NC}"
for appdata in src/*/resources/linux/code.appdata.xml; do
    if [[ -f "$appdata" ]]; then
        echo -e "  Processing ${YELLOW}$(basename "$appdata")${NC}"
        safe_replace "$appdata" "VSCodium" "$BAX_NAME" "AppData application name"
        safe_replace "$appdata" "vscodium" "$BAX_LOWER" "AppData identifiers"
        safe_replace "$appdata" "Binary releases of VS Code without MS branding/telemetry/licensing" "$BAX_NAME - Code editing redefined" "AppData description"
    fi
done

# 9. Update Windows manifests
echo -e "${BLUE}🪟 Updating Windows manifests...${NC}"
for manifest in src/*/resources/win32/VisualElementsManifest.xml; do
    if [[ -f "$manifest" ]]; then
        echo -e "  Processing ${YELLOW}$(basename "$manifest")${NC}"
        safe_replace "$manifest" 'ShortDisplayName="VSCodium"' "ShortDisplayName=\"$BAX_NAME\"" "Windows short display name"
        safe_replace "$manifest" 'ShortDisplayName="VSCodium - Insiders"' "ShortDisplayName=\"$BAX_NAME - Insiders\"" "Windows insider short display name"
    fi
done

echo ""
echo -e "${BOLD}${BLUE}🏗️ Phase 5: Build System & MSI${NC}"
echo "=================================================================="

# 10. Update Windows MSI files
echo -e "${BLUE}📦 Updating Windows MSI installer files...${NC}"
for msi_file in build/windows/msi/*.{wxs,xsl}; do
    if [[ -f "$msi_file" ]]; then
        echo -e "  Processing ${YELLOW}$(basename "$msi_file")${NC}"
        safe_replace "$msi_file" "VSCodium" "$BAX_NAME" "MSI branding"
        safe_replace "$msi_file" "vscodium" "$BAX_LOWER" "MSI identifiers"
    fi
done

# Update MSI internationalization files
for i18n_file in build/windows/msi/i18n/*.wxl; do
    if [[ -f "$i18n_file" ]]; then
        echo -e "  Processing ${YELLOW}$(basename "$i18n_file")${NC}"
        safe_replace "$i18n_file" "VSCodium" "$BAX_NAME" "MSI i18n branding"
        safe_replace "$i18n_file" "vscodium" "$BAX_LOWER" "MSI i18n identifiers"
    fi
done

# Update MSI build script
echo -e "${BLUE}🔨 Updating MSI build script...${NC}"
safe_replace "build/windows/msi/build.sh" "VSCodium" "$BAX_NAME" "MSI build script branding"

echo ""
echo -e "${BOLD}${BLUE}📚 Phase 6: Documentation${NC}"
echo "=================================================================="

# 11. Update documentation files
echo -e "${BLUE}📖 Updating documentation...${NC}"
batch_replace "*.md" "VSCodium" "$BAX_NAME" "Documentation branding"
batch_replace "*.md" "vscodium" "$BAX_LOWER" "Documentation identifiers"
batch_replace "*.md" "Erg69/BAX-IDE" "$BAX_REPO" "Documentation repository links"

# 12. Update issue templates
echo -e "${BLUE}🐛 Updating issue templates...${NC}"
if [[ -d ".github/ISSUE_TEMPLATE" ]]; then
    batch_replace "*.md" "VSCodium-specific" "$BAX_NAME-specific" "Issue template specificity"
    batch_replace "*.md" "VSCodium Code of Conduct" "$BAX_NAME Code of Conduct" "Issue template code of conduct"
fi

echo ""
echo -e "${BOLD}${BLUE}🔧 Phase 7: Infrastructure Files${NC}"
echo "=================================================================="

# 13. Update announcement files
echo -e "${BLUE}📢 Updating announcement files...${NC}"
safe_replace "announcements-extra.json" "Erg69/BAX-IDE" "$BAX_REPO" "Announcements repository"

# 14. Update other infrastructure files
echo -e "${BLUE}⚙️ Updating infrastructure files...${NC}"
safe_replace "CODE_OF_CONDUCT.md" "vscodium@protonmail.com" "$BAX_EMAIL" "Contact email"

# 15. Update build system files
echo -e "${BLUE}🏗️ Updating other build files...${NC}"
batch_replace "*.sh" "Erg69/BAX-IDE" "$BAX_REPO" "Build script repository references"
batch_replace "*.sh" "BAX/repositories-linux" "$BAX_ORG/repositories-linux" "Build script Linux repositories"
batch_replace "*.sh" "bax/bax-linux-build-agent" "$BAX_LOWER/$BAX_LOWER-linux-build-agent" "Build script Docker images"

# 16. Update helper and patch files
echo -e "${BLUE}🔧 Updating development helper files...${NC}"
safe_replace "dev/update_patches.sh" "VSCODIUM HELPER" "$BAX_NAME HELPER" "Patch helper commit message"
safe_replace "dev/patch.sh" "VSCODIUM HELPER" "$BAX_NAME HELPER" "Patch commit message"

echo ""
echo -e "${BOLD}${BLUE}🎯 Phase 8: Icon References${NC}"
echo "=================================================================="

# 17. Update icon references
echo -e "${BLUE}🎨 Updating icon build references...${NC}"
safe_replace "icons/build_icons.sh" "Erg69/BAX-IDE" "$BAX_REPO" "Icon build repository"

# 18. Update product configuration for welcome screen and branding
echo -e "${BLUE}🏷️ Updating product configuration for welcome screen...${NC}"

# First, update product.json template files BEFORE prepare_vscode.sh runs
echo -e "  Updating product.json template with BAX branding..."
safe_replace "product.json" "VSCodium" "$BAX_NAME" "Product template name"
safe_replace "product.json" "Editing evolved" "Code editing redefined" "Product template tagline"
safe_replace "product.json" '"nameShort": "VSCodium"' "\"nameShort\": \"$BAX_NAME\"" "Product short name"
safe_replace "product.json" '"nameLong": "VSCodium"' "\"nameLong\": \"$BAX_NAME\"" "Product long name"
safe_replace "product.json" '"applicationName": "codium"' "\"applicationName\": \"$BAX_LOWER\"" "Application name"

# Run prepare_vscode.sh to apply the product configuration
if [[ -f "prepare_vscode.sh" ]]; then
    echo -e "  Running prepare_vscode.sh to apply BAX product branding..."
    if bash prepare_vscode.sh; then
        echo -e "    ${GREEN}✓${NC} prepare_vscode.sh completed successfully"
    else
        echo -e "    ${YELLOW}⚠️${NC} prepare_vscode.sh failed, continuing with other branding updates..."
        echo -e "    ${YELLOW}⚠️${NC} You may need to run prepare_vscode.sh manually later"
    fi
fi

# 19. Clean up old build outputs to force fresh build
echo -e "${BLUE}🧹 Cleaning up old build outputs...${NC}"
echo -e "  Removing existing build directories to ensure fresh BAX build..."

# Remove old build directories to force a complete rebuild with new branding
for build_dir in VSCode-* vscode-reh-*; do
    if [[ -d "$build_dir" ]]; then
        echo -e "    ${GREEN}✓${NC} Removing ${YELLOW}$build_dir${NC}"
        rm -rf "$build_dir"
    fi
done

# Also clean the vscode/out directory if it exists
if [[ -d "vscode/out" ]]; then
    echo -e "    ${GREEN}✓${NC} Cleaning vscode/out directory"
    rm -rf "vscode/out"
fi

echo -e "  ${GREEN}✓${NC} Build directories cleaned - next build will be fresh with BAX branding"

# 20. Update any remaining build output branding (for post-build runs)
echo -e "${BLUE}📦 Updating build output branding (if exists)...${NC}"

# Handle Windows build output
if [[ -d "VSCode-win32-x64" ]]; then
    echo -e "  Processing Windows build output directory..."
    
    # Rename the main executable
    if [[ -f "VSCode-win32-x64/VSCodium.exe" ]]; then
        echo -e "    ${GREEN}✓${NC} Renaming VSCodium.exe to BAX.exe"
        mv "VSCode-win32-x64/VSCodium.exe" "VSCode-win32-x64/BAX.exe"
    fi
    
    # Update the manifest file
    if [[ -f "VSCode-win32-x64/VSCodium.VisualElementsManifest.xml" ]]; then
        echo -e "    ${GREEN}✓${NC} Renaming VSCodium.VisualElementsManifest.xml to BAX.VisualElementsManifest.xml"
        mv "VSCode-win32-x64/VSCodium.VisualElementsManifest.xml" "VSCode-win32-x64/BAX.VisualElementsManifest.xml"
    fi
    
    if [[ -f "VSCode-win32-x64/VSCodium.VisualElementsManifest" ]]; then
        echo -e "    ${GREEN}✓${NC} Renaming VSCodium.VisualElementsManifest to BAX.VisualElementsManifest"
        mv "VSCode-win32-x64/VSCodium.VisualElementsManifest" "VSCode-win32-x64/BAX.VisualElementsManifest"
    fi
    
    # Update any remaining VSCodium references in the build output
    find "VSCode-win32-x64" -type f \( -name "*.exe" -o -name "*.dll" -o -name "*.manifest" -o -name "*.xml" -o -name "*.json" -o -name "*.js" \) 2>/dev/null | while read -r file; do
        if [[ -f "$file" ]] && grep -q "VSCodium" "$file" 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} Updating branding in ${YELLOW}$(basename "$file")${NC}"
            create_backup "$file"
            if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
                sed -i "s#VSCodium#$BAX_NAME#g" "$file"
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s#VSCodium#$BAX_NAME#g" "$file"
            else
                sed -i "s#VSCodium#$BAX_NAME#g" "$file"
            fi
        fi
    done
    
    # Update the main executable's internal branding if it exists
    if [[ -f "VSCode-win32-x64/BAX.exe" ]]; then
        echo -e "    ${GREEN}✓${NC} Main executable renamed and ready"
    fi
fi

# 20. Update any other build output directories
for build_dir in VSCode-*; do
    if [[ -d "$build_dir" && "$build_dir" != "VSCode-win32-x64" ]]; then
        echo -e "  Processing ${YELLOW}$build_dir${NC}..."
        
        # Rename executables in other build directories
        if [[ -f "$build_dir/VSCodium" ]]; then
            echo -e "    ${GREEN}✓${NC} Renaming VSCodium to BAX in $build_dir"
            mv "$build_dir/VSCodium" "$build_dir/BAX"
        fi
        
        # Update branding in other build files
        find "$build_dir" -type f \( -name "*.exe" -o -name "*.dll" -o -name "*.manifest" -o -name "*.xml" -o -name "*.desktop" -o -name "*.app" \) 2>/dev/null | while read -r file; do
            if grep -q "VSCodium" "$file" 2>/dev/null; then
                echo -e "    ${GREEN}✓${NC} Updating branding in ${YELLOW}$(basename "$file")${NC}"
                create_backup "$file"
                if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
                    sed -i "s#VSCodium#$BAX_NAME#g" "$file"
                elif [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' "s#VSCodium#$BAX_NAME#g" "$file"
                else
                    sed -i "s#VSCodium#$BAX_NAME#g" "$file"
                fi
            fi
        done
    fi
done

# 21. Update welcome screen and UI text in source files AFTER vscode source is prepared
echo -e "${BLUE}🖥️ Updating source files for welcome screen and UI branding...${NC}"
if [[ -d "vscode" ]]; then
    echo -e "  Processing VSCode source files for complete BAX branding..."
    
    # Target specific files that control welcome screen branding
    echo -e "  Updating critical source files for UI branding..."
    
    # Update all TypeScript and JavaScript files that might contain branding
    find "vscode/src" -type f \( -name "*.ts" -o -name "*.js" \) 2>/dev/null | head -200 | while read -r file; do
        if grep -q "VSCodium\|Editing evolved" "$file" 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} Updating source file ${YELLOW}$(basename "$file")${NC}"
            create_backup "$file"
            if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
                sed -i "s#VSCodium#$BAX_NAME#g" "$file"
                sed -i "s#Editing evolved#Code editing redefined#g" "$file"
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s#VSCodium#$BAX_NAME#g" "$file"
                sed -i '' "s#Editing evolved#Code editing redefined#g" "$file"
            else
                sed -i "s#VSCodium#$BAX_NAME#g" "$file"
                sed -i "s#Editing evolved#Code editing redefined#g" "$file"
            fi
        fi
    done
    
    # Update localization files that control UI text
    find "vscode" -type f -name "*.nls.json" 2>/dev/null | while read -r file; do
        if grep -q "VSCodium\|Editing evolved" "$file" 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} Updating localization file ${YELLOW}$(basename "$file")${NC}"
            create_backup "$file"
            if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
                sed -i "s#VSCodium#$BAX_NAME#g" "$file"
                sed -i "s#Editing evolved#Code editing redefined#g" "$file"
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s#VSCodium#$BAX_NAME#g" "$file"
                sed -i '' "s#Editing evolved#Code editing redefined#g" "$file"
            else
                sed -i "s#VSCodium#$BAX_NAME#g" "$file"
                sed -i "s#Editing evolved#Code editing redefined#g" "$file"
            fi
        fi
    done
    
    # Update critical source files that control welcome page branding
    
    # 1. Fix the welcome page "Editing evolved" text in the ACTUAL SOURCE FILE
    welcome_file="vscode/src/vs/workbench/contrib/welcomeGettingStarted/browser/gettingStarted.ts"
    if [[ -f "$welcome_file" ]]; then
        echo -e "    ${GREEN}✓${NC} Updating welcome page text in gettingStarted.ts"
        create_backup "$welcome_file"
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
            sed -i "s#Editing evolved#Code editing redefined#g" "$welcome_file"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s#Editing evolved#Code editing redefined#g" "$welcome_file"
        else
            sed -i "s#Editing evolved#Code editing redefined#g" "$welcome_file"
        fi
    fi
    
    # 2. Fix the electron build configuration
    electron_file="vscode/build/lib/electron.ts"
    if [[ -f "$electron_file" ]]; then
        echo -e "    ${GREEN}✓${NC} Updating electron build configuration"
        create_backup "$electron_file"
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
            sed -i "s#companyName: 'VSCodium'#companyName: '$BAX_NAME'#g" "$electron_file"
            sed -i "s#Copyright (c) VSCodium#Copyright (c) $BAX_NAME#g" "$electron_file"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s#companyName: 'VSCodium'#companyName: '$BAX_NAME'#g" "$electron_file"
            sed -i '' "s#Copyright (c) VSCodium#Copyright (c) $BAX_NAME#g" "$electron_file"
        else
            sed -i "s#companyName: 'VSCodium'#companyName: '$BAX_NAME'#g" "$electron_file"
            sed -i "s#Copyright (c) VSCodium#Copyright (c) $BAX_NAME#g" "$electron_file"
        fi
    fi
    
    # 3. Update the ROOT product configuration file (template)
    for product_file in product.json product.foss.json; do
        if [[ -f "$product_file" ]]; then
            echo -e "    ${GREEN}✓${NC} Updating ROOT template product configuration in ${YELLOW}$(basename "$product_file")${NC}"
            create_backup "$product_file"
            
            # Use comprehensive replacements for ALL VSCodium references in JSON
            if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
                # Replace exact JSON field values - core branding
                sed -i 's#"nameShort": "VSCodium"#"nameShort": "BAX"#g' "$product_file"
                sed -i 's#"nameLong": "VSCodium"#"nameLong": "BAX"#g' "$product_file"
                sed -i 's#"applicationName": "codium"#"applicationName": "bax"#g' "$product_file"
                
                # Replace Windows-specific VSCodium fields for About dialog and installer
                sed -i 's#"win32DirName": "VSCodium"#"win32DirName": "BAX"#g' "$product_file"
                sed -i 's#"win32NameVersion": "VSCodium"#"win32NameVersion": "BAX"#g' "$product_file"
                sed -i 's#"win32RegValueName": "VSCodium"#"win32RegValueName": "BAX"#g' "$product_file"
                sed -i 's#"win32AppUserModelId": "VSCodium.VSCodium"#"win32AppUserModelId": "BAX.BAX"#g' "$product_file"
                sed -i 's#"win32ShellNameShort": "VSCodium"#"win32ShellNameShort": "BAX"#g' "$product_file"
                
                # Replace any remaining VSCodium references
                sed -i "s#VSCodium#$BAX_NAME#g" "$product_file"
                sed -i "s#codium#bax#g" "$product_file"
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                # Replace exact JSON field values - core branding
                sed -i '' 's#"nameShort": "VSCodium"#"nameShort": "BAX"#g' "$product_file"
                sed -i '' 's#"nameLong": "VSCodium"#"nameLong": "BAX"#g' "$product_file"
                sed -i '' 's#"applicationName": "codium"#"applicationName": "bax"#g' "$product_file"
                
                # Replace Windows-specific VSCodium fields for About dialog and installer
                sed -i '' 's#"win32DirName": "VSCodium"#"win32DirName": "BAX"#g' "$product_file"
                sed -i '' 's#"win32NameVersion": "VSCodium"#"win32NameVersion": "BAX"#g' "$product_file"
                sed -i '' 's#"win32RegValueName": "VSCodium"#"win32RegValueName": "BAX"#g' "$product_file"
                sed -i '' 's#"win32AppUserModelId": "VSCodium.VSCodium"#"win32AppUserModelId": "BAX.BAX"#g' "$product_file"
                sed -i '' 's#"win32ShellNameShort": "VSCodium"#"win32ShellNameShort": "BAX"#g' "$product_file"
                
                # Replace any remaining VSCodium references
                sed -i '' "s#VSCodium#$BAX_NAME#g" "$product_file"
                sed -i '' "s#codium#bax#g" "$product_file"
            else
                # Replace exact JSON field values - core branding
                sed -i 's#"nameShort": "VSCodium"#"nameShort": "BAX"#g' "$product_file"
                sed -i 's#"nameLong": "VSCodium"#"nameLong": "BAX"#g' "$product_file"
                sed -i 's#"applicationName": "codium"#"applicationName": "bax"#g' "$product_file"
                
                # Replace Windows-specific VSCodium fields for About dialog and installer
                sed -i 's#"win32DirName": "VSCodium"#"win32DirName": "BAX"#g' "$product_file"
                sed -i 's#"win32NameVersion": "VSCodium"#"win32NameVersion": "BAX"#g' "$product_file"
                sed -i 's#"win32RegValueName": "VSCodium"#"win32RegValueName": "BAX"#g' "$product_file"
                sed -i 's#"win32AppUserModelId": "VSCodium.VSCodium"#"win32AppUserModelId": "BAX.BAX"#g' "$product_file"
                sed -i 's#"win32ShellNameShort": "VSCodium"#"win32ShellNameShort": "BAX"#g' "$product_file"
                
                # Replace any remaining VSCodium references
                sed -i "s#VSCodium#$BAX_NAME#g" "$product_file"
                sed -i "s#codium#bax#g" "$product_file"
            fi
        fi
    done
    
    # 4. Update the ACTUAL COMPILED source product configuration files - THIS IS THE KEY!
    for product_file in vscode/product.json vscode/product.foss.json; do
        if [[ -f "$product_file" ]]; then
            echo -e "    ${GREEN}✓${NC} Updating CRITICAL product configuration in ${YELLOW}$(basename "$product_file")${NC}"
            create_backup "$product_file"
            
            # Use comprehensive replacements for ALL VSCodium references in JSON
            if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
                # Replace exact JSON field values - core branding
                sed -i 's#"nameShort": "VSCodium"#"nameShort": "BAX"#g' "$product_file"
                sed -i 's#"nameLong": "VSCodium"#"nameLong": "BAX"#g' "$product_file"
                sed -i 's#"applicationName": "codium"#"applicationName": "bax"#g' "$product_file"
                
                # Replace Windows-specific VSCodium fields for About dialog and installer
                sed -i 's#"win32DirName": "VSCodium"#"win32DirName": "BAX"#g' "$product_file"
                sed -i 's#"win32NameVersion": "VSCodium"#"win32NameVersion": "BAX"#g' "$product_file"
                sed -i 's#"win32RegValueName": "VSCodium"#"win32RegValueName": "BAX"#g' "$product_file"
                sed -i 's#"win32AppUserModelId": "VSCodium.VSCodium"#"win32AppUserModelId": "BAX.BAX"#g' "$product_file"
                sed -i 's#"win32ShellNameShort": "VSCodium"#"win32ShellNameShort": "BAX"#g' "$product_file"
                
                # Replace any remaining VSCodium references
                sed -i "s#VSCodium#$BAX_NAME#g" "$product_file"
                sed -i "s#codium#bax#g" "$product_file"
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                # Replace exact JSON field values - core branding
                sed -i '' 's#"nameShort": "VSCodium"#"nameShort": "BAX"#g' "$product_file"
                sed -i '' 's#"nameLong": "VSCodium"#"nameLong": "BAX"#g' "$product_file"
                sed -i '' 's#"applicationName": "codium"#"applicationName": "bax"#g' "$product_file"
                
                # Replace Windows-specific VSCodium fields for About dialog and installer
                sed -i '' 's#"win32DirName": "VSCodium"#"win32DirName": "BAX"#g' "$product_file"
                sed -i '' 's#"win32NameVersion": "VSCodium"#"win32NameVersion": "BAX"#g' "$product_file"
                sed -i '' 's#"win32RegValueName": "VSCodium"#"win32RegValueName": "BAX"#g' "$product_file"
                sed -i '' 's#"win32AppUserModelId": "VSCodium.VSCodium"#"win32AppUserModelId": "BAX.BAX"#g' "$product_file"
                sed -i '' 's#"win32ShellNameShort": "VSCodium"#"win32ShellNameShort": "BAX"#g' "$product_file"
                
                # Replace any remaining VSCodium references
                sed -i '' "s#VSCodium#$BAX_NAME#g" "$product_file"
                sed -i '' "s#codium#bax#g" "$product_file"
            else
                # Replace exact JSON field values - core branding
                sed -i 's#"nameShort": "VSCodium"#"nameShort": "BAX"#g' "$product_file"
                sed -i 's#"nameLong": "VSCodium"#"nameLong": "BAX"#g' "$product_file"
                sed -i 's#"applicationName": "codium"#"applicationName": "bax"#g' "$product_file"
                
                # Replace Windows-specific VSCodium fields for About dialog and installer
                sed -i 's#"win32DirName": "VSCodium"#"win32DirName": "BAX"#g' "$product_file"
                sed -i 's#"win32NameVersion": "VSCodium"#"win32NameVersion": "BAX"#g' "$product_file"
                sed -i 's#"win32RegValueName": "VSCodium"#"win32RegValueName": "BAX"#g' "$product_file"
                sed -i 's#"win32AppUserModelId": "VSCodium.VSCodium"#"win32AppUserModelId": "BAX.BAX"#g' "$product_file"
                sed -i 's#"win32ShellNameShort": "VSCodium"#"win32ShellNameShort": "BAX"#g' "$product_file"
                
                # Replace any remaining VSCodium references
                sed -i "s#VSCodium#$BAX_NAME#g" "$product_file"
                sed -i "s#codium#bax#g" "$product_file"
            fi
        fi
    done
    
    echo -e "  ${GREEN}✓${NC} Source files updated - ready for clean build with BAX branding"
fi

# NOTE: The critical vscode/product.json and TypeScript files will be updated 
# AFTER prepare_vscode.sh runs via the apply_final_branding() function below

# 22. Update About dialog and version information
echo -e "${BLUE}ℹ️ Updating About dialog and version information...${NC}"
if [[ -d "vscode" ]]; then
    echo -e "  Processing About dialog and version strings..."
    
    # Find and update About dialog files
    find "vscode" -type f \( -name "*about*" -o -name "*version*" -o -name "*dialog*" \) \( -name "*.ts" -o -name "*.js" -o -name "*.json" -o -name "*.html" \) 2>/dev/null | while read -r file; do
        if grep -q "VSCodium" "$file" 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} Updating About dialog in ${YELLOW}$(basename "$file")${NC}"
            create_backup "$file"
            if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
                sed -i "s#VSCodium#$BAX_NAME#g" "$file"
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s#VSCodium#$BAX_NAME#g" "$file"
            else
                sed -i "s#VSCodium#$BAX_NAME#g" "$file"
            fi
        fi
    done
    
    # Update package.json files for About dialog
    find "vscode" -name "package.json" -type f 2>/dev/null | while read -r file; do
        if grep -q "VSCodium\|displayName\|description" "$file" 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} Updating package.json branding in ${YELLOW}$(basename "$(dirname "$file")")${NC}"
            create_backup "$file"
            if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
                sed -i "s#VSCodium#$BAX_NAME#g" "$file"
                sed -i "s#\"displayName\": \".*VSCodium.*\"#\"displayName\": \"$BAX_NAME\"#g" "$file"
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s#VSCodium#$BAX_NAME#g" "$file"
                sed -i '' "s#\"displayName\": \".*VSCodium.*\"#\"displayName\": \"$BAX_NAME\"#g" "$file"
            else
                sed -i "s#VSCodium#$BAX_NAME#g" "$file"
                sed -i "s#\"displayName\": \".*VSCodium.*\"#\"displayName\": \"$BAX_NAME\"#g" "$file"
            fi
        fi
    done
fi

echo ""
echo -e "${BOLD}${GREEN}✅ BAX Text Branding Replacement Complete!${NC}"
echo "=================================================================="
echo ""
echo -e "${GREEN}🎉 Summary of changes applied:${NC}"
echo -e "  • ${YELLOW}App names:${NC} VSCodium → $BAX_NAME"
echo -e "  • ${YELLOW}Binary names:${NC} codium → $BAX_LOWER"
echo -e "  • ${YELLOW}Repository references:${NC} Erg69/BAX-IDE → $BAX_REPO"
echo -e "  • ${YELLOW}Organization:${NC} VSCodium → $BAX_ORG"
echo -e "  • ${YELLOW}Package identifiers:${NC} vscodium → $BAX_LOWER"
echo -e "  • ${YELLOW}Docker images:${NC} vscodium/vscodium-* → $BAX_LOWER/$BAX_LOWER-*"
echo -e "  • ${YELLOW}Documentation:${NC} All VSCodium references → $BAX_NAME"
echo -e "  • ${YELLOW}Welcome screen:${NC} VSCodium → $BAX_NAME, 'Editing evolved' → 'Code editing redefined'"
echo -e "  • ${YELLOW}About dialog:${NC} VSCodium → $BAX_NAME in all version information"
echo -e "  • ${YELLOW}Executables:${NC} VSCodium.exe → BAX.exe, VSCodium → BAX"
echo -e "  • ${YELLOW}Product config:${NC} nameShort, nameLong, applicationName updated"
echo -e "  • ${YELLOW}Build outputs:${NC} All build directories and files updated"
echo ""
echo -e "${BLUE}📁 Backup files created:${NC} Files with .bak.[timestamp] extension"
echo -e "${YELLOW}⚠️  Important notes:${NC}"
echo -e "  • Review changes before committing"
echo -e "  • Some URLs may need manual verification"
echo -e "  • Test build process after applying changes"
echo -e "  • Update any hardcoded paths specific to your environment"
echo ""
echo -e "${BLUE}🛠 Patching build scripts to prevent reversion...${NC}"

# Ensure prepare_vscode.sh does not revert branding back to VSCodium
if [[ -f "prepare_vscode.sh" ]]; then
    echo -e "  ${GREEN}✓${NC} Aligning ${YELLOW}prepare_vscode.sh${NC} defaults with BAX"
    create_backup "prepare_vscode.sh"

    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        sed -i 's#setpath \"product\" \"nameShort\" \"VSCodium - Insiders\"#setpath \"product\" \"nameShort\" \"BAX - Insiders\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"nameLong\" \"VSCodium - Insiders\"#setpath \"product\" \"nameLong\" \"BAX - Insiders\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"applicationName\" \"codium-insiders\"#setpath \"product\" \"applicationName\" \"bax-insiders\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32ShellNameShort\" \"VSCodium Insiders\"#setpath \"product\" \"win32ShellNameShort\" \"BAX Insiders\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32DirName\" \"VSCodium Insiders\"#setpath \"product\" \"win32DirName\" \"BAX Insiders\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32NameVersion\" \"VSCodium Insiders\"#setpath \"product\" \"win32NameVersion\" \"BAX Insiders\"#g' prepare_vscode.sh

        sed -i 's#setpath \"product\" \"nameShort\" \"VSCodium\"#setpath \"product\" \"nameShort\" \"BAX\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"nameLong\" \"VSCodium\"#setpath \"product\" \"nameLong\" \"BAX\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"applicationName\" \"codium\"#setpath \"product\" \"applicationName\" \"bax\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"urlProtocol\" \"vscodium\"#setpath \"product\" \"urlProtocol\" \"bax\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"serverApplicationName\" \"codium-server\"#setpath \"product\" \"serverApplicationName\" \"bax-server\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"serverDataFolderName\" \"\.vscodium-server\"#setpath \"product\" \"serverDataFolderName\" \"\.bax-server\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"darwinBundleIdentifier\" \"com\.vscodium\"#setpath \"product\" \"darwinBundleIdentifier\" \"com\.bax\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32AppUserModelId\" \"VSCodium\.VSCodium\"#setpath \"product\" \"win32AppUserModelId\" \"BAX\.BAX\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32DirName\" \"VSCodium\"#setpath \"product\" \"win32DirName\" \"BAX\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32MutexName\" \"vscodium\"#setpath \"product\" \"win32MutexName\" \"bax\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32NameVersion\" \"VSCodium\"#setpath \"product\" \"win32NameVersion\" \"BAX\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32RegValueName\" \"VSCodium\"#setpath \"product\" \"win32RegValueName\" \"BAX\"#g' prepare_vscode.sh
    else
        sed -i 's#setpath \"product\" \"nameShort\" \"VSCodium - Insiders\"#setpath \"product\" \"nameShort\" \"BAX - Insiders\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"nameLong\" \"VSCodium - Insiders\"#setpath \"product\" \"nameLong\" \"BAX - Insiders\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"applicationName\" \"codium-insiders\"#setpath \"product\" \"applicationName\" \"bax-insiders\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32ShellNameShort\" \"VSCodium Insiders\"#setpath \"product\" \"win32ShellNameShort\" \"BAX Insiders\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32DirName\" \"VSCodium Insiders\"#setpath \"product\" \"win32DirName\" \"BAX Insiders\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32NameVersion\" \"VSCodium Insiders\"#setpath \"product\" \"win32NameVersion\" \"BAX Insiders\"#g' prepare_vscode.sh

        sed -i 's#setpath \"product\" \"nameShort\" \"VSCodium\"#setpath \"product\" \"nameShort\" \"BAX\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"nameLong\" \"VSCodium\"#setpath \"product\" \"nameLong\" \"BAX\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"applicationName\" \"codium\"#setpath \"product\" \"applicationName\" \"bax\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"urlProtocol\" \"vscodium\"#setpath \"product\" \"urlProtocol\" \"bax\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"serverApplicationName\" \"codium-server\"#setpath \"product\" \"serverApplicationName\" \"bax-server\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"serverDataFolderName\" \"\.vscodium-server\"#setpath \"product\" \"serverDataFolderName\" \"\.bax-server\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"darwinBundleIdentifier\" \"com\.vscodium\"#setpath \"product\" \"darwinBundleIdentifier\" \"com\.bax\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32AppUserModelId\" \"VSCodium\.VSCodium\"#setpath \"product\" \"win32AppUserModelId\" \"BAX\.BAX\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32DirName\" \"VSCodium\"#setpath \"product\" \"win32DirName\" \"BAX\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32MutexName\" \"vscodium\"#setpath \"product\" \"win32MutexName\" \"bax\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32NameVersion\" \"VSCodium\"#setpath \"product\" \"win32NameVersion\" \"BAX\"#g' prepare_vscode.sh
        sed -i 's#setpath \"product\" \"win32RegValueName\" \"VSCodium\"#setpath \"product\" \"win32RegValueName\" \"BAX\"#g' prepare_vscode.sh
    fi
fi

echo -e "${GREEN}🚀 Next steps:${NC}"
echo -e "  1. Run ${YELLOW}bash branding/apply_bax_icons.sh${NC} to update icons"
echo -e "  2. ${BOLD}IMPORTANT:${NC} Run a clean build: ${YELLOW}bash dev/build.sh${NC}"
echo -e "  3. Verify BAX branding in the built application"
echo -e "  4. Commit changes: ${YELLOW}git add . && git commit -m 'Apply BAX branding'${NC}"
echo ""
echo -e "${BOLD}${BLUE}📋 Critical Workflow:${NC}"
echo -e "${YELLOW}  • ALWAYS run branding scripts BEFORE building${NC}"
echo -e "${YELLOW}  • The script cleans old builds to force fresh compilation${NC}"
echo -e "${YELLOW}  • Branding changes are compiled into the source code${NC}"
echo ""
echo -e "${BOLD}${GREEN}BAX IDE text branding completed successfully!${NC}"

# CRITICAL: Function to apply final branding AFTER prepare_vscode.sh
apply_final_branding() {
    echo -e "${BLUE}🎯 CRITICAL FINAL BRANDING: Updating files AFTER prepare_vscode.sh...${NC}"
    
    if [[ ! -d "vscode" ]]; then
        echo -e "  ${RED}✗${NC} vscode directory not found - run prepare_vscode.sh first"
        return 1
    fi
    
    # Update the ACTUAL vscode/product.json that gets compiled (this gets overwritten by prepare_vscode.sh)
    if [[ -f "vscode/product.json" ]]; then
        echo -e "    ${GREEN}✓${NC} Updating CRITICAL product.json (post-prepare_vscode.sh)"
        
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
            sed -i 's#"nameShort": "VSCodium"#"nameShort": "BAX"#g' "vscode/product.json"
            sed -i 's#"nameLong": "VSCodium"#"nameLong": "BAX"#g' "vscode/product.json"
            sed -i 's#"applicationName": "codium"#"applicationName": "bax"#g' "vscode/product.json"
            sed -i 's#"win32NameVersion": "VSCodium"#"win32NameVersion": "BAX"#g' "vscode/product.json"
            sed -i 's#"win32DirName": "VSCodium"#"win32DirName": "BAX"#g' "vscode/product.json"
            sed -i 's#"win32AppUserModelId": "VSCodium.VSCodium"#"win32AppUserModelId": "BAX.BAX"#g' "vscode/product.json"
            sed -i 's#"win32ShellNameShort": "VSCodium"#"win32ShellNameShort": "BAX"#g' "vscode/product.json"
            sed -i 's#"nameShort": "VSCodium - Insiders"#"nameShort": "BAX - Insiders"#g' "vscode/product.json"
            sed -i 's#"nameLong": "VSCodium - Insiders"#"nameLong": "BAX - Insiders"#g' "vscode/product.json"
            sed -i 's#"win32ShellNameShort": "VSCodium Insiders"#"win32ShellNameShort": "BAX Insiders"#g' "vscode/product.json"
            sed -i 's#"win32DirName": "VSCodium Insiders"#"win32DirName": "BAX Insiders"#g' "vscode/product.json"
            sed -i 's#"win32NameVersion": "VSCodium Insiders"#"win32NameVersion": "BAX Insiders"#g' "vscode/product.json"
            # Comprehensive VSCodium replacement
            sed -i "s#VSCodium#BAX#g" "vscode/product.json"
            sed -i "s#codium#bax#g" "vscode/product.json"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's#"nameShort": "VSCodium"#"nameShort": "BAX"#g' "vscode/product.json"
            sed -i '' 's#"nameLong": "VSCodium"#"nameLong": "BAX"#g' "vscode/product.json"
            sed -i '' 's#"applicationName": "codium"#"applicationName": "bax"#g' "vscode/product.json"
            sed -i '' 's#"win32NameVersion": "VSCodium"#"win32NameVersion": "BAX"#g' "vscode/product.json"
            sed -i '' 's#"win32DirName": "VSCodium"#"win32DirName": "BAX"#g' "vscode/product.json"
            sed -i '' 's#"win32AppUserModelId": "VSCodium.VSCodium"#"win32AppUserModelId": "BAX.BAX"#g' "vscode/product.json"
            sed -i '' 's#"win32ShellNameShort": "VSCodium"#"win32ShellNameShort": "BAX"#g' "vscode/product.json"
            sed -i '' 's#"nameShort": "VSCodium - Insiders"#"nameShort": "BAX - Insiders"#g' "vscode/product.json"
            sed -i '' 's#"nameLong": "VSCodium - Insiders"#"nameLong": "BAX - Insiders"#g' "vscode/product.json"
            sed -i '' 's#"win32ShellNameShort": "VSCodium Insiders"#"win32ShellNameShort": "BAX Insiders"#g' "vscode/product.json"
            sed -i '' 's#"win32DirName": "VSCodium Insiders"#"win32DirName": "BAX Insiders"#g' "vscode/product.json"
            sed -i '' 's#"win32NameVersion": "VSCodium Insiders"#"win32NameVersion": "BAX Insiders"#g' "vscode/product.json"
            # Comprehensive VSCodium replacement
            sed -i '' "s#VSCodium#BAX#g" "vscode/product.json"
            sed -i '' "s#codium#bax#g" "vscode/product.json"
        else
            sed -i 's#"nameShort": "VSCodium"#"nameShort": "BAX"#g' "vscode/product.json"
            sed -i 's#"nameLong": "VSCodium"#"nameLong": "BAX"#g' "vscode/product.json"
            sed -i 's#"applicationName": "codium"#"applicationName": "bax"#g' "vscode/product.json"
            sed -i 's#"win32NameVersion": "VSCodium"#"win32NameVersion": "BAX"#g' "vscode/product.json"
            sed -i 's#"win32DirName": "VSCodium"#"win32DirName": "BAX"#g' "vscode/product.json"
            sed -i 's#"win32AppUserModelId": "VSCodium.VSCodium"#"win32AppUserModelId": "BAX.BAX"#g' "vscode/product.json"
            sed -i 's#"win32ShellNameShort": "VSCodium"#"win32ShellNameShort": "BAX"#g' "vscode/product.json"
            sed -i 's#"nameShort": "VSCodium - Insiders"#"nameShort": "BAX - Insiders"#g' "vscode/product.json"
            sed -i 's#"nameLong": "VSCodium - Insiders"#"nameLong": "BAX - Insiders"#g' "vscode/product.json"
            sed -i 's#"win32ShellNameShort": "VSCodium Insiders"#"win32ShellNameShort": "BAX Insiders"#g' "vscode/product.json"
            sed -i 's#"win32DirName": "VSCodium Insiders"#"win32DirName": "BAX Insiders"#g' "vscode/product.json"
            sed -i 's#"win32NameVersion": "VSCodium Insiders"#"win32NameVersion": "BAX Insiders"#g' "vscode/product.json"
            # Comprehensive VSCodium replacement
            sed -i "s#VSCodium#BAX#g" "vscode/product.json"
            sed -i "s#codium#bax#g" "vscode/product.json"
        fi
    fi
    
    # Update the ACTUAL welcome page TypeScript source file (if it exists)
    welcome_file="vscode/src/vs/workbench/contrib/welcomeGettingStarted/browser/gettingStarted.ts"
    if [[ -f "$welcome_file" ]]; then
        echo -e "    ${GREEN}✓${NC} Updating welcome page TypeScript source"
        
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
            sed -i 's#Editing evolved#Code editing redefined#g' "$welcome_file"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's#Editing evolved#Code editing redefined#g' "$welcome_file"
        else
            sed -i 's#Editing evolved#Code editing redefined#g' "$welcome_file"
        fi
    fi
    
    echo -e "  ${GREEN}✅ CRITICAL FINAL BRANDING COMPLETE${NC}"
    echo -e "  ${YELLOW}Welcome page and About dialog should now show BAX branding${NC}"
    echo -e "  ${BLUE}Ready for build: bash dev/build.sh${NC}"
}

echo ""
echo -e "${BOLD}${RED}🚨 UPDATED WORKFLOW REQUIRED:${NC}"
echo -e "${YELLOW}1. bash branding/apply_bax_icons.sh${NC}"
echo -e "${YELLOW}2. bash prepare_vscode.sh${NC}"
echo -e "${YELLOW}3. source branding/apply_bax_branding.sh && apply_final_branding${NC}"
echo -e "${YELLOW}4. bash dev/build.sh${NC}"
echo ""
echo -e "${BLUE}📋 Why This New Workflow is Needed:${NC}"
echo -e "  • prepare_vscode.sh OVERWRITES vscode/product.json with VSCodium values"
echo -e "  • apply_final_branding() must run AFTER prepare_vscode.sh to fix this"
echo -e "  • The welcome page title comes from productService.nameLong in product.json"

# Allow calling the final step directly without sourcing (useful from PowerShell)
if [[ "${1:-}" == "--final-only" ]]; then
    apply_final_branding
    exit 0
fi
