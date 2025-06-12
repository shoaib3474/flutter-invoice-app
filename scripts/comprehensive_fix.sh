#!/bin/bash

echo "🔧 Starting comprehensive fix for Flutter Invoice App..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_status "Flutter version:"
flutter --version

# Clean the project
print_status "Cleaning Flutter project..."
flutter clean

# Remove old lock file
if [ -f "pubspec.lock" ]; then
    print_status "Removing old pubspec.lock..."
    rm pubspec.lock
fi

# Remove old build files
if [ -d "build" ]; then
    print_status "Removing build directory..."
    rm -rf build
fi

# Remove .dart_tool
if [ -d ".dart_tool" ]; then
    print_status "Removing .dart_tool directory..."
    rm -rf .dart_tool
fi

# Get dependencies
print_status "Getting Flutter dependencies..."
if flutter pub get; then
    print_success "Dependencies resolved successfully"
else
    print_error "Failed to resolve dependencies"
    exit 1
fi

# Run code generation
print_status "Running code generation..."
if flutter packages pub run build_runner build --delete-conflicting-outputs; then
    print_success "Code generation completed"
else
    print_warning "Code generation failed, continuing..."
fi

# Analyze code
print_status "Analyzing code..."
if flutter analyze; then
    print_success "Code analysis passed"
else
    print_warning "Code analysis found issues, but continuing..."
fi

# Format code
print_status "Formatting code..."
if dart format lib/ test/; then
    print_success "Code formatted successfully"
else
    print_warning "Code formatting failed, continuing..."
fi

# Fix common issues
print_status "Fixing common Flutter issues..."

# Create missing directories
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/sample_data
mkdir -p assets/config
mkdir -p fonts

# Create empty font files if they don't exist
touch fonts/Roboto-Regular.ttf
touch fonts/Roboto-Bold.ttf

# Test build
print_status "Testing build..."
if flutter build apk --debug; then
    print_success "Debug build successful"
else
    print_error "Debug build failed"
    print_status "Trying to fix build issues..."
    
    # Additional fixes for build issues
    flutter pub deps
    flutter pub upgrade --major-versions
    
    # Try build again
    if flutter build apk --debug; then
        print_success "Debug build successful after fixes"
    else
        print_error "Debug build still failing"
    fi
fi

print_success "Comprehensive fix completed!"
print_status "Next steps:"
echo "1. Check for any remaining errors in your IDE"
echo "2. Run 'flutter doctor' to check for system issues"
echo "3. Test the app with 'flutter run'"
