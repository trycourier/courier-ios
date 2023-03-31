cat Sources/Courier_iOS/Courier_iOS.swift | while read LINE; do
  if [[ $LINE == *"internal static let version"* ]]; then

    # Get version from Courier file
    VERSION=$(echo $LINE | sed -e 's/.*"\(.*\)".*/\1/')

    cat Courier-iOS.podspec | while read SPEC_VERSION; do
      if [[ $SPEC_VERSION == *"s.version          ="* ]]; then

        # Replace PODSPEC version
        NEW_SPEC_VERSION="s.version          = '$VERSION'"
        if [[ $SPEC_VERSION != "" && $NEW_SPEC_VERSION != "" ]]; then
          sed -i '.bak' "s/$SPEC_VERSION/$NEW_SPEC_VERSION/g" "Courier_iOS.podspec"
        fi

      fi
    done

    # Delete backup file
    rm "Courier_iOS.podspec.bak"

    # Bump the version
    git add .
    git commit -m "Bump"
    git push

    # Create a new tag with the version and push
    git tag $VERSION
    git push --tags

    # Ensure github is installed
    brew install gh
    gh auth login

    # gh release create
    gh release create $VERSION --generate-notes
    
    # Push to pods
    pod trunk push

  fi
done
