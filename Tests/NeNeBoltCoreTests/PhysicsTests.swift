import Testing

@testable import NeNeBoltCore

/// 自機の動きと地形（FR-02・FR-02a・FR-02b・REQUIREMENTS 第 3 節）。
@Suite struct PhysicsTests {
    /// 固い地形と重なっているか（地形に埋まっていないかを見る）。
    static func isBuried(_ game: Game) -> Bool {
        let (columns, rows) = Game.cells(of: game.runner.box)
        for row in rows {
            for column in columns {
                switch game.terrain(column: column, row: row) {
                case .solid, .ice, .conveyor: return true
                case .empty, .ladder, .spike, .vanishing: continue
                }
            }
        }
        return false
    }

    @Test func aRunnerOnTheFloorStaysOnIt() {
        var game = Scenario.game(["        ", " S      ", "########"])
        Scenario.run(&game, .none, ticks: 90)
        #expect(game.runner.box.bottom == Field.units(2))
        #expect(game.runner.posture == .standing)
    }

    @Test func aLongFallLandsExactlyOnTheFloorWithoutSinking() {
        var rows = Array(repeating: "      ", count: 24)
        rows[1] = " S    "
        rows[23] = "######"
        var game = Scenario.game(rows)
        var generator = SplitMix64(seed: 1)
        for _ in 0..<120 {
            game = game.step(.none, difficulty: .normal, using: &generator).game
            #expect(!PhysicsTests.isBuried(game))
        }
        #expect(game.runner.velocity.dy == 0)
        #expect(game.runner.box.bottom == Field.units(23))
    }

    private func apex(holding ticks: Int) -> Int {
        var game = Scenario.game(["        ", "        ", "        ", "        ", "        ", " S      ", "########"])
        Scenario.run(&game, .none, ticks: 5)
        let floor = game.runner.position.y
        var highest = floor
        var generator = SplitMix64(seed: 1)
        for tick in 0..<60 {
            game = game.step(tick < ticks ? .jump : .none, difficulty: .normal, using: &generator).game
            highest = min(highest, game.runner.position.y)
        }
        return floor - highest
    }

    @Test func holdingJumpGoesHigherThanTappingIt() {
        let full = apex(holding: 30)
        let tap = apex(holding: 1)
        #expect(full >= 3 * Field.cellUnits)
        #expect(full < 5 * Field.cellUnits)
        #expect(tap < full / 2)
    }

    @Test func iceKeepsTheRunnerSlidingAfterTheKeyIsReleased() {
        var ice = Scenario.game(["                    ", " S                  ", "===================="])
        var rock = Scenario.game(["                    ", " S                  ", "####################"])
        Scenario.run(&ice, .right, ticks: 20)
        Scenario.run(&rock, .right, ticks: 20)
        let iceStop = ice.runner.position.x
        let rockStop = rock.runner.position.x
        Scenario.run(&ice, .none, ticks: 3)
        Scenario.run(&rock, .none, ticks: 3)
        #expect(ice.runner.position.x > iceStop)
        #expect(rock.runner.position.x == rockStop)
    }

    @Test func aLadderIsClimbedToItsTopAndStoodOn() {
        var game = Scenario.game(["      ", "      ", "      ", "  H###", "  H   ", "  H   ", " SH   ", "######"])
        Scenario.run(&game, .right, ticks: 5)
        Scenario.run(&game, .up, ticks: 2)
        #expect(game.runner.posture == .climbing)
        Scenario.run(&game, .up, ticks: 40)
        Scenario.run(&game, .none, ticks: 10)
        #expect(game.runner.posture == .standing)
        #expect(game.runner.box.bottom == Field.units(3))
    }

    @Test func aConveyorCarriesAStandingRunner() {
        var game = Scenario.game(["          ", " S        ", ">>>>>>>>>>"])
        let start = game.runner.position.x
        Scenario.run(&game, .none, ticks: 20)
        #expect(game.runner.position.x > start)
    }

    @Test func aVanishingBlockDropsTheRunnerWhenItGoes() {
        var game = Scenario.game(["    ", " S  ", "1111", "    ", "    ", "####"])
        #expect(VanishingClock.isVisible(group: 0, at: 1))
        Scenario.run(&game, .none, ticks: VanishingClock.visibleTicks - 2)
        #expect(game.runner.posture == .standing)
        Scenario.run(&game, .none, ticks: 6)
        #expect(game.runner.posture == .airborne)
        #expect(game.runner.box.bottom > Field.units(2))
    }

    @Test func aBlockThatAppearsAroundTheRunnerDoesNotTrapIt() {
        var game = Scenario.game([" S      ", "  2     ", "########"])
        Scenario.run(&game, .none, ticks: 5)
        Scenario.run(&game, .right, ticks: 40)
        #expect(game.runner.position.x > Field.units(4))
        #expect(game.runner.box.bottom == Field.units(2))
    }

    @Test func aMovingPlatformCarriesTheRunner() {
        var game = Scenario.game(["          ", "  S       ", "  M       ", "          ", "          "])
        game.runner.position = Point(
            x: game.platforms[0].position.x + 4, y: game.platforms[0].position.y - Runner.height)
        game.runner.posture = .standing
        let start = game.runner.position.x
        Scenario.run(&game, .none, ticks: 10)
        #expect(game.runner.position.x != start)
        #expect(game.runner.box.bottom == game.platforms[0].box.origin.y)
    }

    @Test func wallsStopTheRunner() {
        var game = Scenario.game(["    #", " S  #", "#####"])
        Scenario.run(&game, .right, ticks: 30)
        #expect(game.runner.box.right == Field.units(4))
    }

    @Test func spikesAndPitsCostALife() {
        var spiky = Scenario.game(["      ", " S    ", "###^^#"])
        #expect(Scenario.run(&spiky, .right, ticks: 30).contains(.lifeLost(.spike)))
        var open = Scenario.game(["      ", " S    ", "##    "])
        #expect(Scenario.run(&open, .right, ticks: 60).contains(.lifeLost(.pit)))
    }

    @Test func vanishingGroupsAppearInOrder() {
        let firsts = (0..<4).map { group in
            (0..<VanishingClock.period).first { tick in
                VanishingClock.isVisible(group: group, at: tick)
                    && !VanishingClock.isVisible(group: group, at: tick - 1)
            }
        }
        #expect(firsts == [0, 30, 60, 90])
        #expect((0..<VanishingClock.period).filter { VanishingClock.isVisible(group: 2, at: $0) }.count == 54)
    }
}
