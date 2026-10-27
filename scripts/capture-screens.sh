#!/usr/bin/env bash
# Captures the README screenshots of the RouterDemo example app on an iPhone simulator.
#
# The script builds and installs the app, then for each screenshot starts the app in English
# with `-open <deep link>`, which hands the link to the same handler as onOpenURL (`simctl
# openurl` would show a confirmation alert first), and takes a simulator screenshot in light and
# dark appearance with a fixed status bar. Every image shows the state the router reached from
# that link.
#
# Usage: scripts/capture-screens.sh [simulator name or UDID]
# Without an argument it uses the first available iPhone simulator. Output: docs/images/
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
device="${1:-}"
if [[ -z "$device" ]]; then
  device="$(xcrun simctl list devices available | grep -m1 -oE 'iPhone [^(]+' | sed 's/ *$//')"
fi
if [[ -z "$device" ]]; then
  echo "No available iPhone simulator found." >&2
  exit 1
fi

bundle_id="io.github.muhittincamdali.RouterDemo"
output_dir="$repo_root/docs/images"
build_dir="$repo_root/.build/capture-screens"
mkdir -p "$output_dir" "$build_dir"

# name and deep link of each screenshot
shots=(
  "product routerdemo://products/2"
  "reviews routerdemo://products/2/reviews"
  "cart routerdemo://cart"
  "sign-in routerdemo://account/orders/1001"
)

destination="platform=iOS Simulator,name=$device"
if [[ "$device" =~ ^[0-9A-F-]{36}$ ]]; then
  destination="platform=iOS Simulator,id=$device"
fi
echo "Building RouterDemo for '$device'"
xcodebuild build \
  -project "$repo_root/Examples/RouterDemo/RouterDemo.xcodeproj" \
  -scheme RouterDemo \
  -destination "$destination" \
  -derivedDataPath "$build_dir" \
  -quiet
app="$(find "$build_dir/Build/Products" -maxdepth 2 -name 'RouterDemo.app' -path '*iphonesimulator*' | head -1)"

xcrun simctl boot "$device" 2>/dev/null || true
xcrun simctl bootstatus "$device" -b >/dev/null
xcrun simctl status_bar "$device" override --time 9:41 --batteryState charged --batteryLevel 100 \
  --cellularBars 4 --wifiBars 3 --operatorName ""
xcrun simctl install "$device" "$app"

for appearance in light dark; do
  xcrun simctl ui "$device" appearance "$appearance"
  sleep 2 # the appearance change reaches running processes with a delay
  for shot in "${shots[@]}"; do
    name="${shot%% *}"
    link="${shot#* }"
    xcrun simctl launch --terminate-running-process "$device" "$bundle_id" \
      -AppleLanguages "(en)" -AppleLocale en_US -open "$link" >/dev/null
    sleep 4 # let the launch, the pushes and the sheet animation finish
    file="$output_dir/$name-$appearance.png"
    xcrun simctl io "$device" screenshot --type=png "$file" >/dev/null 2>&1
    # Half the width of an iPhone screenshot keeps the README light.
    sips --resampleWidth 603 "$file" >/dev/null
    echo "$file"
  done
done

xcrun simctl status_bar "$device" clear
xcrun simctl terminate "$device" "$bundle_id" 2>/dev/null || true
