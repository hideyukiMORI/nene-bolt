/// 敵の種類（FR-02f・ADR 0005）。踏めるか・体力・得点・大きさの表の持ち主。
public enum EnemyKind: Sendable, Hashable, CaseIterable {
    /// 床を歩き、壁と崖で向きを変える。
    case walker
    /// ときどき自機の方へ跳ねる。
    case hopper
    /// 自機の方へ波打ちながら飛ぶ。
    case flyer
    /// 動かずに自機の方へ撃つ。上が尖っていて踏めない。
    case turret
    /// 結晶の洞窟の敵。倒すと小さな欠片 2 つに分かれる。
    case splitter
    /// 分かれた小さな欠片。
    case shard

    /// 倒れるまでに要る弾の強さの合計。
    public var toughness: Int {
        switch self {
        case .walker, .flyer, .shard: 1
        case .hopper, .splitter: 2
        case .turret: 3
        }
    }

    /// 上から踏んで倒せるか。
    public var isStompable: Bool {
        switch self {
        case .walker, .hopper, .flyer, .splitter, .shard: true
        case .turret: false
        }
    }

    /// 倒したときの得点。
    public var points: Int {
        switch self {
        case .walker: 100
        case .hopper: 200
        case .flyer: 150
        case .turret: 300
        case .splitter: 200
        case .shard: 50
        }
    }

    /// 当たり判定の大きさ（幅と高さ・単位）。
    public var size: (width: Int, height: Int) {
        switch self {
        case .walker, .hopper, .splitter: (14, 14)
        case .flyer: (14, 10)
        case .turret: (16, 16)
        case .shard: (8, 8)
        }
    }
}
