
xcodebuild archive \
  -project CustomVideoplyer.xcodeproj \
  -scheme CustomVideoplyer \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/CustomVideoplyer-iOS \
  -derivedDataPath .derivedData/archive_build \
  SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive \
  -project CustomVideoplyer.xcodeproj \
  -scheme CustomVideoplyer \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -archivePath build/CustomVideoplyer-Simulator \
  -derivedDataPath .derivedData/archive_build \
  SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
  -framework build/CustomVideoplyer-iOS.xcarchive/Products/Library/Frameworks/CustomVideoplyer.framework \
  -framework build/CustomVideoplyer-Simulator.xcarchive/Products/Library/Frameworks/CustomVideoplyer.framework \
  -output build/CustomVideoplyer.xcframework
