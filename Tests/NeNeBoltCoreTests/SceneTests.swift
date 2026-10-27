import Testing

@testable import NeNeBoltCore

/// 場面は TITLE → PLAY → GAME OVER か ENDING → TITLE の順にだけ巡り、決めた長さだけ見せる（FR-03・FR-11）。
@Suite struct SceneTests {
    private enum Kind: Equatable {
        case title
        case play
        case gameOver
        case ending
    }

    private static func kind(of scene: Scene) -> Kind {
        switch scene {
        case .title: .title
        case .play: .play
        case .gameOver: .gameOver
        case .ending: .ending
        }
    }

    @Test func scenesCycleInOrderAndLastAsLongAsConfigured() {
        var session = Session(durations: SceneDurations(titleTicks: 3, gameOverTicks: 2))
        var generator = SplitMix64(seed: 11)
        var runnerGenerator = SplitMix64(seed: 12)
        var memory = 0
        var runs: [(Kind, Int)] = []
        var started: [Int] = []
        while session.gamesStarted < 4 {
            var buttons: Buttons = []
            if case .play(let game) = session.scene {
                buttons = TestRunner.forward.buttons(for: game, memory: &memory, using: &runnerGenerator)
            }
            let step = session.step(buttons, difficulty: .hard, using: &generator)
            for case .gameStarted(let number) in step.events {
                started.append(number)
            }
            let kind = SceneTests.kind(of: session.scene)
            if let last = runs.last, last.0 == kind {
                runs[runs.count - 1].1 += 1
            } else {
                runs.append((kind, 1))
            }
            session = step.session
        }
        let order = runs.map(\.0)
        #expect(order == [.title, .play, .gameOver, .title, .play, .gameOver, .title, .play, .gameOver, .title])
        #expect(runs.filter { $0.0 == .title }.allSatisfy { $0.1 == 3 })
        #expect(runs.filter { $0.0 == .gameOver }.allSatisfy { $0.1 == 2 })
        #expect(started == [1, 2, 3, 4])
    }

    @Test func theGameOverSceneCarriesTheFinalScore() {
        var session = Session(durations: SceneDurations(titleTicks: 1, gameOverTicks: 5))
        var generator = SplitMix64(seed: 2)
        var ended: [GameSummary] = []
        while ended.isEmpty {
            let step = session.step([], difficulty: .hard, using: &generator)
            for case .gameEnded(let summary) in step.events {
                ended.append(summary)
            }
            session = step.session
        }
        guard case .gameOver(let summary, let ticksLeft) = session.scene else {
            Issue.record("GAME OVER になっていない")
            return
        }
        #expect(summary == ended[0])
        #expect(ticksLeft == 5)
        #expect(summary.difficulty == .hard)
        #expect(summary.ending == .outOfLives)
    }

    @Test func beatingTheBossShowsTheEndingAndThenTheTitle() {
        var game = Scenario.at(Stage(number: 4))
        game.status = .running
        guard let door = game.map.first(.door) else {
            Issue.record("扉が無い")
            return
        }
        game.runner.position = Point(x: door.origin.x + 2 * Field.cellUnits, y: Field.units(15) - Runner.height)
        game.runner.invulnerable = 100_000
        var session = Session(
            scene: .play(game), gamesStarted: 1, durations: SceneDurations(titleTicks: 4, gameOverTicks: 3))
        var generator = SplitMix64(seed: 5)
        var kinds: [Kind] = []
        for tick in 0..<20_000 where kinds.last != .title {
            var buttons: Buttons = []
            if case .play(var playing) = session.scene, case .fighting(var boss) = playing.boss {
                boss.health = min(boss.health, 1)
                playing.boss = .fighting(boss)
                session = Session(scene: .play(playing), gamesStarted: 1, durations: session.durations)
                let aim: Buttons = playing.runner.box.centerX < boss.box.centerX ? .right : .left
                buttons = tick % 2 == 0 ? aim.union(.fire) : aim
            }
            let step = session.step(buttons, difficulty: .normal, using: &generator)
            session = step.session
            if kinds.last != SceneTests.kind(of: session.scene) {
                kinds.append(SceneTests.kind(of: session.scene))
            }
        }
        #expect(kinds == [.play, .ending, .title])
    }
}
