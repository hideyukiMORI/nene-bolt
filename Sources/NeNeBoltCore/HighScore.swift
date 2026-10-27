/// ハイスコアの 1 件（FR-02e）。
public struct HighScore: Sendable, Hashable {
    /// 得点。
    public let score: Int
    /// 乗っていたパイロットの名前（表示用。Core はパイロットを知らない）。
    public let pilot: String
    /// 到達したステージ。
    public let stage: Int
    /// 難易度。
    public let difficulty: Difficulty

    /// 1 件を作る。
    public init(score: Int, pilot: String, stage: Int, difficulty: Difficulty) {
        precondition(score >= 0 && stage >= 1, "得点は 0 以上・ステージは 1 から")
        self.score = score
        self.pilot = pilot
        self.stage = stage
        self.difficulty = difficulty
    }
}
