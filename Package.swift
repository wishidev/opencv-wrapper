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
            url: "https://github.com/wishidev/opencv-wrapper/releases/download/v4.5.1/opencv2.xcframework.zip",
            checksum: "f2207e9172c0f340b23c73d6c83f048c315e0c4729d0c34a1197e7caac37495f"
        ),
        .testTarget(
            name: "SwiftOpenCVTests",
            dependencies: ["SwiftOpenCV"]
        )
    ],
    cxxLanguageStandard: CXXLanguageStandard.cxx11
)
