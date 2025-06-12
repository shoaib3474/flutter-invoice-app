#!/bin/bash

echo "🚀 Deploying Firebase Cloud Functions"
echo "====================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "Please run this script from the Flutter project root directory"
    exit 1
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI not found. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if logged in to Firebase
print_status "Checking Firebase authentication..."
firebase projects:list &> /dev/null
if [ $? -ne 0 ]; then
    print_error "Not logged in to Firebase. Please run: firebase login"
    exit 1
fi

# Check if functions directory exists
if [ ! -d "functions" ]; then
    print_error "Functions directory not found. Please run: firebase init functions"
    exit 1
fi

# Navigate to functions directory
cd functions

# Install dependencies
print_status "Installing function dependencies..."
npm install

if [ $? -ne 0 ]; then
    print_error "Failed to install dependencies"
    exit 1
fi

print_success "Dependencies installed successfully"

# Check if Stripe configuration exists
print_status "Checking Stripe configuration..."
firebase functions:config:get stripe.secret_key &> /dev/null
if [ $? -ne 0 ]; then
    print_warning "Stripe secret key not configured"
    echo "Please set your Stripe configuration:"
    echo "firebase functions:config:set stripe.secret_key=\"sk_test_your_secret_key_here\""
    echo "firebase functions:config:set stripe.webhook_secret=\"whsec_your_webhook_secret_here\""
    echo ""
    read -p "Do you want to continue without Stripe configuration? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    print_success "Stripe configuration found"
fi

# Go back to project root
cd ..

# Deploy functions
print_status "Deploying Cloud Functions..."
firebase deploy --only functions

if [ $? -eq 0 ]; then
    print_success "Cloud Functions deployed successfully!"
    
    # Get function URLs
    print_status "Function URLs:"
    firebase functions:list
    
    print_status "Next steps:"
    echo "1. Configure Stripe webhooks with your function URLs"
    echo "2. Test the functions using the app's test screens"
    echo "3. Monitor function logs: firebase functions:log"
    
else
    print_error "Failed to deploy Cloud Functions"
    print_status "Troubleshooting tips:"
    echo "1. Check function logs: firebase functions:log"
    echo "2. Verify your Firebase project has the Blaze plan"
    echo "3. Check your function code for syntax errors"
    echo "4. Ensure all dependencies are installed"
    exit 1
fi

print_success "🎉 Deployment completed!"
