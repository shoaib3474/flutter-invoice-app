#!/bin/bash

echo "🔥 Firebase Setup Script for GST Invoice App"
echo "============================================="

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

# Check if Firebase CLI is installed
print_status "Checking Firebase CLI installation..."
if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI not found. Installing..."
    npm install -g firebase-tools
    if [ $? -eq 0 ]; then
        print_success "Firebase CLI installed successfully"
    else
        print_error "Failed to install Firebase CLI"
        exit 1
    fi
else
    print_success "Firebase CLI is already installed"
fi

# Check if FlutterFire CLI is installed
print_status "Checking FlutterFire CLI installation..."
if ! command -v flutterfire &> /dev/null; then
    print_error "FlutterFire CLI not found. Installing..."
    dart pub global activate flutterfire_cli
    if [ $? -eq 0 ]; then
        print_success "FlutterFire CLI installed successfully"
    else
        print_error "Failed to install FlutterFire CLI"
        exit 1
    fi
else
    print_success "FlutterFire CLI is already installed"
fi

# Login to Firebase
print_status "Checking Firebase authentication..."
firebase projects:list &> /dev/null
if [ $? -ne 0 ]; then
    print_warning "Not logged in to Firebase. Please login..."
    firebase login
    if [ $? -ne 0 ]; then
        print_error "Failed to login to Firebase"
        exit 1
    fi
else
    print_success "Already logged in to Firebase"
fi

# Configure FlutterFire
print_status "Configuring FlutterFire..."
print_warning "Please select or create a Firebase project when prompted"
flutterfire configure

if [ $? -eq 0 ]; then
    print_success "FlutterFire configuration completed"
else
    print_error "FlutterFire configuration failed"
    exit 1
fi

# Install dependencies
print_status "Installing Flutter dependencies..."
flutter pub get

if [ $? -eq 0 ]; then
    print_success "Dependencies installed successfully"
else
    print_error "Failed to install dependencies"
    exit 1
fi

# Initialize Firebase project (if firebase.json doesn't exist)
if [ ! -f "firebase.json" ]; then
    print_status "Initializing Firebase project..."
    firebase init firestore functions hosting
    
    if [ $? -eq 0 ]; then
        print_success "Firebase project initialized"
    else
        print_error "Failed to initialize Firebase project"
        exit 1
    fi
else
    print_success "Firebase project already initialized"
fi

# Set up Firestore security rules
print_status "Setting up Firestore security rules..."
cat > firestore.rules << 'EOF'
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null 
        && request.auth.uid == userId;
    }
    
    // Public read access for HSN/SAC codes
    match /hsn_sac_codes/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Public read access for GST rates
    match /gst_rates/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
EOF

print_success "Firestore security rules created"

# Set up Firebase Storage rules
print_status "Setting up Firebase Storage security rules..."
cat > storage.rules << 'EOF'
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can only access their own files
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null 
        && request.auth.uid == userId;
    }
    
    // Public read access for app assets
    match /public/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
EOF

print_success "Firebase Storage security rules created"

# Deploy security rules
print_status "Deploying security rules..."
firebase deploy --only firestore:rules,storage

if [ $? -eq 0 ]; then
    print_success "Security rules deployed successfully"
else
    print_warning "Failed to deploy security rules (you can do this manually later)"
fi

print_success "🎉 Firebase setup completed successfully!"
print_status "Next steps:"
echo "  1. Run: flutter run"
echo "  2. Go to Settings → Test Screens → Firebase Setup Test"
echo "  3. Deploy Cloud Functions: ./scripts/deploy_functions.sh"
echo "  4. Configure Stripe keys in lib/config/stripe_config.dart"
