// swift-tools-version:4.1
import PackageDescription

let package = Package(
    name: "Cacao",
    products: [
        .library(name: "Cacao", targets: ["Cacao"]),
        .executable(name: "CacaoDemo", targets: ["CacaoDemo"]),
        ],
    dependencies: [
        .package(
            url: "https://github.com/SilinVasya/Silica.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/SilinVasya/Cairo.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/SilinVasya/SDL.git",
            .branch("master")
        )
    ],
    targets: [
        .target(
            name: "Cacao",
            dependencies: [
                "Silica",
                "Cairo",
                "SDL"
            ]
        ),
        .target(
            name: "CacaoDemo",
            dependencies: [
                "Cacao"
            ]
        ),
        ]
)
