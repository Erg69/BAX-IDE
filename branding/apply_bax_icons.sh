#!/usr/bin/env bash
# BAX IDE Icon Replacement Script (ImageMagick-only version)
#
# This script generates all required icon sizes and formats from:
#   - TODO/BAX Logo.svg (main app/desktop icon)
#   - TODO/BAX White Logo.svg (all other icons)
#   - TODO/BAX 25% Logo.svg (welcome/empty editor background)
# and replaces all VSCodium icon files in the repo.
#
# Requirements: imagemagick (convert)
# Usage: bash TODO/apply_bax_icons.sh
#
# NOTE: .ico files are generated using ImageMagick only. Please test them for multi-resolution support in Windows.

set -e

# ImageMagick compatibility
if command -v magick >/dev/null 2>&1; then
    # Use magick convert for ImageMagick 7
    CONVERT_CMD="magick convert"
elif [ -f "/home/erg/miniconda3/bin/magick" ]; then
    # Use conda ImageMagick path
    CONVERT_CMD="/home/erg/miniconda3/bin/magick convert"
else
    CONVERT_CMD="convert"
fi

# Paths
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SRC_DIR/.." && pwd)"
LOGO_MAIN="$SRC_DIR/BAX Logo.svg"
LOGO_WHITE="$SRC_DIR/BAX White Logo.svg"
LOGO_25="$SRC_DIR/BAX 25% Logo.svg"

# Output locations (relative to repo root)
WIN32_DIRS=(
  "src/stable/resources/win32"
  "src/insider/resources/win32"
)
DARWIN_DIRS=(
  "src/stable/resources/darwin"
  "src/insider/resources/darwin"
)
LINUX_DIRS=(
  "src/stable/resources/linux"
  "src/insider/resources/linux"
)
SERVER_DIRS=(
  "src/stable/resources/server"
  "src/insider/resources/server"
)
MEDIA_DIRS=(
  "src/stable/src/vs/workbench/browser/media"
  "src/insider/src/vs/workbench/browser/media"
)
ICONS_DIRS=(
  "icons/stable"
  "icons/insider"
)
# Optionally, set this to your build output win32 resource folder (relative to repo root)
BUILD_OUTPUT_WIN32_DIR="VSCode-win32-x64/resources/app/resources/win32"

# 1. Generate PNGs from SVGs
sizes=(16 32 48 64 70 128 150 192 256 512 1024)
for sz in "${sizes[@]}"; do
  $CONVERT_CMD -background none -resize ${sz}x${sz} "$LOGO_MAIN" "$SRC_DIR/bax_icon_${sz}.png"
  $CONVERT_CMD -background none -resize ${sz}x${sz} "$LOGO_WHITE" "$SRC_DIR/bax_white_icon_${sz}.png"
done

# 2. Generate .ico (Windows desktop icon) using ImageMagick only
# (multi-size: 16,32,48,64,128,256)
$CONVERT_CMD "$SRC_DIR/bax_icon_16.png" \
        "$SRC_DIR/bax_icon_32.png" \
        "$SRC_DIR/bax_icon_48.png" \
        "$SRC_DIR/bax_icon_64.png" \
        "$SRC_DIR/bax_icon_128.png" \
        "$SRC_DIR/bax_icon_256.png" \
        "$SRC_DIR/bax_icon.ico"

# 3. Generate .icns (macOS app icon) - skipped (requires png2icns)
# If you need .icns, use an online converter or macOS tool.

