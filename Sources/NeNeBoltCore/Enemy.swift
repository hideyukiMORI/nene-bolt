/// 敵 1 体。外からは読むだけ。
public struct Enemy: Sendable, Hashable {
    /// 面の中で一意の番号。
    public let id: Int
    /// 種類。
    public let kind: EnemyKind
    /// 左上の位置。
    public internal(set) var position: Point
    /// 速さ。
    public internal(set) var velocity: Velocity
    /// 向き。
    public internal(set) var facing: Heading
    /// 体力。
    public internal(set) var health: Int
    /// 動きの時計（刻み）。
    public internal(set) var timer: Int
    /// 状態。
    public internal(set) var state: EnemyState

    init(id: Int, kind: EnemyKind, position: Point) {
        self.id = id
        self.kind = kind
        self.position = position
        velocity = .zero
        facing = .left
        health = kind.toughness
        timer = 0
        state = .dormant
    }

    /// 当たり判定の箱。
    public var box: Box {
        Box(origin: position, width: kind.size.width, height: kind.size.height)
    }

    /// 当たり判定があるか（爆発中は無い）。
    public var isSolid: Bool {
        switch state {
        case .dormant, .active: true
        case .dying: false
        }
    }
}
