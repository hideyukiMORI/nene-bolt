/// 面の中の段階。
public enum PlayPhase: Sendable, Hashable {
    /// 面の始まりの帯を見せている（残りの刻み）。何も動かない。
    case intro(ticksLeft: Int)
    /// 遊んでいる。
    case playing
    /// 1 機失った（残りの刻み）。終わると中間地点からやり直すか、ゲームが終わる。
    case dying(ticksLeft: Int)
    /// ゴールに着いた（残りの刻み）。終わると次の面。
    case cleared(ticksLeft: Int)
    /// ボスを倒した（残りの刻み）。終わるとゲームが ENDING で終わる。
    case victory(ticksLeft: Int)
}
