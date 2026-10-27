/// ハイスコアの表に入れた結果の順位。
public enum HighScoreRank: Sendable, Hashable {
    /// 何位に入ったか（1 から）。
    case ranked(Int)
    /// 表に入らなかった。
    case unranked
}
