/// 1 機失った理由（FR-02d）。
public enum LossCause: Sendable, Hashable {
    /// 体力が尽きた。
    case health
    /// 穴に落ちた。
    case pit
    /// 棘に触れた。
    case spike
    /// 面の制限時間が尽きた。
    case timeUp
}
