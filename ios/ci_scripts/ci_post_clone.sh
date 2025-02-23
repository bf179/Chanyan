#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# The default execution directory of this script is the ci_scripts directory.
cd $CI_PRIMARY_REPOSITORY_PATH # change working directory to the root of your cloned repo.

# Specify the Flutter tag you want to checkout.
FLUTTER_TAG="3.19.6"

# Install Flutter using git with the specified tag.
git clone https://github.com/flutter/flutter.git --depth 1 --branch $FLUTTER_TAG $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"


# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios

# Install Flutter dependencies.
flutter pub get

# Install CocoaPods using Homebrew.
HOMEBREW_NO_AUTO_UPDATE=1 # disable homebrew's automatic updates.
brew install cocoapods

# Install CocoaPods dependencies.
cd ios && pod install # run `pod install` in the `ios` directory.

exit 0