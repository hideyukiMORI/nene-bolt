/// 自機（FR-02・FR-02d・ADR 0005）。外からは読むだけで、状態を変えるのは Core の 1 刻み関数だけ（ARC-004）。
public struct Runner: Sendable, Hashable {
    /// 当たり判定の幅（1 セルより少し細い）。
    public static let width = 12
    /// 当たり判定の高さ（2 セルより少し低い）。
    public static let height = 28
    /// 走る最高速度（単位／刻み）。
    public static let runSpeed = 3
    /// 跳んだ瞬間の上向きの速さ。
    public static let jumpSpeed = 11
    /// 跳ぶボタンを離したときに、上向きの速さをここまで落とす（押している長さで高さが変わる）。
    public static let jumpCut = 3
    /// 1 刻みの重力。
    public static let gravity = 1
    /// 落ちる最高速度（1 セルより小さい・床を突き抜けない）。
    public static let maxFall = 12
    /// 梯子を上り下りする速さ。
    public static let climbSpeed = 3
    /// 敵を踏んだあとの跳ね返り。
    public static let stompBounce = 7
    /// 体力の最大。
    public static let maxHealth = 10
    /// 被弾したあとの無敵の刻み。
    public static let invulnerableTicks = 45
    /// 溜め撃ちになるまで撃つボタンを押し続ける刻み。
    public static let chargeTicks = 30
    /// パワーアップの最大の段。
    public static let maxPower = 2

    /// 左上の位置。
    public internal(set) var position: Point
    /// 速さ。
    public internal(set) var velocity: Velocity
    /// 向き。
    public internal(set) var facing: Heading
    /// 足の状態。
    public internal(set) var posture: Posture
    /// 体力。
    public internal(set) var health: Int
    /// 無敵の残りの刻み。
    public internal(set) var invulnerable: Int
    /// 撃つボタンを押し続けている刻み。
    public internal(set) var charge: Int
    /// パワーアップの段（0〜2）。
    public internal(set) var power: Int
    /// 前の刻みに押されていたボタン（押した瞬間・離した瞬間を見るため）。
    public internal(set) var held: Buttons

    init(at position: Point) {
        self.position = position
        velocity = .zero
        facing = .right
        posture = .airborne
        health = Runner.maxHealth
        invulnerable = 0
        charge = 0
        power = 0
        held = .none
    }

    /// 地図の始まりや中間地点のセルに立たせる（足がセルの下端に来る）。
    static func standing(on spawn: Spawn) -> Runner {
        Runner(at: Point(x: spawn.origin.x + 2, y: spawn.origin.y + Field.cellUnits - height))
    }

    /// 当たり判定の箱。
    public var box: Box {
        Box(origin: position, width: Runner.width, height: Runner.height)
    }

    /// 溜め撃ちが溜まっているか。
    public var isCharged: Bool { charge >= Runner.chargeTicks }
}
