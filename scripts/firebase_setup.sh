#!/bin/bash

# TastyGo Firebase Configuration Script
# This script helps you set up Firebase for your TastyGo app

echo "🔥 TastyGo Firebase Configuration Helper"
echo "=========================================="
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed."
    echo "📦 Please install it first:"
    echo "   npm install -g firebase-tools"
    echo ""
    exit 1
fi

# Check if FlutterFire CLI is installed
if ! command -v flutterfire &> /dev/null; then
    echo "❌ FlutterFire CLI is not installed."
    echo "📦 Installing FlutterFire CLI..."
    dart pub global activate flutterfire_cli
fi

echo "✅ Prerequisites installed!"
echo ""

# Step 1: Login to Firebase
echo "Step 1: Firebase Login"
echo "------------------------"
echo "Please log in to Firebase (your browser will open):"
firebase login
echo ""

# Step 2: Configure FlutterFire
echo "Step 2: Configure FlutterFire"
echo "------------------------------"
echo "This will configure Firebase for all platforms (iOS, Android, Web, macOS)."
echo "Please select your Firebase project when prompted."
echo ""
read -p "Press Enter to continue..."

flutterfire configure

echo ""
echo "✅ Firebase configuration complete!"
echo ""

# Step 3: Instructions for Firestore setup
echo "Step 3: Firestore Database Setup"
echo "---------------------------------"
echo "Please complete these steps manually in the Firebase Console:"
echo ""
echo "1. Go to: https://console.firebase.google.com"
echo "2. Select your project"
echo "3. Click 'Firestore Database' in the left menu"
echo "4. Click 'Create database'"
echo "5. Choose 'Start in TEST MODE' (for development)"
echo "6. Select a location closest to you"
echo "7. Click 'Enable'"
echo ""
read -p "Press Enter when you have completed Firestore setup..."

# Step 4: Instructions for Authentication setup
echo ""
echo "Step 4: Enable Email/Password Authentication"
echo "---------------------------------------------"
echo "1. In Firebase Console, click 'Authentication'"
echo "2. Click 'Get started' if it's your first time"
echo "3. Go to the 'Sign-in method' tab"
echo "4. Click on 'Email/Password'"
echo "5. Enable it and click 'Save'"
echo ""
read -p "Press Enter when you have enabled Email/Password authentication..."

echo ""
echo "🎉 Firebase setup complete!"
echo ""
echo "Next steps:"
echo "1. Run sample data seeding script to populate Firestore"
echo "2. Test your app with 'flutter run'"
echo ""
echo "Configuration files created:"
echo "  - lib/firebase_options.dart"
echo "  - android/app/google-services.json (if Android was selected)"
echo "  - ios/Runner/GoogleService-Info.plist (if iOS was selected)"
echo ""
