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

Courier Service Template is ready! 🐣

Next, in Xcode, go to:
1. File > New > Target
2. Type \"Courier\" in the filter search box
3. Click Next
4. Type a Product Name
5. Click Finish
6. Enjoy!

You are safe to close this terminal window.

"
