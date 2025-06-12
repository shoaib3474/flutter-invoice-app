#!/bin/bash

echo "🔧 Fixing test dependencies and configurations..."

# Create missing directories
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/config
mkdir -p assets/sample_data
mkdir -p fonts
mkdir -p test/unit
mkdir -p test/widget
mkdir -p test/integration

# Create placeholder font files
touch fonts/Roboto-Regular.ttf
touch fonts/Roboto-Bold.ttf

# Create placeholder asset files
echo "# Placeholder" > assets/images/.gitkeep
echo "# Placeholder" > assets/icons/.gitkeep
echo "# Placeholder" > assets/config/.gitkeep
echo "# Placeholder" > assets/sample_data/.gitkeep

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Generate code if needed
echo "🔨 Generating code..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run dart fix
echo "🔧 Running dart fix..."
dart fix --apply

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze

echo "✅ Test dependencies and configurations fixed!"
