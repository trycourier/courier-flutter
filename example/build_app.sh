#!/bin/bash

options=("Android" "iOS")

PS3="Which platform to build? "
select opt in "${options[@]}"
do
  case $opt in
    "Android")

      # Build Android
      flutter build appbundle -t lib/main.dart
      open build/app/outputs/bundle/release

      break
      ;;
    "iOS")

      # Build iOS
      flutter build ipa lib/main.dart
      open build/ios/archive/Runner.xcarchive

      break
      ;;
    *)
      # code to execute if an invalid option is selected
      break
      ;;
  esac
done
