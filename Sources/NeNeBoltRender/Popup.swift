import NeNeBoltCore

/// 倒した場所に浮かぶ得点（FR-02h）。移植元: NeNe Swarm `Sources/NeNeSwarmRender/Popup.swift`（コミット a660f47）。
struct Popup: Sendable, Hashable {
    let text: String
    let point: Point
    /// 出た刻み（`Effects` の時計）。
    let born: Int
}
