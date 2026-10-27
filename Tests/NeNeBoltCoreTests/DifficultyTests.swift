import Testing

@testable import NeNeBoltCore

/// 難易度と面の効き方（FR-14）。
@Suite struct DifficultyTests {
    @Test func everyDifficultyCyclesWithTheKey() {
        #expect(Difficulty.easy.next == .normal)
        #expect(Difficulty.normal.next == .hard)
        #expect(Difficulty.hard.next == .easy)
    }

    static func isAtLeastAsHard(_ harder: Tuning, as easier: Tuning) -> Bool {
        harder.enemySpeed >= easier.enemySpeed && harder.hopInterval <= easier.hopInterval
            && harder.turretInterval <= easier.turretInterval && harder.enemyShotSpeed >= easier.enemyShotSpeed
            && harder.contactDamage >= easier.contactDamage && harder.bossHealth >= easier.bossHealth
            && harder.bossPause <= easier.bossPause
    }

    @Test(arguments: 1...StageCatalog.count)
    func aHarderDifficultyNeverHelpsTheRunner(_ number: Int) {
        let tunings = Difficulty.allCases.map { Tuning.make(difficulty: $0, stage: Stage(number: number)) }
        for (easier, harder) in zip(tunings, tunings.dropFirst()) {
            #expect(DifficultyTests.isAtLeastAsHard(harder, as: easier))
        }
    }

    @Test(arguments: Difficulty.allCases)
    func aLaterStageNeverHelpsTheRunner(_ difficulty: Difficulty) {
        let tunings = (1...StageCatalog.count).map { Tuning.make(difficulty: difficulty, stage: Stage(number: $0)) }
        for (earlier, later) in zip(tunings, tunings.dropFirst()) {
            #expect(DifficultyTests.isAtLeastAsHard(later, as: earlier))
        }
    }

    /// 寿命の単調性（EASY ≥ NORMAL ≥ HARD）は、本物のランナー 4 名で Engine のテストが見る（ADR 0008）。
    /// テストのランナーは、乱数のものは時間切れで終わることが多く、右へ走るものは同じ所で落ちるので、敵の強さの差が寿命に出ない。
}
