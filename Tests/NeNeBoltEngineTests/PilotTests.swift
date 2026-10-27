import Testing

@testable import NeNeBoltCore
@testable import NeNeBoltEngine

/// ランナーとキャスト（FR-04・FR-06・ADR 0008）。
struct PilotTests {
    /// 兄弟のキャスト（Gambit・Reversi・Igo・Poker・Swarm）の名前。
    static let siblings: Set<String> = [
        "GRANNY.DLL", "MORT.SH", "VEX.EXE", "CORNER.SYS", "FLIP.BAT", "LAZY.CRON", "SPAM.EML", "MOYO.PNG", "SEKI.LCK",
        "SENTE.SYS", "TENUKI.LOG", "BLUFF.EXE", "NIT.BAK", "ODDS.CSV", "TILT.SH", "BLASTER.BIN", "LUCKY.INI",
        "NERVOUS.TMP", "SNIPER.ISO",
    ]

    @Test func theCastIsFourDistinctNamesNotSharedWithSiblings() {
        let names = Persona.roster.map(\.name)
        #expect(names.count == 4)
        #expect(Set(names).count == 4)
        #expect(Set(names).isDisjoint(with: Self.siblings))
        #expect(Persona.roster.allSatisfy { $0.face.unicodeScalars.allSatisfy(\.isASCII) })
    }

    /// 道のりの地図は、どの面でも始まりから行き先までつながっている（届かない面は、ランナーが行き先を見失う）。
    @Test(arguments: 1...StageCatalog.count)
    func everyStageStartReachesTheGoal(_ number: Int) {
        var game = Game()
        var ignored: [GameEvent] = []
        game.load(Stage(number: number), events: &ignored)
        let route = Route.make(for: game)
        #expect(route.distance(from: game.runner.box) < Route.unreachable)
    }

    /// 同じシードなら、同じボタンの列になる（FR-05）。
    @Test func theSameSeedGivesTheSameButtons() {
        func trace() -> [Buttons] {
            var generator = SplitMix64(seed: 4)
            var pilotGenerator = SplitMix64(seed: 5)
            var pilot = Pilot(persona: .glitch)
            var game = Game()
            var buttons: [Buttons] = []
            for _ in 0..<900 {
                let pressed = pilot.buttons(for: game, difficulty: .normal, using: &pilotGenerator)
                buttons.append(pressed)
                game = game.step(pressed, difficulty: .normal, using: &generator).game
            }
            return buttons
        }
        let first = trace()
        #expect(first == trace())
        #expect(first.contains { $0.contains(.jump) })
        #expect(first.contains { $0.contains(.right) })
    }

    /// どのランナーもどの難易度でも、ゲームは刻みの上限に届かずに終わる（REQUIREMENTS 第 3 節）。
    @Test(arguments: Persona.roster)
    func everyRunnerFinishesEveryGame(_ persona: Persona) {
        for difficulty in Difficulty.allCases {
            let measure = Measure.play(persona, difficulty: difficulty, seed: 11)
            #expect(measure.ending != nil)
            #expect(measure.ending != .timeLimit)
        }
    }

    /// 難易度の単調性: 4 名 × 同じシードで、到達した面（ボスを倒したら 5）の合計が EASY ≥ NORMAL ≥ HARD（REQUIREMENTS 第 3 節）。
    /// 1 名ずつでは本物のゲームの揺れの方が大きく、HOARD と GLITCH で NORMAL と HARD が入れ替わった（ADR 0008）。
    @Test func harderDifficultiesGetLessFar() {
        let progress = Difficulty.allCases.map { difficulty in
            Persona.roster.reduce(0) { sum, persona in
                (0..<UInt64(PilotTests.seeds)).reduce(sum) { total, seed in
                    let measure = Measure.play(persona, difficulty: difficulty, seed: seed)
                    return total + measure.stage + (measure.ending == .cleared ? 1 : 0)
                }
            }
        }
        #expect(progress[0] >= progress[1], "\(progress)")
        #expect(progress[1] >= progress[2], "\(progress)")
    }

    /// 単調性を見るシードの数（ランナーごと・難易度ごと）。黙って下げない（ADR 0008）。
    static let seeds = 8
}
