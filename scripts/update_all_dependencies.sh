#!/bin/bash

echo "🔄 Updating all dependencies to latest versions..."

# Backup current pubspec.yaml
cp pubspec.yaml pubspec.yaml.backup

# Update dependencies
echo "📦 Updating dependencies..."
flutter pub upgrade

# Check outdated packages
echo "📊 Checking for outdated packages..."
flutter pub outdated

# Fix any version conflicts
echo "🔧 Resolving version conflicts..."
flutter pub get

echo "✅ All dependencies updated!"
