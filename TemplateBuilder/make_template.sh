#!/bin/sh

# Create Templates folder (if needed)
mkdir -p ~/Library/Developer/Xcode/Templates >/dev/null 2>&1

# Delete the old Template
rm -rf ~/Library/Developer/Xcode/Templates/Courier\ Service.xctemplate

# Create the new Template
cp -rf Courier\ Service.xctemplate ~/Library/Developer/Xcode/Templates/Courier\ Service.xctemplate

echo "
    
    ^-
  '( 🍥 >
   _) (
  /    )
 /_,'  /
   \  /
 ===m""m===

Courier Service Template is ready!

"

read -p "→ Press \"enter ↩\" to setup the Courier Service"
open https://github.com/trycourier/courier-ios#recommended-setup-the-courier-notification-service

echo "

Launching Courier Service setup tutorial...

If your broswer did not open the link, you can see next steps here:
https://github.com/trycourier/courier-ios#recommended-setup-the-courier-notification-service

"

read -p "→ Press \"enter ↩\" to close this terminal session"
osascript -e 'tell application "Terminal" to close first window'
