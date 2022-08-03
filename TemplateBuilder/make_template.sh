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

"

echo 'Courier Service Template is ready!'
echo 'You can close this terminal window.'
echo '\n'
