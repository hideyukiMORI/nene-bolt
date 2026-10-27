/// 地図の上の物 1 つ（種類とセル）。
public struct Spawn: Sendable, Hashable {
    /// 種類。
    public let kind: SpawnKind
    /// 列。
    public let column: Int
    /// 段。
    public let row: Int

    /// そのセルの左上（単位）。
    public var origin: Point {
        Point(x: Field.units(column), y: Field.units(row))
    }
}
