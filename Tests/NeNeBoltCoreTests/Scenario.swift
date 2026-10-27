@testable import NeNeBoltCore

/// 手で作る場面。小さな地図（1 頁）から、遊んでいる段階のゲームを作る。
enum Scenario {
    static func game(_ rows: [String]) -> Game {
        var game = Game()
        guard case .decoded(let map) = StageMap.decode([rows]), let start = map.first(.start) else {
            preconditionFailure("場面の地図が読めない")
        }
        game.map = map
        game.checkpoint = start
        game.pickups = map.spawns.compactMap(Game.pickup)
        game.restart()
        game.phase = .playing
        return game
    }

    /// 決まったボタンで `ticks` 刻み進め、起きたことを返す。
    @discardableResult
    static func run(_ game: inout Game, _ buttons: Buttons, ticks: Int, difficulty: Difficulty = .normal) -> [GameEvent]
    {
        var generator = SplitMix64(seed: 1)
        var events: [GameEvent] = []
        for _ in 0..<ticks {
            let step = game.step(buttons, difficulty: difficulty, using: &generator)
            events += step.events
            game = step.game
        }
        return events
    }

    /// ゲームを、その面の始まりで遊んでいる段階にする。
    static func at(_ stage: Stage) -> Game {
        var game = Game()
        var events: [GameEvent] = []
        game.load(stage, events: &events)
        game.phase = .playing
        return game
    }
}
