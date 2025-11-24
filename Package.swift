// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PomodoroTimer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "PomodoroTimer",
            targets: ["PomodoroTimer"]
        )
    ],
    targets: [
        .executableTarget(
            name: "PomodoroTimer",
            path: "PomodoroTimer/PomodoroTimer",
            exclude: [
                "Assets.xcassets",
                "Preview Content",
                "PomodoroTimer.entitlements",
                "Info.plist"
            ],
            sources: [
                "PomodoroApp.swift",
                "PomodoroManager.swift",
                "PomodoroServices.swift",
                "PomodoroSession.swift",
                "PomodoroMenuView.swift",
                "HeatmapView.swift"
            ]
        ),
        .testTarget(
            name: "PomodoroTimerTests",
            dependencies: ["PomodoroTimer"],
            path: "PomodoroTimer/PomodoroTimerTests"
        )
    ]
)
