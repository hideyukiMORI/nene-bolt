@testable import NeNeBoltCore

/// 1 ゲームを最後まで回した記録。
struct Playthrough {
    let final: Game
    let events: [GameEvent]

    /// 面から始めて、テストのランナーで終わりまで回す。刻みごとに `inspect`（前の状態・ボタン・結果）を呼ぶ。
    static func run(
        _ trial: Trial, seed: UInt64, inspect: (Game, Buttons, GameStep) -> Void = { _, _, _ in }
    ) -> Playthrough {
        let stage = Stage(number: trial.stage)
        var generator = SplitMix64(seed: seed)
        var runnerGenerator = SplitMix64(seed: seed ^ 0x77)
        var memory = 0
        var game = Game()
        if stage.number > 1 {
            var ignored: [GameEvent] = []
            game.load(stage, events: &ignored)
        }
        var events: [GameEvent] = []
        while case .running = game.status {
            let buttons = trial.runner.buttons(for: game, memory: &memory, using: &runnerGenerator)
            let step = game.step(buttons, difficulty: trial.difficulty, using: &generator)
            inspect(game, buttons, step)
            events += step.events
            game = step.game
        }
        return Playthrough(final: game, events: events)
    }
}
