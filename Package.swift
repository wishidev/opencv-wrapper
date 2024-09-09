// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftOpenCV",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "SwiftOpenCV",
            targets: ["SwiftOpenCV", "ObjCOpenCV"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftOpenCV",
            dependencies: ["ObjCOpenCV"],
            path: "Sources/Swift"
        ),
        .target(
            name: "ObjCOpenCV",
            dependencies: ["opencv2"],
            path: "Sources/ObjCOpenCV",
            cxxSettings: [
                .headerSearchPath("include")
            ]
        ),
        .binaryTarget(
            name: "opencv2",
            url: "https://github.com/wishidev/opencv-wrapper/releases/download/v4.10.0/opencv-4.10.0-ios-framework.zip",
            checksum: "cbd21c62a4cfdd4cfe7e69c8601d23976e2d2bd05a912d0759debb3052c257db"
        ),
        .testTarget(
            name: "SwiftOpenCVTests",
            dependencies: ["SwiftOpenCV"]
        )
    ],
    cxxLanguageStandard: CXXLanguageStandard.cxx11
)
