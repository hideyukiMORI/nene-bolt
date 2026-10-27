/// ハイスコアの表に 1 件入れた結果。
public struct HighScoreInsertion: Sendable, Hashable {
    /// 入れたあとの表。
    public let table: HighScoreTable
    /// 入れた記録の順位。
    public let rank: HighScoreRank
}
