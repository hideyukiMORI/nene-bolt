/// 先読みのための乱数源（ADR 0008）。いつも最大の値を返すので、先読みの中の乱数はどれも同じ側に倒れる。
/// 移植元: NeNe Swarm `Sources/NeNeSwarmEngine/Calm.swift`（コミット a660f47）。
struct Calm: RandomNumberGenerator {
    mutating func next() -> UInt64 {
        .max
    }
}
