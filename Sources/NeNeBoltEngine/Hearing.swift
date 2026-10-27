import NeNeBoltCore

/// 1 刻みにランナーが聞いたこと（場面の出来事と、合成ルートだけが知る新記録）。
public struct Hearing: Sendable, Hashable {
    /// その刻みの出来事。
    public let events: [SessionEvent]
    /// 刻みのあとの残機（いま走っている 1 機を含む・遊んでいなければ nil）。
    public let lives: Int?
    /// そのゲームでハイスコアの 1 位になったか。
    public let newRecord: Bool

    /// 組を作る。
    public init(events: [SessionEvent], lives: Int?, newRecord: Bool) {
        self.events = events
        self.lives = lives
        self.newRecord = newRecord
    }
}
