/// 地図の上に置く物の種類（ADR 0005）。面を読むときに地形から外し、物として置く。
public enum SpawnKind: Sendable, Hashable, CaseIterable {
    /// 自機の始まりの位置（`S`）。
    case start
    /// 中間地点（`K`）。
    case checkpoint
    /// ゴールの旗（`G`）。
    case goal
    /// ボス（`B`）。
    case boss
    /// ボスの部屋の扉（`D`）。ボス戦が始まると閉じる。
    case door
    /// コイン（`c`）。
    case coin
    /// 体力の回復（`h`）。
    case health
    /// 1UP（`u`）。
    case oneUp
    /// パワーアップ（`p`）。
    case powerUp
    /// 歩く敵（`w`）。
    case walker
    /// 跳ねる敵（`j`）。
    case hopper
    /// 飛ぶ敵（`f`）。
    case flyer
    /// 撃ってくる砲台（`t`）。
    case turret
    /// 撃たれると小さく分かれる結晶の敵（`s`）。
    case splitter
    /// 左右に動く足場（`M`）。
    case mover

    /// 地図の文字から。物でなければ nil。
    static func of(_ character: Character) -> SpawnKind? {
        table[character]
    }

    private static let table: [Character: SpawnKind] = [
        "S": .start, "K": .checkpoint, "G": .goal, "B": .boss, "D": .door, "c": .coin, "h": .health, "u": .oneUp,
        "p": .powerUp, "w": .walker, "j": .hopper, "f": .flyer, "t": .turret, "s": .splitter, "M": .mover,
    ]
}
