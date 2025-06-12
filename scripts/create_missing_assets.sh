#!/bin/bash

echo "📁 Creating missing asset directories and files..."

# Create asset directories
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/fonts
mkdir -p assets/templates
mkdir -p assets/config

# Create placeholder app icon
cat > assets/icons/app_icon.png << 'EOF'
# This is a placeholder for the app icon
# Replace this with your actual app icon (512x512 PNG)
EOF

# Create placeholder font files
touch assets/fonts/Roboto-Regular.ttf
touch assets/fonts/Roboto-Bold.ttf
touch assets/fonts/OpenSans-Regular.ttf
touch assets/fonts/OpenSans-Bold.ttf

# Create placeholder images
touch assets/images/logo.png
touch assets/images/splash_background.png

# Create config files
cat > assets/config/app_config.json << 'EOF'
{
  "app_name": "GST Invoice App",
  "version": "1.0.0",
  "api_base_url": "https://api.gstinvoice.com",
  "features": {
    "offline_mode": true,
    "cloud_sync": true,
    "pdf_generation": true
  }
}
EOF

echo "✅ Asset directories and placeholder files created!"
