/// 左右に動く足場（3 面）。上からだけ乗れ、乗っている自機を運ぶ。
public struct Platform: Sendable, Hashable {
    /// 幅（3 セル）。
    public static let width = 3 * Field.cellUnits
    /// 厚さ。
    public static let height = Field.cellUnits / 2
    /// 動く幅（片側のセル）。
    public static let reach = 4

    /// 左上の位置。
    public internal(set) var position: Point
    /// 1 刻みの横の量。
    public internal(set) var step: Int
    /// 左端の最小。
    public let minX: Int
    /// 左端の最大。
    public let maxX: Int

    /// 当たり判定の箱。
    public var box: Box {
        Box(origin: position, width: Platform.width, height: Platform.height)
    }
}
