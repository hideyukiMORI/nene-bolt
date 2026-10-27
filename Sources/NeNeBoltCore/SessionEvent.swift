/// 場面を 1 刻み進めて起きたこと。
public enum SessionEvent: Sendable, Hashable {
    /// TITLE に戻った。
    case titleShown
    /// 何ゲーム目かが始まった（1 から）。
    case gameStarted(number: Int)
    /// 遊んでいるゲームで起きたこと。
    case game(GameEvent)
    /// ゲームが終わった。
    case gameEnded(GameSummary)
}
