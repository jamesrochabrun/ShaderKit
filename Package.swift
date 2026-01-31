// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ShaderKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "ShaderKit",
            targets: ["ShaderKit"]
        ),
        .library(
            name: "ShaderKitUI",
            targets: ["ShaderKitUI"]
        ),
    ],
    targets: [
        .target(
            name: "ShaderKit",
            resources: [
                .process("Shaders")
            ]
        ),
        .target(
            name: "ShaderKitUI",
            dependencies: ["ShaderKit"]
        ),
        .testTarget(
            name: "ShaderKitTests",
            dependencies: ["ShaderKit"]
        ),
    ]
)
