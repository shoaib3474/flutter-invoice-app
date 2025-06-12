#!/bin/bash

# Final Production APK Build Script for GST Invoice App
# This script performs a complete clean build with all optimizations

set -e  # Exit on any error

echo "🚀 Building Final Production APK for GST Invoice App"
echo "====================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="GST_Invoice_App"
VERSION="1.0.0"
BUILD_NUMBER="1"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BUILD_DIR="production_build_$TIMESTAMP"
SYMBOLS_DIR="$BUILD_DIR/symbols"

echo -e "${BLUE}Build Configuration:${NC}"
echo "  📱 App Name: $APP_NAME"
echo "  🔢 Version: $VERSION+$BUILD_NUMBER"
echo "  📅 Build Time: $(date)"
echo "  📁 Output Directory: $BUILD_DIR"
echo "  🔒 Obfuscation: Enabled"
echo "  📦 Split APKs: Enabled"
echo "  🗜️ Resource Shrinking: Enabled"
echo ""

# Create output directories
mkdir -p "$BUILD_DIR"
mkdir -p "$SYMBOLS_DIR"

# Step 1: Environment Check
echo -e "${YELLOW}Step 1: Checking build environment...${NC}"

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter not found. Please install Flutter first.${NC}"
    exit 1
fi

# Check Android SDK
if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
    echo -e "${RED}✗ Android SDK not found. Please set ANDROID_HOME or ANDROID_SDK_ROOT.${NC}"
    exit 1
fi

# Check Java
if ! command -v java &> /dev/null; then
    echo -e "${RED}✗ Java not found. Please install Java JDK.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Build environment verified${NC}"
echo ""

# Step 2: Flutter Doctor Check
echo -e "${YELLOW}Step 2: Running Flutter doctor...${NC}"
flutter doctor --android-licenses > /dev/null 2>&1 || true
DOCTOR_OUTPUT=$(flutter doctor)
echo "$DOCTOR_OUTPUT"

if echo "$DOCTOR_OUTPUT" | grep -q "No issues found"; then
    echo -e "${GREEN}✓ Flutter doctor passed${NC}"
else
    echo -e "${YELLOW}⚠ Flutter doctor found some issues, but continuing...${NC}"
fi
echo ""

# Step 3: Clean Everything
echo -e "${YELLOW}Step 3: Performing deep clean...${NC}"

# Flutter clean
flutter clean

# Clean Android build
if [ -d "android" ]; then
    cd android
    if [ -f "gradlew" ]; then
        ./gradlew clean
    elif [ -f "gradlew.bat" ]; then
        ./gradlew.bat clean
    fi
    cd ..
fi

# Remove build directories
rm -rf build/
rm -rf .dart_tool/
rm -rf android/.gradle/
rm -rf android/app/build/

echo -e "${GREEN}✓ Deep clean completed${NC}"
echo ""

# Step 4: Get Dependencies
echo -e "${YELLOW}Step 4: Getting dependencies...${NC}"
flutter pub get

