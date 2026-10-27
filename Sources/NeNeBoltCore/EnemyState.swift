/// 敵の状態。
public enum EnemyState: Sendable, Hashable {
    /// まだ自機が遠い（動かない・当たり判定はある）。
    case dormant
    /// 動いている。
    case active
    /// 倒れて爆発している（残りの刻み）。当たり判定は無い。
    case dying(ticksLeft: Int)
}
