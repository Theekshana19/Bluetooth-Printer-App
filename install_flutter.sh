#!/bin/bash
# Flutter SDK installation script
# Run this in Terminal: bash install_flutter.sh
# (No timeout - let it complete; may take 15-30+ minutes on slow connections)

set -e

echo "=== Flutter SDK Installer ==="
echo ""

# Remove partial download if exists
rm -f ~/flutter_sdk.zip

echo "Step 1: Downloading Flutter SDK (~2GB) - this may take a while..."
cd ~
curl -L -o flutter_sdk.zip "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.41.0-stable.zip"

echo ""
echo "Step 2: Extracting..."
unzip -o flutter_sdk.zip
rm flutter_sdk.zip

echo ""
echo "Step 3: Adding to PATH in ~/.zshrc"
if ! grep -q 'flutter/bin' ~/.zshrc 2>/dev/null; then
    echo '' >> ~/.zshrc
    echo '# Flutter SDK' >> ~/.zshrc
    echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
    echo "Added Flutter to PATH."
else
    echo "Flutter PATH already in .zshrc."
fi

echo ""
echo "Step 4: Running flutter doctor..."
export PATH="$PATH:$HOME/flutter/bin"
flutter doctor

echo ""
echo "=== Done! ==="
echo "Open a new terminal or run: source ~/.zshrc"
echo "Then run: flutter --version"
