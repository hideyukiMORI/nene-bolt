/// ランナーが話すきっかけ（FR-06・ADR 0009）。
public enum Cue: Sendable, Hashable, CaseIterable {
    /// TITLE で次の出番を待っている。
    case title
    /// 面が始まった。
    case stageStart
    /// 面を終えた。
    case stageClear
    /// 短い間に続けて倒した。
    case streak
    /// パワーアップか 1UP を手に入れた。
    case powerUp
    /// 被弾した。
    case hit
    /// 1 機失った。
    case lifeLost
    /// 最後の 1 機で戻ってきた。
    case lastLife
    /// 制限時間が残り少ない。
    case hurryUp
    /// ボスが現れた。
    case bossAppeared
    /// ボスを倒した。
    case bossDefeated
    /// ゲームが終わった。
    case gameOver
    /// ハイスコアの 1 位になった。
    case newRecord

    /// 言う確率（百分率）。100 は必ず言う。
    var chance: Int {
        switch self {
        case .title, .lifeLost, .lastLife, .hurryUp, .bossAppeared, .bossDefeated, .gameOver, .newRecord: 100
        case .stageClear, .powerUp: 80
        case .stageStart: 70
        case .hit: 60
        case .streak: 50
        }
    }

    /// 前の発言から間を置かずに言えるか（必ず言う出来事だけ）。
    var interrupts: Bool { chance == 100 }

    /// 同じ刻みに複数あるときの優先度（大きいほど先）。
    var priority: Int {
        switch self {
        case .newRecord: 13
        case .gameOver: 12
        case .bossDefeated: 11
        case .lifeLost: 10
        case .lastLife: 9
        case .bossAppeared: 8
        case .hurryUp: 7
        case .hit: 6
        case .powerUp: 5
        case .stageClear: 4
        case .stageStart: 3
        case .streak: 2
        case .title: 1
        }
    }
}
