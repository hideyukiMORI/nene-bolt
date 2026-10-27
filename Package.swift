// swift-tools-version: 6.2
// tools-version は manifest の API の版であり、ツールチェーンの版（.swift-version）ではない。
// 6.2 は treatAllWarnings(as:) を使える最小の版（ADR 0001）。
// target は承認された依存グラフ（docs/architecture/module-graph.txt・ADR 0004）から、最初の責務が生じた PR で足した（Core は Issue #3・残りは Issue #5）。
// 各 target の swiftSettings は [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]（CNF-009）。

import PackageDescription

let package = Package(
    name: "NeNeBolt",
    targets: [
        .target(
            name: "NeNeBoltCore",
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .target(
            name: "NeNeBoltEngine",
            dependencies: ["NeNeBoltCore"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .target(
            name: "NeNeBoltRender",
            dependencies: ["NeNeBoltCore", "NeNeBoltEngine"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .target(
            name: "NeNeBoltTerminal",
            dependencies: ["NeNeBoltRender"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .executableTarget(
            name: "nene-bolt",
            dependencies: ["NeNeBoltCore", "NeNeBoltEngine", "NeNeBoltRender", "NeNeBoltTerminal"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "NeNeBoltCoreTests",
            dependencies: ["NeNeBoltCore"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "NeNeBoltEngineTests",
            dependencies: ["NeNeBoltCore", "NeNeBoltEngine"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "NeNeBoltRenderTests",
            dependencies: ["NeNeBoltCore", "NeNeBoltEngine", "NeNeBoltRender"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
        .testTarget(
            name: "NeNeBoltTerminalTests",
            dependencies: ["NeNeBoltRender", "NeNeBoltTerminal"],
            swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]
        ),
    ],
    swiftLanguageModes: [.v6]
)
