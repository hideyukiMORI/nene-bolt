/// 当たり判定の箱（単位）。左上の位置と幅・高さ。幅と高さは正。
public struct Box: Sendable, Hashable {
    /// 左上。
    public let origin: Point
    /// 幅。
    public let width: Int
    /// 高さ。
    public let height: Int

    /// 箱を作る。
    public init(origin: Point, width: Int, height: Int) {
        precondition(width > 0 && height > 0, "箱の幅と高さは正")
        self.origin = origin
        self.width = width
        self.height = height
    }

    /// 右端（含まない）。
    public var right: Int { origin.x + width }
    /// 下端（含まない）。
    public var bottom: Int { origin.y + height }
    /// 横の中心。
    public var centerX: Int { origin.x + width / 2 }

    /// 2 つの箱が重なるか（辺が接するだけなら重ならない）。当たり判定の唯一の経路（ARC-001）。
    public func overlaps(_ other: Box) -> Bool {
        origin.x < other.right && other.origin.x < right && origin.y < other.bottom && other.origin.y < bottom
    }

    /// 縦の中心。
    public var centerY: Int { origin.y + height / 2 }

    /// 動かした箱。
    public func moved(by velocity: Velocity) -> Box {
        Box(origin: origin.moved(by: velocity), width: width, height: height)
    }
}
