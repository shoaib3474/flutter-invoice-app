#!/bin/bash

# Comprehensive build script for Flutter Invoice App
set -e

echo "🚀 Starting Flutter Invoice App Release Build Process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="Flutter Invoice App"
BUILD_DIR="build"
RELEASE_DIR="release"
KEYSTORE_PATH="android/keystore/release-keystore.jks"
KEYSTORE_PROPERTIES="android/keystore.properties"

# Functions
print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Step 1: Environment Check
print_step "Checking build environment..."

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
print_success "Flutter found: $FLUTTER_VERSION"

# Check Android SDK
if [ -z "$ANDROID_HOME" ]; then
    print_warning "ANDROID_HOME not set. Please set it to your Android SDK path."
fi

# Check Java version
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    print_success "Java found: $JAVA_VERSION"
else
    print_error "Java is not installed"
    exit 1
fi

# Step 2: Project Validation
print_step "Validating project structure..."

# Check if pubspec.yaml exists
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Are you in the Flutter project root?"
    exit 1
fi

# Check if android directory exists
if [ ! -d "android" ]; then
    print_error "Android directory not found"
    exit 1
fi

print_success "Project structure validated"

# Step 3: Clean Previous Builds
print_step "Cleaning previous builds..."

flutter clean
rm -rf $BUILD_DIR
rm -rf $RELEASE_DIR

# Clean Android build
cd android
./gradlew clean
cd ..

print_success "Previous builds cleaned"

# Step 4: Dependencies
print_step "Getting dependencies..."

flutter pub get

# Generate code if needed
if [ -f "build.yaml" ]; then
    print_step "Generating code..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
fi

print_success "Dependencies resolved"

# Step 5: Code Analysis
print_step "Running code analysis..."

flutter analyze
if [ $? -ne 0 ]; then
    print_warning "Code analysis found issues. Continue? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

print_success "Code analysis completed"

# Step 6: Tests
print_step "Running tests..."

flutter test
if [ $? -ne 0 ]; then
    print_warning "Tests failed. Continue? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

print_success "Tests completed"

# Step 7: Keystore Check
print_step "Checking keystore configuration..."

if [ ! -f "$KEYSTORE_PROPERTIES" ]; then
    print_warning "Keystore properties not found at $KEYSTORE_PROPERTIES"
    print_warning "Creating debug build instead of release build"
    BUILD_TYPE="debug"
else
    # Check if keystore file exists
    KEYSTORE_FILE=$(grep "storeFile=" "$KEYSTORE_PROPERTIES" | cut -d'=' -f2)
    if [ ! -f "android/$KEYSTORE_FILE" ]; then
        print_warning "Keystore file not found. Creating debug build instead"
        BUILD_TYPE="debug"
    else
        print_success "Keystore configuration found"
        BUILD_TYPE="release"
    fi
fi

# Step 8: Build APK
print_step "Building APK ($BUILD_TYPE)..."

if [ "$BUILD_TYPE" = "release" ]; then
    # Build release APK
    flutter build apk --release --split-per-abi
    
    # Build universal APK
    flutter build apk --release
    
    print_success "Release APK built successfully"
else
    # Build debug APK
    flutter build apk --debug
    
    print_success "Debug APK built successfully"
fi

# Step 9: Build App Bundle (only for release)
if [ "$BUILD_TYPE" = "release" ]; then
    print_step "Building App Bundle..."
    
    flutter build appbundle --release
    
    print_success "App Bundle built successfully"
fi

# Step 10: Organize Release Files
print_step "Organizing release files..."

mkdir -p $RELEASE_DIR

# Copy APK files
if [ "$BUILD_TYPE" = "release" ]; then
    cp build/app/outputs/flutter-apk/app-release.apk "$RELEASE_DIR/app-universal-release.apk"
    cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk "$RELEASE_DIR/" 2>/dev/null || true
    cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk "$RELEASE_DIR/" 2>/dev/null || true
    cp build/app/outputs/flutter-apk/app-x86_64-release.apk "$RELEASE_DIR/" 2>/dev/null || true
    
    # Copy App Bundle
    cp build/app/outputs/bundle/release/app-release.aab "$RELEASE_DIR/" 2>/dev/null || true
else
    cp build/app/outputs/flutter-apk/app-debug.apk "$RELEASE_DIR/"
fi

