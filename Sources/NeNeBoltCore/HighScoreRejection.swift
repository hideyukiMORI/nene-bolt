/// ハイスコアのファイルが読めなかった理由（ARC-009）。
public enum HighScoreRejection: Sendable, Hashable {
    /// 1 行目が版の行でないか、知らない版。
    case unknownVersion
    /// 行番号（1 から）の中身が読めない。
    case malformedLine(Int)
}