# Check for dependency issues
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to get dependencies${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Dependencies updated${NC}"
echo ""

# Step 5: Code Generation
echo -e "${YELLOW}Step 5: Running code generation...${NC}"

# Check if build_runner is needed
if grep -q "build_runner" pubspec.yaml; then
    echo "Running build_runner..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    echo -e "${GREEN}✓ Code generation completed${NC}"
else
    echo -e "${BLUE}ℹ No code generation needed${NC}"
fi
echo ""

# Step 6: Pre-build Analysis
echo -e "${YELLOW}Step 6: Running pre-build analysis...${NC}"

# Run flutter analyze
ANALYZE_OUTPUT=$(flutter analyze 2>&1)
ANALYZE_EXIT_CODE=$?

if [ $ANALYZE_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ Static analysis passed${NC}"
else
    echo -e "${YELLOW}⚠ Static analysis found issues:${NC}"
    echo "$ANALYZE_OUTPUT"
    echo -e "${YELLOW}Continuing with build...${NC}"
fi
echo ""

# Step 7: Build Production APK
echo -e "${YELLOW}Step 7: Building production APK...${NC}"

# Build command with all optimizations
BUILD_CMD="flutter build apk --release"
BUILD_CMD="$BUILD_CMD --split-per-abi"
BUILD_CMD="$BUILD_CMD --obfuscate"
BUILD_CMD="$BUILD_CMD --split-debug-info=$SYMBOLS_DIR"
BUILD_CMD="$BUILD_CMD --shrink"
BUILD_CMD="$BUILD_CMD --target-platform android-arm,android-arm64,android-x64"

echo "Executing: $BUILD_CMD"
echo ""

# Execute build with progress
eval $BUILD_CMD

BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ APK build completed successfully${NC}"
else
    echo -e "${RED}✗ APK build failed with exit code $BUILD_EXIT_CODE${NC}"
    exit 1
fi
echo ""

# Step 8: Organize Build Outputs
echo -e "${YELLOW}Step 8: Organizing build outputs...${NC}"

APK_SOURCE_DIR="build/app/outputs/flutter-apk"
if [ -d "$APK_SOURCE_DIR" ]; then
    # Copy APK files
    cp -r "$APK_SOURCE_DIR"/* "$BUILD_DIR/"
    
    # Rename APKs with proper naming
    cd "$BUILD_DIR"
    for apk in *.apk; do
        if [ -f "$apk" ]; then
            # Extract architecture from filename
            if [[ $apk == *"arm64-v8a"* ]]; then
                ARCH="arm64"
                ARCH_FULL="ARM64 (64-bit)"
            elif [[ $apk == *"armeabi-v7a"* ]]; then
                ARCH="arm32"
                ARCH_FULL="ARM32 (32-bit)"
            elif [[ $apk == *"x86_64"* ]]; then
                ARCH="x64"
                ARCH_FULL="x86_64 (64-bit)"
            else
                ARCH="universal"
                ARCH_FULL="Universal (All architectures)"
            fi
            
            NEW_NAME="${APP_NAME}_v${VERSION}_${ARCH}_${TIMESTAMP}.apk"
            mv "$apk" "$NEW_NAME"
            
            # Get file size
            SIZE=$(ls -lh "$NEW_NAME" | awk '{print $5}')
            echo -e "  ${GREEN}✓${NC} Created: ${CYAN}$NEW_NAME${NC} (${PURPLE}$SIZE${NC}) - $ARCH_FULL"
        fi
    done
    cd ..
else
    echo -e "${RED}✗ APK output directory not found${NC}"
    exit 1
fi
echo ""

# Step 9: Generate Build Report
echo -e "${YELLOW}Step 9: Generating comprehensive build report...${NC}"

REPORT_FILE="$BUILD_DIR/BUILD_REPORT.md"
cat > "$REPORT_FILE" << EOF
# GST Invoice App - Production Build Report

## Build Information
- **App Name**: $APP_NAME
- **Version**: $VERSION+$BUILD_NUMBER
- **Build Date**: $(date)
- **Build Type**: Production Release
- **Build ID**: $TIMESTAMP

## Environment
- **Flutter Version**: $(flutter --version | head -n 1)
- **Dart Version**: $(dart --version)
- **Platform**: $(uname -s) $(uname -m)
- **Java Version**: $(java -version 2>&1 | head -n 1)

## Build Configuration
- ✅ Code Obfuscation: Enabled
- ✅ Resource Shrinking: Enabled
- ✅ Split APKs: Enabled (ARM32, ARM64, x86_64)
- ✅ Debug Info: Stripped (symbols saved separately)
- ✅ Proguard: Enabled
- ✅ R8 Optimization: Enabled

## Generated APKs
EOF

# Add APK information to report
cd "$BUILD_DIR"
for apk in *.apk; do
    if [ -f "$apk" ]; then
        SIZE=$(ls -lh "$apk" | awk '{print $5}')
        if [[ $apk == *"arm64"* ]]; then
            ARCH_DESC="ARM64 (64-bit) - Recommended for modern devices"
        elif [[ $apk == *"arm32"* ]]; then
            ARCH_DESC="ARM32 (32-bit) - Compatible with older devices"
        elif [[ $apk == *"x64"* ]]; then
            ARCH_DESC="x86_64 (64-bit) - For emulators and x86 devices"
        else
            ARCH_DESC="Universal - Works on all devices (larger size)"
        fi
        echo "- **$apk** ($SIZE) - $ARCH_DESC" >> BUILD_REPORT.md
    fi
done

cat >> BUILD_REPORT.md << EOF

## Security Features
- 🔒 Code obfuscation applied
- 🔒 Debug symbols stripped
- 🔒 Resource shrinking enabled
- 🔒 Proguard rules applied
- 🔒 Release signing (if keystore configured)

## Installation Instructions
1. Enable "Unknown Sources" in Android settings
2. Download the appropriate APK for your device:
   - **ARM64**: For most modern Android devices (recommended)
   - **ARM32**: For older Android devices
   - **x86_64**: For Android emulators
3. Install the APK file
4. Grant necessary permissions when prompted

## Troubleshooting
- If installation fails, ensure you have enough storage space
- For "App not installed" error, try uninstalling any previous version
- For permission issues, check Android security settings

## Support
- App Version: $VERSION
- Build ID: $TIMESTAMP
- Contact: [Your support email]

---
*Generated on $(date) by GST Invoice App Build System*
EOF

cd ..

echo -e "${GREEN}✓ Build report generated${NC}"
echo ""

# Step 10: Create Checksums
echo -e "${YELLOW}Step 10: Creating security checksums...${NC}"
cd "$BUILD_DIR"

# Create SHA256 checksums
sha256sum *.apk > checksums.sha256

# Create MD5 checksums for compatibility
md5sum *.apk > checksums.md5 2>/dev/null || {
    # Fallback for systems without md5sum
    for apk in *.apk; do
        if command -v md5 &> /dev/null; then
            md5 "$apk" >> checksums.md5
        fi
    done
}

echo -e "${GREEN}✓ Security checksums created${NC}"
cd ..
echo ""

# Step 11: Build Summary
echo -e "${GREEN}🎉 Production APK Build Completed Successfully!${NC}"
echo "=============================================="
echo ""
echo -e "${BLUE}📁 Output Directory:${NC} $BUILD_DIR"
echo -e "${BLUE}📊 Build Report:${NC} $BUILD_DIR/BUILD_REPORT.md"
echo -e "${BLUE}🔒 Debug Symbols:${NC} $SYMBOLS_DIR"
echo ""

echo -e "${CYAN}📱 Generated APKs:${NC}"
cd "$BUILD_DIR"
for apk in *.apk; do
    if [ -f "$apk" ]; then
        SIZE=$(ls -lh "$apk" | awk '{print $5}')
        echo -e "  ${GREEN}•${NC} $apk ${PURPLE}($SIZE)${NC}"
    fi
done
cd ..

echo ""
echo -e "${CYAN}🔐 Security Checksums:${NC}"
echo -e "  ${GREEN}•${NC} SHA256: $BUILD_DIR/checksums.sha256"
echo -e "  ${GREEN}•${NC} MD5: $BUILD_DIR/checksums.md5"

echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. 🧪 Test APKs on different devices"
echo "2. 📤 Upload to Google Play Console or distribute directly"
echo "3. 💾 Keep symbols directory for crash reporting"
echo "4. 📋 Review build report for details"
echo ""

# Optional: Open output directory
if command -v xdg-open > /dev/null; then
    echo -e "${BLUE}📂 Opening output directory...${NC}"
    xdg-open "$BUILD_DIR"
elif command -v open > /dev/null; then
    echo -e "${BLUE}📂 Opening output directory...${NC}"
    open "$BUILD_DIR"
fi

echo -e "${GREEN}🚀 Production build completed successfully!${NC}"
echo -e "${PURPLE}Build ID: $TIMESTAMP${NC}"
