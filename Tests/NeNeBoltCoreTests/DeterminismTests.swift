import Testing

@testable import NeNeBoltCore

/// 同じシード・同じ入力の列からは、同じ状態の列と出来事の列になる（FR-05・ARC-007）。
@Suite struct DeterminismTests {
    private func trace(seed: UInt64, runner: TestRunner) -> [GameStep] {
        var steps: [GameStep] = []
        _ = Playthrough.run(.fromStart(runner, .normal), seed: seed) { _, _, step in
            steps.append(step)
        }
        return steps
    }

    @Test(arguments: TestRunner.allCases)
    func theSameSeedReplaysTheSameGameTickByTick(_ runner: TestRunner) {
        for seed: UInt64 in [3, 30] {
            let first = trace(seed: seed, runner: runner)
            #expect(!first.isEmpty)
            #expect(first == trace(seed: seed, runner: runner))
        }
    }

    @Test func differentSeedsPlayDifferentGames() {
        #expect(trace(seed: 1, runner: .random) != trace(seed: 2, runner: .random))
    }

    @Test func aFinishedGameDoesNotChange() {
        var game = Game()
        game.status = .over(.outOfLives)
        var generator = SplitMix64(seed: 3)
        let step = game.step([.right, .jump, .fire], difficulty: .hard, using: &generator)
        #expect(step.game == game)
        #expect(step.events.isEmpty)
    }
}
