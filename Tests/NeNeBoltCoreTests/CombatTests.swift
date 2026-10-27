import Testing

@testable import NeNeBoltCore

/// 撃つ・踏む・被弾・ボス（FR-02・FR-02c・FR-02d・FR-02f）。
@Suite struct CombatTests {
    private let lane = ["                ", " S      w       ", "################"]

    @Test func aShotDefeatsAWalkerAndScores() {
        var game = Scenario.game(lane)
        game.enemies[0].state = .active
        let events = Scenario.run(&game, .fire, ticks: 30)
        #expect(
            events.contains { event in
                if case .enemyDefeated(.walker, 100, _, .shot) = event {
                    return true
                }
                return false
            })
        #expect(game.score == 100)
    }

    @Test func atMostThreeShotsAreOnScreen() {
        var game = Scenario.game(["                ", " S              ", "################"])
        var generator = SplitMix64(seed: 2)
        for tick in 0..<12 {
            game = game.step(tick % 2 == 0 ? .fire : .none, difficulty: .normal, using: &generator).game
            #expect(game.shots.filter { $0.owner == .runner }.count <= Game.maxRunnerShots)
        }
        #expect(!game.canFire)
    }

    @Test func aChargedShotGoesThroughTheEnemiesItDefeats() {
        var game = Scenario.game(["                ", " S    w w      #", "################"])
        // 撃つボタンを溜まるまで押し続けた状態にして、離す（押した瞬間のふつうの弾は出さない）
        game.runner.held = .fire
        game.runner.charge = Runner.chargeTicks
        let events = Scenario.run(&game, .none, ticks: 30)
        #expect(events.contains(.chargedShot))
        let defeated = events.filter { event in
            if case .enemyDefeated = event {
                return true
            }
            return false
        }
        #expect(defeated.count == 2)
    }

    @Test func fallingOntoAWalkerStompsItAndBounces() {
        var game = Scenario.game(["        ", "        ", "        ", "   w   S", "########"])
        game.runner.position = Point(x: game.enemies[0].position.x, y: game.enemies[0].position.y - Runner.height - 6)
        game.runner.velocity = Velocity(dx: 0, dy: 4)
        game.runner.posture = .airborne
        let events = Scenario.run(&game, .none, ticks: 3)
        #expect(
            events.contains { event in
                if case .enemyDefeated(.walker, _, _, .stomp) = event {
                    return true
                }
                return false
            })
        #expect(game.runner.velocity.dy < 0)
    }

    @Test func aTurretCannotBeStompedAndHurtsInstead() {
        var game = Scenario.game(["        ", "        ", "        ", "   t   S", "########"])
        game.runner.power = 1
        game.runner.position = Point(x: game.enemies[0].position.x, y: game.enemies[0].position.y - Runner.height - 6)
        game.runner.velocity = Velocity(dx: 0, dy: 4)
        game.runner.posture = .airborne
        let events = Scenario.run(&game, .none, ticks: 3, difficulty: .normal)
        let damage = Tuning.make(difficulty: .normal, stage: game.stage).contactDamage
        #expect(events.contains(.runnerHit(damage: damage)))
        #expect(game.runner.health == Runner.maxHealth - damage)
        #expect(game.runner.power == 0)
        #expect(game.enemies[0].isSolid)
    }

    @Test func invulnerabilityBlocksAnotherHitForAWhile() {
        var game = Scenario.game(["                ", " S              ", "################"])
        var events: [GameEvent] = []
        game.hurt(by: 2, events: &events)
        game.hurt(by: 2, events: &events)
        #expect(events == [.runnerHit(damage: 2)])
        #expect(game.runner.health == Runner.maxHealth - 2)
    }

    @Test func runningOutOfHealthCostsALife() {
        var game = Scenario.game(["                ", " S              ", "################"])
        var events: [GameEvent] = []
        game.hurt(by: Runner.maxHealth, events: &events)
        #expect(events == [.runnerHit(damage: Runner.maxHealth), .lifeLost(.health)])
        #expect(game.phase == .dying(ticksLeft: Game.dyingTicks))
    }

    @Test func aSplitterBreaksIntoTwoShards() {
        var game = Scenario.game(["                ", " S    s         ", "################"])
        var events: [GameEvent] = []
        game.damage(at: 0, by: 5, method: .shot, events: &events)
        #expect(game.enemies.filter { $0.kind == .shard }.count == 2)
        #expect(Set(game.enemies.map(\.id)).count == game.enemies.count)
    }

    @Test func theBossFightStartsBehindTheDoorAndEndsTheGameWhenWon() {
        var game = Scenario.at(Stage(number: 4))
        guard let door = game.map.first(.door) else {
            Issue.record("扉が無い")
            return
        }
        game.runner.position = Point(x: door.origin.x + 2 * Field.cellUnits, y: Field.units(15) - Runner.height)
        let opening = Scenario.run(&game, .none, ticks: 1)
        #expect(opening.contains(.bossAppeared))
        #expect(game.doorClosed)
        #expect(game.terrain(column: door.column, row: door.row) == .solid)
        guard case .fighting(var boss) = game.boss else {
            Issue.record("ボス戦が始まらない")
            return
        }
        boss.health = 1
        game.boss = .fighting(boss)
        game.runner.invulnerable = 1_000
        var events: [GameEvent] = []
        var generator = SplitMix64(seed: 3)
        for tick in 0..<400 where game.status == .running {
            let aim: Buttons = game.runner.box.centerX < boss.box.centerX ? .right : .left
            let step = game.step(tick % 2 == 0 ? aim.union(.fire) : aim, difficulty: .normal, using: &generator)
            events += step.events
            game = step.game
        }
        #expect(events.contains(.bossDefeated(points: Game.bossPoints)))
        #expect(game.status == .over(.cleared))
    }
}
