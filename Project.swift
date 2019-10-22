import ProjectDescription

let project = Project(
    name: "Trollbox",
    targets: [
        Target(
            name: "Trollbox",
            platform: .iOS,
            product: .app,
            bundleId: "io.ultralightbeam.trollbox",
            infoPlist: "Info.plist",
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .cocoapods(path: "."),
            ]
        ),
        Target(
            name: "TrollboxTests",
            platform: .iOS,
            product: .unitTests,
            bundleId: "io.ultralightbeam.trollboxTests",
            infoPlist: "Tests.plist",
            sources: "Tests/**",
            dependencies: [
                .target(name: "Trollbox"),
            ]
        ),
        Target(
            name: "TrollboxUITests",
            platform: .iOS,
            product: .uiTests,
            bundleId: "io.ultralightbeam.trollboxUITests",
            infoPlist: "UITests.plist",
            sources: "UITests/**",
            dependencies: [
                .target(name: "Trollbox"),
            ]
        ),
    ]
)
