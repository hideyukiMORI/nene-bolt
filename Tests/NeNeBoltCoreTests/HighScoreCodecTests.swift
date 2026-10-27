import NeNeBoltCore
import Testing

/// ハイスコアのファイルの形式（FR-02e・ARC-009・ADR 0011）。
@Suite struct HighScoreCodecTests {
    static let table = HighScoreTable(entries: [
        HighScore(score: 12_340, pilot: "SNIPER.ISO", stage: 7, difficulty: .hard),
        HighScore(score: 900, pilot: "LUCKY.INI", stage: 2, difficulty: .easy),
    ])

    @Test func aTableSurvivesTheRoundTrip() {
        let text = HighScoreCodec.encode(Self.table)
        #expect(text == "nene-bolt-highscores 1\n12340\t7\thard\tSNIPER.ISO\n900\t2\teasy\tLUCKY.INI\n")
        #expect(HighScoreCodec.decode(text) == .decoded(Self.table))
    }

    @Test func anEmptyTableIsJustTheHeader() {
        #expect(HighScoreCodec.decode(HighScoreCodec.encode(.empty)) == .decoded(.empty))
    }

    @Test func anUnknownVersionIsRejected() {
        #expect(HighScoreCodec.decode("nene-bolt-highscores 2\n") == .rejected(.unknownVersion))
        #expect(HighScoreCodec.decode("") == .rejected(.unknownVersion))
    }

    @Test(arguments: [
        "abc\t1\teasy\tP", "-5\t1\teasy\tP", "5\t0\teasy\tP", "5\t1\tlunatic\tP", "5\t1\teasy\t", "5\t1\teasy",
        "5\t1\teasy\tA_VERY_LONG_PILOT_NAME",
    ])
    func aBrokenLineIsRejectedWithItsNumber(_ line: String) {
        let text = "nene-bolt-highscores 1\n100\t1\tnormal\tOK.BIN\n" + line + "\n"
        #expect(HighScoreCodec.decode(text) == .rejected(.malformedLine(3)))
    }

    @Test func moreThanFiveEntriesAreTrimmedToTheBestFive() {
        let lines = (1...7).map { "\($0 * 100)\t1\tnormal\tP" }
        let outcome = HighScoreCodec.decode("nene-bolt-highscores 1\n" + lines.joined(separator: "\n") + "\n")
        guard case .decoded(let table) = outcome else {
            Issue.record("読めなかった")
            return
        }
        #expect(table.entries.map(\.score) == [700, 600, 500, 400, 300])
    }
}