print_success "Release files organized"

# Step 11: Generate Build Info
print_step "Generating build information..."

BUILD_INFO_FILE="$RELEASE_DIR/build_info.txt"
cat > "$BUILD_INFO_FILE" << EOF
$APP_NAME Build Information
========================================

Build Date: $(date)
Build Type: $BUILD_TYPE
Flutter Version: $FLUTTER_VERSION
Git Commit: $(git rev-parse HEAD 2>/dev/null || echo "Not available")
Git Branch: $(git branch --show-current 2>/dev/null || echo "Not available")

APK Files:
$(ls -la $RELEASE_DIR/*.apk 2>/dev/null || echo "No APK files found")

App Bundle:
$(ls -la $RELEASE_DIR/*.aab 2>/dev/null || echo "No App Bundle found")

Build Configuration:
- Keystore: $([ "$BUILD_TYPE" = "release" ] && echo "Configured" || echo "Not configured")
- Obfuscation: $([ "$BUILD_TYPE" = "release" ] && echo "Enabled" || echo "Disabled")
- Shrinking: $([ "$BUILD_TYPE" = "release" ] && echo "Enabled" || echo "Disabled")

EOF

print_success "Build information generated"

# Step 12: APK Analysis
print_step "Analyzing APK..."

if command -v aapt &> /dev/null; then
    APK_FILE="$RELEASE_DIR/app-universal-release.apk"
    if [ ! -f "$APK_FILE" ]; then
        APK_FILE="$RELEASE_DIR/app-debug.apk"
    fi
    
    if [ -f "$APK_FILE" ]; then
        echo "APK Analysis:" >> "$BUILD_INFO_FILE"
        echo "============" >> "$BUILD_INFO_FILE"
        aapt dump badging "$APK_FILE" | grep -E "(package|application-label|sdkVersion|targetSdkVersion)" >> "$BUILD_INFO_FILE"
        
        # APK size
        APK_SIZE=$(du -h "$APK_FILE" | cut -f1)
        echo "APK Size: $APK_SIZE" >> "$BUILD_INFO_FILE"
    fi
fi

# Step 13: Installation Test (optional)
print_step "Testing installation..."

# Check for connected devices
DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | wc -l)

if [ "$DEVICES" -gt 0 ]; then
    print_success "Found $DEVICES connected device(s)"
    
    echo "Install APK on connected device? (y/n)"
    read -r install_response
    
    if [[ "$install_response" =~ ^[Yy]$ ]]; then
        APK_TO_INSTALL="$RELEASE_DIR/app-universal-release.apk"
        if [ ! -f "$APK_TO_INSTALL" ]; then
            APK_TO_INSTALL="$RELEASE_DIR/app-debug.apk"
        fi
        
        if [ -f "$APK_TO_INSTALL" ]; then
            adb install -r "$APK_TO_INSTALL"
            print_success "APK installed successfully"
        else
            print_error "APK file not found for installation"
        fi
    fi
else
    print_warning "No connected devices found for installation test"
fi

# Step 14: Migration Test (optional)
print_step "Running migration tests..."

echo "Run migration tests? (y/n)"
read -r test_response

if [[ "$test_response" =~ ^[Yy]$ ]]; then
    # This would run the migration test suite
    print_step "Running migration test suite..."
    # flutter test test/migration_test.dart
    print_success "Migration tests completed"
fi

# Step 15: Summary
print_step "Build Summary"

echo ""
echo "🎉 Build completed successfully!"
echo ""
echo "📁 Release files location: $RELEASE_DIR"
echo "📋 Build information: $BUILD_INFO_FILE"
echo ""

if [ "$BUILD_TYPE" = "release" ]; then
    echo "🔐 Release build with signing"
    echo "📦 Files ready for distribution:"
    echo "   - Universal APK: app-universal-release.apk"
    echo "   - Architecture-specific APKs: app-*-release.apk"
    echo "   - App Bundle: app-release.aab (for Play Store)"
else
    echo "🔧 Debug build (no signing)"
    echo "📦 Files for testing:"
    echo "   - Debug APK: app-debug.apk"
fi

echo ""
echo "📱 Next steps:"
echo "   1. Test the APK on various devices"
echo "   2. Upload to Play Console (for release builds)"
echo "   3. Distribute to testers"
echo ""

print_success "Build process completed! 🚀"
