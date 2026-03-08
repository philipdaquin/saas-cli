// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "saas-cli",
    targets: [
        .executableTarget(
            name: "saas-cli",
            path: "Sources"
        )
    ]
)
