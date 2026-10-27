import Testing

@testable import NeNeBoltCore

/// 多数のゲームを最後まで回し、刻みごとに不変条件を見る（REQUIREMENTS 第 3 節）。重いので release 構成で回す（ADR 0006）。
@Suite struct InvariantTests {
    /// 面ごと・難易度ごと・テストのランナーごとに回すシードの数。黙って下げない（ADR 0006）。
    static let seedsPerCell = 25

    static let trials: [Trial] = (1...StageCatalog.count).flatMap { stage in
        Difficulty.allCases.flatMap { difficulty in
            TestRunner.allCases.map { Trial(stage: stage, difficulty: difficulty, runner: $0) }
        }
    }

    @Test(arguments: trials)
    func everyGameEndsAndKeepsEveryInvariant(_ trial: Trial) {
        for seed in 0..<UInt64(InvariantTests.seedsPerCell) {
            var failures: [String] = []
            let run = Playthrough.run(trial, seed: seed) {
                before, _, step in
                failures += InvariantTests.violations(before: before, step: step)
            }
            if case .over(.timeLimit) = run.final.status {
                failures.append("刻みの上限に達した")
            }
            if !failures.isEmpty {
                Issue.record("\(trial) seed \(seed): \(failures.prefix(3))")
                return
            }
        }
    }

    static func violations(before: Game, step: GameStep) -> [String] {
        var found = bounds(step.game)
        let gained = step.events.reduce(0) { $0 + points(of: $1) }
        if step.game.score != before.score + gained {
            found.append("スコアの増え方 \(before.score) → \(step.game.score)（出来事 \(gained)）")
        }
        let change = step.events.reduce(0) { $0 + lifeChange(of: $1) }
        if step.game.lives != before.lives + change {
            found.append("残機 \(before.lives) → \(step.game.lives)（出来事 \(change)）")
        }
        return found
    }

    /// 地形に埋まらない・面の外へ出ない・数が範囲の中。
    static func bounds(_ game: Game) -> [String] {
        var found: [String] = []
        if PhysicsTests.isBuried(game) {
            found.append("地形に埋まった \(game.runner.position)")
        }
        let runner = game.runner
        if runner.position.x < 0 || runner.box.right > game.map.width {
            found.append("面の外 \(runner.position)")
        }
        if !(0..<Game.coinsPerLife).contains(game.coins) || !(0...Runner.maxHealth).contains(runner.health)
            || !(0...Runner.maxPower).contains(runner.power)
        {
            found.append("数が範囲の外")
        }
        if game.shots.filter({ $0.owner == .runner }).count > Game.maxRunnerShots + 1 {
            found.append("自機の弾が多すぎる")
        }
        return found
    }

    static func points(of event: GameEvent) -> Int {
        switch event {
        case .enemyDefeated(_, let points, _, _), .bossDefeated(let points), .timeBonus(let points): points
        case .pickedUp(let kind): kind.points
        case .stageStarted, .stageCleared, .enemyHit, .chargedShot, .runnerHit, .lifeLost, .respawned, .coinsOneUp,
            .checkpointReached, .hurryUp, .bossAppeared, .bossHit, .bossFlash, .gameOver:
            0
        }
    }

    /// 残機（いま走っている 1 機を含む）を動かす出来事。
    static func lifeChange(of event: GameEvent) -> Int {
        switch event {
        case .lifeLost: -1
        case .pickedUp(.oneUp), .coinsOneUp: 1
        case .stageStarted, .stageCleared, .timeBonus, .enemyDefeated, .enemyHit, .chargedShot, .runnerHit, .respawned,
            .pickedUp, .checkpointReached, .hurryUp, .bossAppeared, .bossHit, .bossFlash, .bossDefeated, .gameOver:
            0
        }
    }
}
