// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "靶场工坊",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "靶场工坊",
            path: "."
        )
    ]
)
