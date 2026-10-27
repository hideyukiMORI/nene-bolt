/// 自機の足の状態。
public enum Posture: Sendable, Hashable {
    /// 床（か動く足場）に立っている。
    case standing
    /// 空中（跳んでいる・落ちている）。
    case airborne
    /// 梯子につかまっている。
    case climbing
}
