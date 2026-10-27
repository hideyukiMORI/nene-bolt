/// 難易度と面から決まる敵の強さ（FR-14・ADR 0005）。ランナーの腕は変えない。
///
/// 同じ面では難易度が高いほど、どの値も敵に有利か同じになる（難易度の単調性）。面が進むほど少しずつ強くなる。
public struct Tuning: Sendable, Hashable {
    /// 歩く敵・飛ぶ敵の速さ（単位／刻み）。
    public let enemySpeed: Int
    /// 跳ねる敵が跳ぶ間隔（刻み）。少ないほど速い。
    public let hopInterval: Int
    /// 砲台が撃つ間隔（刻み）。
    public let turretInterval: Int
    /// 敵の弾の速さ。
    public let enemyShotSpeed: Int
    /// 敵に触れたときの強さ。
    public let contactDamage: Int
    /// ボスの体力。
    public let bossHealth: Int
    /// ボスの攻撃の間（刻み）。
    public let bossPause: Int

    /// 難易度と面から決める。
    public static func make(difficulty: Difficulty, stage: Stage) -> Tuning {
        Tuning(tier: difficulty.rawValue, level: stage.number - 1)
    }

    private init(tier: Int, level: Int) {
        enemySpeed = 1 + (tier + level) / 2
        hopInterval = max(20, 70 - tier * 15 - level * 5)
        turretInterval = max(30, 100 - tier * 20 - level * 8)
        enemyShotSpeed = 3 + tier + level / 2
        contactDamage = 2 + tier
        bossHealth = 16 + tier * 8
        bossPause = max(12, 45 - tier * 12)
    }
}
