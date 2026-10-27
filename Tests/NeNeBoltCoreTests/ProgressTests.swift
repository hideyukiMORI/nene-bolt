import Testing

@testable import NeNeBoltCore

/// 拾うもの・中間地点・ゴール・制限時間・やり直し（FR-02a・FR-02d・FR-02e）。
@Suite struct ProgressTests {
    @Test func aHundredCoinsGiveALife() {
        var game = Scenario.game(["    ", " Sc ", "####"])
        game.coins = Game.coinsPerLife - 1
        let events = Scenario.run(&game, .right, ticks: 20)
        #expect(events.contains(.coinsOneUp))
        #expect(game.coins == 0)
        #expect(game.reserve == Game.startingReserve + 1)
    }

    @Test func healthAndPowerArePickedUpAndCapped() {
        var game = Scenario.game(["       ", " Shppp ", "#######"])
        game.runner.health = 8
        Scenario.run(&game, .right, ticks: 40)
        #expect(game.runner.health == Runner.maxHealth)
        #expect(game.runner.power == Runner.maxPower)
        #expect(game.score == PickupKind.health.points + 3 * PickupKind.powerUp.points)
    }

    @Test func aCheckpointIsWhereTheRunnerComesBack() {
        var game = Scenario.game(["          ", " S   K  ^ ", "##########"])
        let events = Scenario.run(&game, .right, ticks: 60)
        #expect(events.contains(.checkpointReached))
        #expect(events.contains(.lifeLost(.spike)))
        Scenario.run(&game, .none, ticks: Game.dyingTicks)
        #expect(game.reserve == Game.startingReserve - 1)
        #expect(game.runner.position.x == game.checkpoint.origin.x + 2)
    }

    @Test func theLastLifeEndsTheGame() {
        var game = Scenario.game(["      ", " S    ", "###^^#"])
        game.reserve = 0
        let events = Scenario.run(&game, .right, ticks: 30 + Game.dyingTicks)
        #expect(events.contains(.gameOver(.outOfLives)))
        #expect(game.status == .over(.outOfLives))
    }

    @Test func reachingTheGoalMovesToTheNextStageWithATimeBonus() {
        var game = Scenario.at(Stage(number: 1))
        guard let goal = game.map.first(.goal) else {
            Issue.record("ゴールが無い")
            return
        }
        game.runner.position = Point(x: goal.origin.x - 4, y: goal.origin.y + Field.cellUnits - Runner.height)
        let events = Scenario.run(&game, .right, ticks: Game.clearedTicks + 2)
        #expect(events.contains(.stageCleared(Stage(number: 1))))
        #expect(events.contains(.stageStarted(Stage(number: 2))))
        #expect(game.stage.number == 2)
        #expect(game.score > 0)
    }

    @Test func runningOutOfTimeCostsALifeAfterAHurryUp() {
        var game = Scenario.game(["    ", " S  ", "####"])
        game.timeLeft = Game.hurryTicks + 2
        let events = Scenario.run(&game, .none, ticks: Game.hurryTicks + 3)
        #expect(events.contains(.hurryUp))
        #expect(events.contains(.lifeLost(.timeUp)))
    }

    @Test func aStageBeginsWithItsIntroAndTheTimerFull() {
        let game = Game()
        #expect(game.phase == .intro(ticksLeft: Game.introTicks))
        #expect(game.timeLeft == Game.stageTime)
        #expect(game.lives == Game.startingReserve + 1)
    }
}
