// swift-tools-version: 5.9
import PackageDescription
let package = Package(name: "saas-cli", version: "1.0.0", description: "Build SaaS apps in seconds", license: .mit, authors: [.init(name: "Philip Daquin", email: "philip@daquin.com")], targets: [.executableTarget(name: "saas-cli", dependencies: [], path: "Sources")])
