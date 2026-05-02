#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT="${PROJECT:-Configs.xcodeproj}"
SCHEME="${SCHEME:-Configs}"
CONFIGURATION="${CONFIGURATION:-Release}"
DESTINATION="${DESTINATION:-generic/platform=macOS}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$ROOT_DIR/.build/DerivedData}"
APP_NAME="${APP_NAME:-Configs.app}"
INSTALL_DIR="${INSTALL_DIR:-/Applications}"
CODE_SIGNING_ALLOWED="${CODE_SIGNING_ALLOWED:-NO}"

cd "$ROOT_DIR"

echo "Pulling latest changes..."
git pull

echo "Building $SCHEME ($CONFIGURATION)..."
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED="$CODE_SIGNING_ALLOWED" \
  build

BUILT_APP="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION/$APP_NAME"
TARGET_APP="$INSTALL_DIR/$APP_NAME"

if [[ ! -d "$BUILT_APP" ]]; then
  echo "Build succeeded, but app was not found at: $BUILT_APP" >&2
  exit 1
fi

echo "Installing $APP_NAME to $INSTALL_DIR..."
TMP_APP="$INSTALL_DIR/.$APP_NAME.tmp"
if [[ -w "$INSTALL_DIR" ]]; then
  rm -rf "$TMP_APP"
  ditto "$BUILT_APP" "$TMP_APP"
  rm -rf "$TARGET_APP"
  mv "$TMP_APP" "$TARGET_APP"
else
  sudo rm -rf "$TMP_APP"
  sudo ditto "$BUILT_APP" "$TMP_APP"
  sudo rm -rf "$TARGET_APP"
  sudo mv "$TMP_APP" "$TARGET_APP"
fi

echo "Installed: $TARGET_APP"
