/// ボスの攻撃の型（FR-02c・ADR 0005）。
public enum BossAttack: Sendable, Hashable {
    /// 次の攻撃までの間（残りの刻み）。
    case idle(ticksLeft: Int)
    /// 自機の方へ高く跳ぶ。
    case leap
    /// 自機の方へ 3 発を扇に撃つ。
    case barrage
    /// 壁まで突進する。
    case dash
    /// 画面全体が光り（残りの刻み）、光り終わると 5 発を扇に撃つ。
    case flash(ticksLeft: Int)
}
