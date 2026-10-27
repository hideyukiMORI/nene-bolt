/// 終わったゲームのまとめ（GAME OVER の画面とハイスコアの入力）。
public struct GameSummary: Sendable, Hashable {
    /// 最終スコア。
    public let score: Int
    /// 到達したステージ。
    public let stage: Stage
    /// 終わり方。
    public let ending: GameEnding
    /// 終わったときの難易度。
    public let difficulty: Difficulty
    /// かかった刻みの数。
    public let ticks: Int
}
