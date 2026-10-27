/// ハイスコアがファイルに残るか（FR-02g）。合成ルートが決めて、Render は TITLE に出すだけ。
public enum ScoreStorage: Sendable, Hashable {
    /// ファイルに残る。
    case file
    /// 起動中だけ（ファイルが読めない・書けない）。
    case memoryOnly
}
