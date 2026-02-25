#!/bin/bash
set -euo pipefail

# AppTemplate Setup Script
# Renames the template project to your own app name and bundle identifier.

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo ""
echo -e "${BOLD}AppTemplate Setup${NC}"
echo "This script will rename the template to your app name."
echo ""

# --- Prompt for app name ---
read -rp "$(echo -e "${CYAN}App name (e.g. MyApp): ${NC}")" APP_NAME

if [[ -z "$APP_NAME" ]]; then
    echo "Error: App name cannot be empty."
    exit 1
fi

# Validate: no spaces, starts with uppercase letter
if [[ ! "$APP_NAME" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
    echo "Error: App name must start with an uppercase letter and contain only alphanumeric characters (no spaces)."
    exit 1
fi

# --- Prompt for bundle ID prefix ---
read -rp "$(echo -e "${CYAN}Bundle ID prefix (e.g. com.mycompany): ${NC}")" BUNDLE_PREFIX

if [[ -z "$BUNDLE_PREFIX" ]]; then
    echo "Error: Bundle ID prefix cannot be empty."
    exit 1
fi

# Validate bundle ID format
if [[ ! "$BUNDLE_PREFIX" =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$ ]]; then
    echo "Error: Bundle ID prefix must be in reverse-domain format (e.g. com.mycompany)."
    exit 1
fi

# --- Derive values ---
APP_NAME_LOWER=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]')
BUNDLE_ID="${BUNDLE_PREFIX}.${APP_NAME_LOWER}"
GROUP_ID="group.${BUNDLE_ID}"

echo ""
echo -e "${YELLOW}Summary:${NC}"
echo "  App name:       $APP_NAME"
echo "  Bundle ID:      $BUNDLE_ID"
echo "  App Group:      $GROUP_ID"
echo "  URL Scheme:     $APP_NAME_LOWER"
echo ""
read -rp "Proceed? (y/N) " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo -e "${BOLD}Renaming...${NC}"

# --- Find all text files to process (exclude .git, xcodeproj, images, binaries) ---
find_text_files() {
    find . -type f \
        ! -path './.git/*' \
        ! -path './*.xcodeproj/*' \
        ! -path '*/Assets.xcassets/AppIcon.appiconset/*.png' \
        ! -name '*.png' \
        ! -name '*.jpg' \
        ! -name '*.jpeg' \
        ! -name '*.gif' \
        ! -name '*.ico' \
        ! -name '*.icns' \
        ! -name 'setup.sh' \
        -print0
}

# --- Replace strings in all text files ---
# Order matters: replace longest/most specific patterns first to avoid partial matches.

echo "  Replacing group.com.apptemplate.app -> $GROUP_ID"
find_text_files | xargs -0 sed -i '' "s|group\.com\.apptemplate\.app|${GROUP_ID}|g" 2>/dev/null || true

echo "  Replacing com.apptemplate.app -> $BUNDLE_ID"
find_text_files | xargs -0 sed -i '' "s|com\.apptemplate\.app|${BUNDLE_ID}|g" 2>/dev/null || true

echo "  Replacing com.apptemplate -> $BUNDLE_PREFIX"
find_text_files | xargs -0 sed -i '' "s|com\.apptemplate|${BUNDLE_PREFIX}|g" 2>/dev/null || true

echo "  Replacing AppTemplate -> $APP_NAME"
find_text_files | xargs -0 sed -i '' "s|AppTemplate|${APP_NAME}|g" 2>/dev/null || true

echo "  Replacing \"apptemplate\" -> \"$APP_NAME_LOWER\""
find_text_files | xargs -0 sed -i '' "s|\"apptemplate\"|\"${APP_NAME_LOWER}\"|g" 2>/dev/null || true

# --- Rename files ---
echo "  Renaming files..."

if [[ -f "AppTemplate/AppTemplateApp.swift" ]]; then
    mv "AppTemplate/AppTemplateApp.swift" "AppTemplate/${APP_NAME}App.swift"
fi

if [[ -f "AppTemplate/AppTemplate.entitlements" ]]; then
    mv "AppTemplate/AppTemplate.entitlements" "AppTemplate/${APP_NAME}.entitlements"
fi

# --- Rename directory ---
if [[ -d "AppTemplate" ]]; then
    mv "AppTemplate" "$APP_NAME"
    echo "  Renamed AppTemplate/ -> ${APP_NAME}/"
fi

# --- Remove old Xcode project ---
if [[ -d "AppTemplate.xcodeproj" ]]; then
    rm -rf "AppTemplate.xcodeproj"
    echo "  Removed old AppTemplate.xcodeproj"
fi

# --- Regenerate Xcode project ---
if command -v xcodegen &>/dev/null; then
    echo ""
    echo -e "${BOLD}Regenerating Xcode project...${NC}"
    xcodegen generate
    echo -e "${GREEN}Xcode project generated successfully.${NC}"
else
    echo ""
    echo -e "${YELLOW}xcodegen not found. Install it with: brew install xcodegen${NC}"
    echo "Then run: xcodegen generate"
fi

echo ""
echo -e "${GREEN}${BOLD}Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Open ${APP_NAME}.xcodeproj"
echo "  2. Replace Resources/GoogleService-Info.plist with your Firebase config"
echo "  3. Set your RevenueCat API key in Services/SubscriptionManager.swift"
echo "  4. Set your OpenAI API key in Services/OpenAIService.swift"
echo "  5. Build and run"
echo ""

# --- Optionally self-destruct ---
read -rp "Delete this setup script? (y/N) " DELETE_SELF
if [[ "$DELETE_SELF" == "y" || "$DELETE_SELF" == "Y" ]]; then
    rm -- "$0"
    echo "Setup script removed."
fi
