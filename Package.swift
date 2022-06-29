// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Bento",
    defaultLocalization: "en_US",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "Bento", targets: ["Bento"])
    ],
    dependencies: [
        .package(url: "https://github.com/RACCommunity/FlexibleDiff.git", from: "0.0.8")
    ],
    targets: [
        .target(
            name: "Bento",
            dependencies: [
                "FlexibleDiff",
                "Common",
            ],
            path: "Bento"
        ),
        .target(
            name: "Common",
            path: "Common"
        )
    ]
)
