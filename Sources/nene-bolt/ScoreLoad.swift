import NeNeBoltCore

/// ハイスコアのファイルを読んだ結果。
enum ScoreLoad {
    /// 読めた（ファイルが無かったときは空の表）。以後は保存する。
    case loaded(HighScoreTable)
    /// 読めない・置き場が決まらない。起動中だけの記録で続ける（FR-02g）。
    case memoryOnly
}
