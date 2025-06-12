#!/bin/bash

# Production APK Build Script for GST Invoice App
# This script builds a production-ready APK with all optimizations

set -e  # Exit on any error

echo "🚀 Starting Production APK Build for GST Invoice App"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="GST_Invoice_App"
BUILD_TYPE="release"
SPLIT_PER_ABI=true
OBFUSCATE=true
SHRINK_RESOURCES=true

# Get current timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BUILD_DIR="build_output_$TIMESTAMP"

echo -e "${BLUE}Build Configuration:${NC}"
echo "  App Name: $APP_NAME"
echo "  Build Type: $BUILD_TYPE"
echo "  Split per ABI: $SPLIT_PER_ABI"
echo "  Obfuscate: $OBFUSCATE"
echo "  Shrink Resources: $SHRINK_RESOURCES"
echo "  Output Directory: $BUILD_DIR"
echo ""

# Create output directory
mkdir -p "$BUILD_DIR"

# Step 1: Clean previous builds
echo -e "${YELLOW}Step 1: Cleaning previous builds...${NC}"
flutter clean
if [ -d "android" ]; then
    cd android
    ./gradlew clean
    cd ..
fi
echo -e "${GREEN}✓ Clean completed${NC}"
echo ""

# Step 2: Get dependencies
echo -e "${YELLOW}Step 2: Getting dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies updated${NC}"
echo ""

# Step 3: Generate code
echo -e "${YELLOW}Step 3: Generating code...${NC}"
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    flutter packages pub run build_runner build --delete-conflicting-outputs
    echo -e "${GREEN}✓ Code generation completed${NC}"
else
    echo -e "${BLUE}ℹ No code generation needed${NC}"
fi
echo ""

# Step 4: Build APK
echo -e "${YELLOW}Step 4: Building production APK...${NC}"

# Construct build command
BUILD_CMD="flutter build apk --$BUILD_TYPE"

if [ "$SPLIT_PER_ABI" = true ]; then
    BUILD_CMD="$BUILD_CMD --split-per-abi"
fi

if [ "$OBFUSCATE" = true ]; then
    BUILD_CMD="$BUILD_CMD --obfuscate --split-debug-info=$BUILD_DIR/symbols"
fi

if [ "$SHRINK_RESOURCES" = true ]; then
    BUILD_CMD="$BUILD_CMD --shrink"
fi

# Add target platforms
BUILD_CMD="$BUILD_CMD --target-platform android-arm,android-arm64,android-x64"

echo "Executing: $BUILD_CMD"
eval $BUILD_CMD

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ APK build completed successfully${NC}"
else
    echo -e "${RED}✗ APK build failed${NC}"
    exit 1
fi
echo ""

# Step 5: Copy APKs to output directory
echo -e "${YELLOW}Step 5: Organizing build outputs...${NC}"

APK_SOURCE_DIR="build/app/outputs/flutter-apk"
if [ -d "$APK_SOURCE_DIR" ]; then
    # Copy APK files
    cp -r "$APK_SOURCE_DIR"/* "$BUILD_DIR/"
    
    # Rename APKs with timestamp
    cd "$BUILD_DIR"
    for apk in *.apk; do
        if [ -f "$apk" ]; then
            # Extract architecture from filename
            if [[ $apk == *"arm64-v8a"* ]]; then
                ARCH="arm64"
            elif [[ $apk == *"armeabi-v7a"* ]]; then
                ARCH="arm32"
            elif [[ $apk == *"x86_64"* ]]; then
                ARCH="x64"
            else
                ARCH="universal"
            fi
            
            NEW_NAME="${APP_NAME}_${ARCH}_${TIMESTAMP}.apk"
            mv "$apk" "$NEW_NAME"
            echo "  ✓ Created: $NEW_NAME"
        fi
    done
    cd ..
else
    echo -e "${RED}✗ APK output directory not found${NC}"
    exit 1
fi
echo ""

# Step 6: Generate build report
echo -e "${YELLOW}Step 6: Generating build report...${NC}"

REPORT_FILE="$BUILD_DIR/build_report.txt"
cat > "$REPORT_FILE" << EOF
GST Invoice App - Build Report
==============================

Build Information:
- Build Date: $(date)
- Build Type: $BUILD_TYPE
- Flutter Version: $(flutter --version | head -n 1)
- Dart Version: $(dart --version)

Configuration:
- Split per ABI: $SPLIT_PER_ABI
- Code Obfuscation: $OBFUSCATE
- Resource Shrinking: $SHRINK_RESOURCES

Generated APKs:
EOF

# Add APK information to report
cd "$BUILD_DIR"
for apk in *.apk; do
    if [ -f "$apk" ]; then
        SIZE=$(ls -lh "$apk" | awk '{print $5}')
        echo "- $apk ($SIZE)" >> build_report.txt
    fi
done
cd ..

echo -e "${GREEN}✓ Build report generated${NC}"
echo ""

# Step 7: Create checksums
echo -e "${YELLOW}Step 7: Creating checksums...${NC}"
cd "$BUILD_DIR"
sha256sum *.apk > checksums.sha256
echo -e "${GREEN}✓ Checksums created${NC}"
cd ..
echo ""

# Step 8: Display summary
echo -e "${GREEN}🎉 Build completed successfully!${NC}"
echo "=================================================="
echo -e "${BLUE}Output Directory:${NC} $BUILD_DIR"
echo -e "${BLUE}Generated Files:${NC}"

cd "$BUILD_DIR"
ls -la
cd ..

echo ""
echo -e "${BLUE}APK Information:${NC}"
cd "$BUILD_DIR"
for apk in *.apk; do
    if [ -f "$apk" ]; then
        SIZE=$(ls -lh "$apk" | awk '{print $5}')
        echo "  📱 $apk - $SIZE"
    fi
done
cd ..

echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Test the APK on different devices"
echo "2. Upload to Google Play Console or distribute directly"
echo "3. Keep the symbols directory for crash reporting"
echo ""

# Optional: Open output directory
if command -v xdg-open > /dev/null; then
    echo -e "${BLUE}Opening output directory...${NC}"
    xdg-open "$BUILD_DIR"
elif command -v open > /dev/null; then
    echo -e "${BLUE}Opening output directory...${NC}"
    open "$BUILD_DIR"
fi

echo -e "${GREEN}Build script completed! 🚀${NC}"
