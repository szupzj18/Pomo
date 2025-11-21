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
            path: ".",
            sources: [
                "PomodoroApp.swift",
                "PomodoroManager.swift",
                "PomodoroSession.swift",
                "PomodoroMenuView.swift",
                "HeatmapView.swift"
            ]
        )
    ]
)
