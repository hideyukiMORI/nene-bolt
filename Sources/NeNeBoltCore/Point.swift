/// 盤面の上の位置（単位）。y は下向き。
public struct Point: Sendable, Hashable {
    /// 横の位置。
    public let x: Int
    /// 縦の位置。
    public let y: Int

    /// 位置を作る。
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    /// 動かした位置。
    public func moved(by velocity: Velocity) -> Point {
        Point(x: x + velocity.dx, y: y + velocity.dy)
    }
}
