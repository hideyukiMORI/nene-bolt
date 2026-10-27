/// 4 面の終わりの部屋のボス（FR-02c）。外からは読むだけ。
public struct Boss: Sendable, Hashable {
    /// 当たり判定の幅。
    public static let width = 28
    /// 当たり判定の高さ。
    public static let height = 40
    /// 体当たりの強さ。
    public static let contactDamage = 4
    /// 被弾したあとの無敵の刻み。
    public static let invulnerableTicks = 10

    /// 左上の位置。
    public internal(set) var position: Point
    /// 速さ。
    public internal(set) var velocity: Velocity
    /// 体力。
    public internal(set) var health: Int
    /// 体力の最大。
    public let maxHealth: Int
    /// いまの攻撃。
    public internal(set) var attack: BossAttack
    /// 向き。
    public internal(set) var facing: Heading
    /// 無敵の残りの刻み。
    public internal(set) var invulnerable: Int

    init(at position: Point, health: Int) {
        self.position = position
        velocity = .zero
        self.health = health
        maxHealth = health
        attack = .idle(ticksLeft: 60)
        facing = .left
        invulnerable = 0
    }

    /// 当たり判定の箱。
    public var box: Box {
        Box(origin: position, width: Boss.width, height: Boss.height)
    }
}
