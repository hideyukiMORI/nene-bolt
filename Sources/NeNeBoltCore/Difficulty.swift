/// 難易度（FR-14）。変えるのは敵の側（速さ・弾の数・急降下の頻度）だけで、パイロットの腕は変えない。
public enum Difficulty: Int, Sendable, Hashable, CaseIterable {
    case easy
    case normal
    case hard

    /// キー `d` で巡る次の難易度。
    public var next: Difficulty {
        switch self {
        case .easy: .normal
        case .normal: .hard
        case .hard: .easy
        }
    }
}
