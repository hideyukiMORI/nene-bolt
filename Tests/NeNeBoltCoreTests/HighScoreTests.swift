import NeNeBoltCore
import Testing

/// ハイスコアの上位 5 件の並べ方（FR-02e）。
@Suite struct HighScoreTests {
    private func entry(_ score: Int, _ pilot: String = "P") -> HighScore {
        HighScore(score: score, pilot: pilot, stage: 1, difficulty: .normal)
    }

    @Test func entriesAreKeptHighestFirstAndOnlyFive() {
        let table = HighScoreTable(entries: [100, 500, 300, 900, 200, 700].map { entry($0) })
        #expect(table.entries.map(\.score) == [900, 700, 500, 300, 200])
        #expect(table.best == 900)
    }

    @Test func aNewScoreGetsItsRank() {
        let table = HighScoreTable(entries: [900, 700, 500].map { entry($0) })
        let insertion = table.inserting(entry(600, "NEW"))
        #expect(insertion.rank == .ranked(3))
        #expect(insertion.table.entries.map(\.score) == [900, 700, 600, 500])
    }

    @Test func anEqualScoreGoesBelowTheOlderOne() {
        let table = HighScoreTable(entries: [entry(500, "OLD")])
        let insertion = table.inserting(entry(500, "NEW"))
        #expect(insertion.rank == .ranked(2))
        #expect(insertion.table.entries.map(\.pilot) == ["OLD", "NEW"])
    }

    @Test func aScoreBelowAFullTableIsUnranked() {
        let table = HighScoreTable(entries: [900, 800, 700, 600, 500].map { entry($0) })
        let insertion = table.inserting(entry(500))
        #expect(insertion.rank == .unranked)
        #expect(insertion.table == table)
    }

    @Test func theFirstScoreIsNumberOne() {
        let insertion = HighScoreTable.empty.inserting(entry(0))
        #expect(insertion.rank == .ranked(1))
        #expect(HighScoreTable.empty.best == 0)
    }
}
