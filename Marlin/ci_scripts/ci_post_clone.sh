#!/bin/sh


# Install CocoaPods using Homebrew.
brew install cocoapods

# Move up a directory for the custom Podfile copy commands (To copy Acknowledgements.plist into the Settings.bundle)
cd ..

# Install dependencies you manage with CocoaPods.
pod install