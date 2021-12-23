# SwiftOpenCV

SwiftOpenCV is Swift package that wraps OpenCV compiled xcframework and an Objective-C++ algorithm that extracts objects from images ignoring backgrounds.

New OpenCV version build steps:
- Checkout the relevant release from [OpenCV repository](https://github.com/opencv/opencv)
- Compile: ```python3 platforms/apple/build_xcframework.py -o build --iphoneos_archs arm64,armv7 --iphonesimulator_archs x86_64 --build_only_specified_archs --without=video```
- Zip .xcframework file
- Upload file as asset to release
- Add asset url to Package.swift 'url' property
- Calculate zipped file checksum: ```swift package --package-path /Users/valentin/Projects/opencv-wrapper compute-checksum opencv2.xcframework.zip```, and add the calculated checksum to Package.swift 'checksum' property
