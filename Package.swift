import PackageDescription

let package = Package(
    name: "ServerSideSwift",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 3),
        .Package(url: "https://github.com/vapor/fluent.git", majorVersion: 1, minor: 3),
        .Package(url: "https://github.com/vapor/redis-provider.git", majorVersion: 1)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
        "Tests",
    ]
)
