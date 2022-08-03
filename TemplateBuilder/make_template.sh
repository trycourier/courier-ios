echo 'Making Courier Service Template 🥚'

# Create Templates folder (if needed)
mkdir -p ~/Library/Developer/Xcode/Templates >/dev/null 2>&1

# Delete the old Template
rm -rf ~/Library/Developer/Xcode/Templates/Courier\ Service.xctemplate

# Create the new Template
cp -rf Courier\ Notification\ Service\ Extension.xctemplate ~/Library/Developer/Xcode/Templates/Courier\ Service.xctemplate

echo 'Courier Service Template Created 🐣'
