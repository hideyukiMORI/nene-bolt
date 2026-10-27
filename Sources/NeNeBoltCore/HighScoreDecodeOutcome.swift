/// ハイスコアのファイルを読んだ結果。
public enum HighScoreDecodeOutcome: Sendable, Hashable {
    case decoded(HighScoreTable)
    case rejected(HighScoreRejection)
}
