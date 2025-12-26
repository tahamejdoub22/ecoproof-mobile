#!/bin/bash

# Script to update Flutter and run the EcoProof mobile app

echo "🔄 Updating Flutter to the latest version..."
flutter upgrade

echo ""
echo "📦 Getting project dependencies..."
flutter pub get

echo ""
echo "🚀 Running the app..."
flutter run

