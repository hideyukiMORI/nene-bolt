/// 場面（FR-03）。TITLE → PLAY → GAME OVER か ENDING → TITLE の順にだけ巡る。
public enum Scene: Sendable, Hashable {
    /// 題・次のランナー・難易度・キーのヘルプ（残りの刻み）。
    case title(ticksLeft: Int)
    /// 遊んでいる。
    case play(Game)
    /// 残機が尽きたゲームのまとめを見せている（残りの刻み）。
    case gameOver(GameSummary, ticksLeft: Int)
    /// ボスを倒したゲームのまとめを見せている（残りの刻み）。
    case ending(GameSummary, ticksLeft: Int)
}
