#!/bin/bash

echo "📦 Installing BLoC CLI globally..."

# Install bloc_cli globally
dart pub global activate bloc_cli

# Add pub cache bin to PATH if not already there
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Verify installation
echo "🔍 Verifying BLoC CLI installation..."
bloc --version

echo "✅ BLoC CLI installed successfully!"
echo "💡 Make sure to add ~/.pub-cache/bin to your PATH permanently"
echo "   Add this line to your ~/.bashrc or ~/.zshrc:"
echo "   export PATH=\"\$PATH\":\"\$HOME/.pub-cache/bin\""
