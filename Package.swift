import PackageDescription

let package = Package(
    name: "thegreatscrape",
    dependencies: [
        .Package(url: "https://github.com/tid-kijyun/Kanna.git", majorVersion: 2)
    ]
)
