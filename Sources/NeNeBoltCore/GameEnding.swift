/// ゲームの終わり方（FR-03・FR-02d）。
public enum GameEnding: Sendable, Hashable {
    /// ボスを倒した（ENDING へ）。
    case cleared
    /// 残機が尽きた。
    case outOfLives
    /// 刻みの数の上限に達した（安全のための上限。届いた割合は計測して ADR に書く）。
    case timeLimit
}
