/// 拾うもの 1 つ。
public struct Pickup: Sendable, Hashable {
    /// 大きさ（単位）。
    public static let size = 12

    /// 種類。
    public let kind: PickupKind
    /// 左上の位置。
    public let position: Point
    /// もう拾われたか。
    public internal(set) var taken: Bool

    /// 当たり判定の箱。
    public var box: Box {
        Box(origin: position, width: Pickup.size, height: Pickup.size)
    }
}
