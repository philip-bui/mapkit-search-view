// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "MapKitSearchView",
    products: [
        .library(name: "MapKitSearchView", targets: ["MapKitSearchView"]),
    ],
    targets: [
        .target(name: "MapKitSearchView", path: "Sources")
    ]
)
