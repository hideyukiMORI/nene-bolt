/// TITLE と GAME OVER を見せる刻みの数（FR-11）。秒への換算は合成ルートだけがする。
public struct SceneDurations: Sendable, Hashable {
    /// TITLE を見せる刻みの数。
    public let titleTicks: Int
    /// GAME OVER を見せる刻みの数。
    public let gameOverTicks: Int

    /// 長さを作る。どちらも 1 以上。
    public init(titleTicks: Int, gameOverTicks: Int) {
        precondition(titleTicks >= 1 && gameOverTicks >= 1, "場面を見せる刻みは 1 以上")
        self.titleTicks = titleTicks
        self.gameOverTicks = gameOverTicks
    }
}
