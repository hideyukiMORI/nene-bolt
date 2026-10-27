import NeNeBoltCore

/// 画面の演出の状態（FR-02h・ADR 0010）。出来事から作る見た目だけの値で、ゲームの状態（Core）には入れない（ADR 0004）。
///
/// 合成ルートが刻みごとに出来事を渡して進め、Render が描く。持ち主は合成ルート（ARC-005）。
/// 移植元: NeNe Swarm `Sources/NeNeSwarmRender/Effects.swift`（コミット a660f47）。出来事を横スクロールのものに替えた。
public struct Effects: Sendable, Hashable {
    /// 得点が浮かんでいる刻みの数。
    static let popupTicks = 30
    /// ボスの前の WARNING の帯を出す刻みの数。
    static let warningTicks = 75

    /// 演出の時計（刻みごとに 1 進む。点滅もこれで動く）。
    public private(set) var clock = 0
    private(set) var popups: [Popup] = []
    private(set) var warningUntil = 0

    /// 何も起きていない状態。
    public init() {}

    /// 1 刻みの出来事を取り込む。
    public mutating func absorb(_ events: [SessionEvent]) {
        clock += 1
        popups.removeAll { clock - $0.born >= Effects.popupTicks }
        for case .game(let event) in events {
            absorb(event)
        }
    }

    private mutating func absorb(_ event: GameEvent) {
        switch event {
        case .enemyDefeated(_, let points, let at, _):
            popups.append(Popup(text: String(points), point: at, born: clock))
        case .bossAppeared:
            warningUntil = clock + Effects.warningTicks
        case .stageStarted, .bossDefeated, .stageCleared, .timeBonus, .enemyHit, .chargedShot, .runnerHit, .lifeLost,
            .respawned,
            .pickedUp, .coinsOneUp, .checkpointReached, .hurryUp, .bossHit, .bossFlash, .gameOver:
            break
        }
    }

    /// ボスの前の WARNING の帯を出しているか。
    var showsWarning: Bool { clock < warningUntil }
}
