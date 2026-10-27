/// 弾を撃ったもの。
public enum ShotOwner: Sendable, Hashable {
    /// 自機。
    case runner
    /// 敵かボス。
    case enemy
}
