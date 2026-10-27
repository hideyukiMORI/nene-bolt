/// 弾 1 発。
public struct Shot: Sendable, Hashable {
    /// 撃ったもの。
    public let owner: ShotOwner
    /// 左上の位置。
    public internal(set) var position: Point
    /// 1 刻みに進む量。
    public let velocity: Velocity
    /// 幅。
    public let width: Int
    /// 高さ。
    public let height: Int
    /// 当たったときの強さ。
    public let damage: Int
    /// 溜め撃ちか（敵を倒しても止まらずに進む）。
    public let charged: Bool
    /// 残りの刻み（尽きたら消える）。
    public internal(set) var life: Int

    /// 当たり判定の箱。
    public var box: Box {
        Box(origin: position, width: width, height: height)
    }
}
