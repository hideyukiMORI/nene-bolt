import NeNeBoltCore

@testable import NeNeBoltEngine

/// 1 ゲームを本物のランナーで最後まで回した記録（長さの計測と単調性のテスト・ADR 0008）。
struct Measure {
    let ticks: Int
    let stage: Int
    let score: Int
    let ending: GameEnding?
    let losses: [LossCause]

    static func play(_ persona: Persona, difficulty: Difficulty, seed: UInt64) -> Measure {
        var generator = SplitMix64(seed: seed)
        var pilotGenerator = SplitMix64(seed: seed ^ 0x51)
        var pilot = Pilot(persona: persona)
        var game = Game()
        var losses: [LossCause] = []
        while case .running = game.status {
            let buttons = pilot.buttons(for: game, difficulty: difficulty, using: &pilotGenerator)
            let step = game.step(buttons, difficulty: difficulty, using: &generator)
            for case .lifeLost(let cause) in step.events {
                losses.append(cause)
            }
            game = step.game
        }
        var ending: GameEnding?
        if case .over(let end) = game.status {
            ending = end
        }
        return Measure(ticks: game.tick, stage: game.stage.number, score: game.score, ending: ending, losses: losses)
    }
}