# 4. Replace icons in all relevant locations
for d in "${WIN32_DIRS[@]}"; do
  cp "$SRC_DIR/bax_icon.ico" "$ROOT_DIR/$d/code.ico"
  cp "$SRC_DIR/bax_icon_70.png" "$ROOT_DIR/$d/code_70x70.png"
  cp "$SRC_DIR/bax_icon_150.png" "$ROOT_DIR/$d/code_150x150.png"
  # Replace installer bmps (using 100,125,150,175,200,225,250)
  for sz in 100 125 150 175 200 225 250; do
    $CONVERT_CMD "$SRC_DIR/bax_icon_256.png" -resize $((sz*2))x$((sz*2)) "$ROOT_DIR/$d/inno-big-${sz}.bmp"
  done
  # Small bmps (using 100,125,150,175,200,225,250)
  for sz in 100 125 150 175 200 225 250; do
    $CONVERT_CMD "$SRC_DIR/bax_icon_70.png" -resize $((sz/2))x$((sz/2)) "$ROOT_DIR/$d/inno-small-${sz}.bmp"
  done
  # File type icons (use white logo)
  for icon in bower c config cpp csharp css default go html jade java javascript json less markdown php powershell python react ruby sass shell sql typescript vue xml yaml; do
    $CONVERT_CMD "$SRC_DIR/bax_white_icon_128.png" "$ROOT_DIR/$d/${icon}.ico"
  done
done

# Also copy to build output win32 resource folder if it exists
if [ -d "$ROOT_DIR/$BUILD_OUTPUT_WIN32_DIR" ]; then
  cp "$SRC_DIR/bax_icon.ico" "$ROOT_DIR/$BUILD_OUTPUT_WIN32_DIR/code.ico"
fi

for d in "${DARWIN_DIRS[@]}"; do
  # .icns generation skipped
  # File type icons (use white logo, PNG as placeholder)
  for icon in bower c config cpp csharp css default go html jade java javascript json less markdown php powershell python react ruby sass shell sql typescript vue xml yaml; do
    $CONVERT_CMD "$SRC_DIR/bax_white_icon_128.png" -resize 128x128 "$ROOT_DIR/$d/${icon}.png"
  done
done

for d in "${LINUX_DIRS[@]}"; do
  cp "$SRC_DIR/bax_icon_512.png" "$ROOT_DIR/$d/code.png"
  cp "$LOGO_MAIN" "$ROOT_DIR/$d/code.svg"
  # .xpm for rpm
  mkdir -p "$ROOT_DIR/$d/rpm"
  $CONVERT_CMD "$SRC_DIR/bax_icon_512.png" "$ROOT_DIR/$d/rpm/code.xpm"
done

for d in "${SERVER_DIRS[@]}"; do
  cp "$SRC_DIR/bax_icon_192.png" "$ROOT_DIR/$d/code-192.png"
  cp "$SRC_DIR/bax_icon_512.png" "$ROOT_DIR/$d/code-512.png"
  cp "$SRC_DIR/bax_icon.ico" "$ROOT_DIR/$d/favicon.ico"
done

# Use BAX White Logo for all UI SVGs (welcome, activity bar, etc.)
for d in "${MEDIA_DIRS[@]}"; do
  cp "$LOGO_WHITE" "$ROOT_DIR/$d/code-icon.svg"
  # Replace letterpress SVGs for welcome/empty editor background with BAX 25% Logo
  for letterpress in letterpress-dark.svg letterpress-light.svg letterpress-hcDark.svg letterpress-hcLight.svg; do
    cp "$LOGO_25" "$ROOT_DIR/${d%/media}/parts/editor/media/$letterpress"
  done
done

for d in "${ICONS_DIRS[@]}"; do
  cp "$LOGO_WHITE" "$ROOT_DIR/$d/codium_cnl.svg"
  cp "$LOGO_WHITE" "$ROOT_DIR/$d/codium_clt.svg"
  cp "$LOGO_WHITE" "$ROOT_DIR/$d/codium_cnl_w80_b8.svg"
  cp "$LOGO_WHITE" "$ROOT_DIR/$d/codium_cnl_w100_b05.svg"
done

# Clean up temp PNGs
rm "$SRC_DIR"/bax_icon_*.png "$SRC_DIR"/bax_white_icon_*.png "$SRC_DIR/bax_icon.ico" 2>/dev/null || true

# Do NOT delete this script

echo "BAX icons applied (ImageMagick-only). Script NOT deleted, you can re-run as needed!"
echo "REMINDER: Run this script BEFORE building or packaging to ensure your BAX desktop icon is used everywhere. If you build to a different output folder, set BUILD_OUTPUT_WIN32_DIR at the top of this script." 