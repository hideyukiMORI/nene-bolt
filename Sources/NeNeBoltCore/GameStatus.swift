/// ゲームが続いているか。
public enum GameStatus: Sendable, Hashable {
    case running
    case over(GameEnding)
}
