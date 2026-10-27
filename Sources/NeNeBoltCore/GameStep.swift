/// 1 刻み進めた結果（次のゲームとその刻みで起きたこと）。
public struct GameStep: Sendable, Hashable {
    /// 次のゲーム。
    public let game: Game
    /// 起きたこと（起きた順）。
    public let events: [GameEvent]
}
